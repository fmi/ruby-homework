module LazyMode
  class Date
    class Diff
      def initialize(first, second)
        @first, @second = first, second
      end

      def days
        @first.to_days - @second.to_days
      end
    end

    attr_reader :year, :month, :day

    def initialize(string)
      @year, @month, @day = string.split('-').map(&:to_i)
      @string = string
    end

    def after(days)
      days_for_after_date = to_days + days
      day_of_month = (days_for_after_date % 360) % 30
      month = 1 + (days_for_after_date % 360) / 30
      year = days_for_after_date / 360
      Date.new(sprintf('%.4d-%.2d-%.2d', year, month, day_of_month))
    end

    def ==(date)
      (self - date).days == 0
    end

    def -(date)
      Diff.new(self, date)
    end

    def to_days
      year * 360 + (month - 1) * 30 + day
    end

    def to_s
      @string
    end
  end

  class NoteWithDate
    attr_reader :file_name, :header, :tags, :status, :body, :date

    def initialize(note, date)
      @file_name = note.file_name
      @header    = note.header
      @tags      = note.tags
      @status    = note.status
      @body      = note.body
      @date      = date
    end
  end

  class Note
    class Schedule
      def initialize(date)
        @date = date
      end

      def scheduled_for?(date)
        @date == date
      end
    end

    class NullSchedule
      def scheduled_for?(_)
        false
      end
    end

    class DailySchedule
      def initialize(start_date, number_of_days_repeating)
        @start_date = start_date
        @number_of_days_repeating = number_of_days_repeating
      end

      def scheduled_for?(date)
        days_since_start_date = (date - @start_date).days

        return false if days_since_start_date < 0

        days_since_start_date % @number_of_days_repeating == 0
      end

      def self.from_string(string)
        start_date = Date.new(string[0..9])

        new(start_date, number_of_days_repeating(string))
      end

      private

      def self.number_of_days_repeating(string)
        repeater = string[11..-1]

        case repeater
        when /d$/ then 1  * repeater[/\d+/].to_i
        when /w$/ then 7  * repeater[/\d+/].to_i
        when /m$/ then 30 * repeater[/\d+/].to_i
        end
      end
    end

    attr_reader :file_name, :header, :tags
    attr_accessor :sub_notes, :status, :body, :schedule

    def initialize(file_name, header, tags)
      @file_name = file_name
      @header = header
      @tags = tags
    end

    def flatten_sub_notes
      @sub_notes.flat_map { |sub_note| [sub_note] + sub_note.flatten_sub_notes }
    end

    def scheduled_for?(date)
      @schedule.scheduled_for?(date)
    end

    def with_date(date)
      NoteWithDate.new(self, date)
    end

    class DSLBuilder
      def initialize(file_name, header, tags)
        @file_name = file_name
        @header = header
        @tags = tags
        @sub_notes = []
      end

      def status(status)
        @status = status
      end

      def body(body)
        @body = body
      end

      def scheduled(date)
        @schedule = if date[/[dwm]$/]
                      DailySchedule.from_string(date)
                    else
                      Schedule.new(Date.new(date))
                    end
      end

      def note(header, *tags, &block)
        @sub_notes << self.class.build(@file_name, header, tags, &block)
      end

      def to_note
        Note.new(@file_name, @header, @tags).tap do |note|
          note.status    = @status    || :topostpone
          note.body      = @body      || ''
          note.schedule  = @schedule  || NullSchedule.new
          note.sub_notes = @sub_notes
        end
      end

      def self.build(file_name, header, tags, &block)
        builder = new(file_name, header, tags)
        builder.instance_eval(&block)
        builder.to_note
      end
    end
  end

  class FilteredNotes
    attr_reader :notes

    def initialize(notes)
      @notes = notes
    end

    def where(tag: nil, status: nil, text: nil)
      filtered_notes = notes.dup
      filter_by_tag(tag, filtered_notes)       if tag
      filter_by_status(status, filtered_notes) if status
      filter_by_text(text, filtered_notes)     if text
      FilteredNotes.new(filtered_notes)
    end

    private

    def filter_by_tag(tag, filtered_notes)
      filtered_notes.select! { |note| note.tags.include?(tag) }
    end

    def filter_by_status(status, filtered_notes)
      filtered_notes.select! { |note| note.status == status }
    end

    def filter_by_text(regex, filtered_notes)
      filtered_notes.select! do |note|
        note.header[regex] || note.body[regex]
      end
    end
  end

  class File
    attr_reader :name, :notes

    def initialize(name, notes)
      @name, @notes = name, notes
    end

    def daily_agenda(date)
      filtered_notes = flatten_notes.select do |note|
        note.scheduled_for?(date)
      end

      filtered_notes.map! { |note| note.with_date(date) }

      FilteredNotes.new(filtered_notes)
    end

    def weekly_agenda(date)
      filtered_notes = 0.upto(6).flat_map do |days|
        daily_agenda(date.after(days)).notes
      end

      FilteredNotes.new(filtered_notes)
    end

    def flatten_notes
      notes + notes.flat_map { |note| note.flatten_sub_notes }
    end

    class DSLBuilder
      def initialize(file_name)
        @file_name = file_name
        @notes = []
      end

      def note(header, *tags, &block)
        @notes << Note::DSLBuilder.build(@file_name, header, tags, &block)
      end

      def to_file
        File.new(@file_name, @notes)
      end

      def self.build(file_name, &block)
        builder = new(file_name)
        builder.instance_eval(&block)
        builder.to_file
      end
    end
  end

  def self.create_file(file_name, &block)
    File::DSLBuilder.build(file_name, &block)
  end
end
