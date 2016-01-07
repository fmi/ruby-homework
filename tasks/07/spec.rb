describe LazyMode do
  describe LazyMode::Date do
    it 'can parse year' do
      date = LazyMode::Date.new('2012-10-03')
      expect(date.year).to eq(2012)
    end

    it 'can parse month' do
      date = LazyMode::Date.new('2012-10-03')
      expect(date.month).to eq(10)
    end

    it 'can parse day' do
      date = LazyMode::Date.new('2012-10-03')
      expect(date.day).to eq(3)
    end
  end

  describe LazyMode::Note do
    it 'has file_name' do
      file = LazyMode.create_file('my_todos') do
        note 'one' do
          # not important
        end
      end
      expect(file.notes.first.file_name).to eq('my_todos')
    end

    it 'has header' do
      file = LazyMode.create_file('not_important') do
        note 'todo_list' do
          # not important
        end
      end
      expect(file.notes.first.header).to eq('todo_list')
    end

    describe '#tags' do
      it 'has tags' do
        file = LazyMode.create_file('not_important') do
          note 'not_important', :important, :wip, :blocker do
            # not important
          end
        end
        expect(file.notes.first.tags).to eq([:important, :wip, :blocker])
      end

      it 'can have no tags' do
        file = LazyMode.create_file('not_important') do
          note 'not_important' do
            # not important
          end
        end
        expect(file.notes.first.tags).to eq([])
      end
    end

    describe '#status' do
      it 'has status' do
        file = LazyMode.create_file('not_important') do
          note 'not_important' do
            status :postponed
          end
        end
        expect(file.notes.first.status).to eq(:postponed)
      end

      it 'can have default status' do
        file = LazyMode.create_file('not_important') do
          note 'not_important' do
            # not important
          end
        end
        expect(file.notes.first.status).to eq(:topostpone)
      end
    end

    describe '#body' do
      it 'has body' do
        file = LazyMode.create_file('not_important') do
          note 'not_important' do
            body 'Do not forget to...'
          end
        end
        expect(file.notes.first.body).to eq('Do not forget to...')
      end

      it 'can have no body' do
        file = LazyMode.create_file('not_important') do
          note 'not_important' do
            # not important
          end
        end
        expect(file.notes.first.body).to eq('')
      end
    end

    it 'can have nested notes' do
      file = LazyMode.create_file('not_important') do
        note 'not_important' do
          note 'one' do
            # not important
          end

          note 'two' do
            # not important
          end

          note 'three' do
            # not important
          end
        end
      end
      expect(file.notes.first.body).to eq('')
    end
  end

  describe '#daily_agenda' do
    it 'returns note scheduled without repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-12-12'
        end

        note 'simple note 2' do
          scheduled '2012-12-13'
        end
      end

      agenda = file.daily_agenda(LazyMode::Date.new('2012-12-12'))
      expect(agenda.notes.size).to eq(1)
      note = agenda.notes.first
      expect(note.header).to eq('simple note')
      expect(note.status).to eq(:topostpone)
      expect(note.tags).to eq([])
      expect(note.date.year).to eq(2012)
      expect(note.date.month).to eq(12)
      expect(note.date.day).to eq(12)
    end

    it 'returns note scheduled with daily repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-12-11 +1d'
        end

        note 'simple note 2' do
          scheduled '2012-12-13'
        end
      end

      agenda = file.daily_agenda(LazyMode::Date.new('2012-12-12'))
      expect(agenda.notes.size).to eq(1)
      note = agenda.notes.first
      expect(note.header).to eq('simple note')
      expect(note.status).to eq(:topostpone)
      expect(note.tags).to eq([])
      expect(note.date.year).to eq(2012)
      expect(note.date.month).to eq(12)
      expect(note.date.day).to eq(12)
    end

    it 'returns note scheduled with weekly repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-12-5 +1w'
        end

        note 'simple note 2' do
          scheduled '2012-12-13 +1w'
        end
      end

      agenda = file.daily_agenda(LazyMode::Date.new('2012-12-12'))
      expect(agenda.notes.size).to eq(1)
      note = agenda.notes.first
      expect(note.header).to eq('simple note')
      expect(note.status).to eq(:topostpone)
      expect(note.tags).to eq([])
      expect(note.date.year).to eq(2012)
      expect(note.date.month).to eq(12)
      expect(note.date.day).to eq(12)
    end


    it 'returns note scheduled with monthly repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-11-12 +2m'
        end

        note 'simple note 2' do
          scheduled '2012-12-13 +2m'
        end
      end

      agenda = file.daily_agenda(LazyMode::Date.new('2013-01-12'))
      expect(agenda.notes.size).to eq(1)
      note = agenda.notes.first
      expect(note.header).to eq('simple note')
      expect(note.status).to eq(:topostpone)
      expect(note.tags).to eq([])
      expect(note.date.year).to eq(2013)
      expect(note.date.month).to eq(1)
      expect(note.date.day).to eq(12)
    end

    it 'does not return note whose start date is in the future' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-11-12 +1m'
        end
      end

      agenda = file.daily_agenda(LazyMode::Date.new('2012-10-12'))
      expect(agenda.notes.size).to eq(0)
    end

    it 'returns nested notes' do
      file = LazyMode.create_file('nesting') do
        note 'task' do
          scheduled '2012-08-07'

          note 'subtask' do
            scheduled '2012-08-06'
          end
        end
      end

      agenda = file.daily_agenda(LazyMode::Date.new('2012-08-06'))

      expect(agenda.notes.size).to eq(1)
    end
  end

  describe '#weekly_agenda' do
    it 'returns note scheduled without repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-12-12'
        end

        note 'simple note 2' do
          scheduled '2012-12-13'
        end
      end

      agenda = file.weekly_agenda(LazyMode::Date.new('2012-12-06'))
      expect(agenda.notes.size).to eq(1)
      note = agenda.notes.first
      expect(note.header).to eq('simple note')
      expect(note.status).to eq(:topostpone)
      expect(note.tags).to eq([])
      expect(note.date.year).to eq(2012)
      expect(note.date.month).to eq(12)
      expect(note.date.day).to eq(12)
    end

    it 'returns multiple notes with different dates when scheduled with daily repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-12-11 +1d'
        end

        note 'simple note 2' do
          scheduled '2012-12-15'
        end
      end

      agenda = file.weekly_agenda(LazyMode::Date.new('2012-12-06'))
      expect(agenda.notes.size).to eq(2)
      agenda.notes.each do |note|
        expect(note.header).to eq('simple note')
        expect(note.status).to eq(:topostpone)
        expect(note.tags).to eq([])
        expect(note.date.year).to eq(2012)
        expect(note.date.month).to eq(12)
      end

      expect(agenda.notes.map(&:date).map(&:day)).to match_array([11, 12])
    end

    it 'returns note scheduled with weekly repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-12-5 +1w'
        end

        note 'simple note 2' do
          scheduled '2012-12-13 +1w'
        end
      end

      agenda = file.weekly_agenda(LazyMode::Date.new('2012-12-10'))
      expect(agenda.notes.size).to eq(2)

      first_note = agenda.notes.find { |note| note.header == 'simple note' }
      expect(first_note.header).to eq('simple note')
      expect(first_note.status).to eq(:topostpone)
      expect(first_note.tags).to eq([])
      expect(first_note.date.year).to eq(2012)
      expect(first_note.date.month).to eq(12)
      expect(first_note.date.day).to eq(12)

      second_note = agenda.notes.find { |note| note.header == 'simple note 2' }
      expect(second_note.header).to eq('simple note 2')
      expect(second_note.status).to eq(:topostpone)
      expect(second_note.tags).to eq([])
      expect(second_note.date.year).to eq(2012)
      expect(second_note.date.month).to eq(12)
      expect(second_note.date.day).to eq(13)
    end


    it 'returns note scheduled with monthly repeater' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-11-12 +2m'
        end

        note 'simple note 2' do
          scheduled '2012-12-13 +2m'
        end
      end

      agenda = file.weekly_agenda(LazyMode::Date.new('2013-01-10'))
      expect(agenda.notes.size).to eq(1)
      note = agenda.notes.first
      expect(note.header).to eq('simple note')
      expect(note.status).to eq(:topostpone)
      expect(note.tags).to eq([])
      expect(note.date.year).to eq(2013)
      expect(note.date.month).to eq(1)
      expect(note.date.day).to eq(12)
    end

    it 'does not return note whose start date is in the future' do
      file = LazyMode.create_file('file') do
        note 'simple note' do
          scheduled '2012-11-12 +1m'
        end
      end

      agenda = file.weekly_agenda(LazyMode::Date.new('2012-10-12'))
      expect(agenda.notes.size).to eq(0)
    end

    it 'returns nested notes' do
      file = LazyMode.create_file('nesting') do
        note 'task' do
          scheduled '2012-08-07'

          note 'subtask' do
            scheduled '2012-08-06 +1m'
          end
        end
      end

      agenda = file.weekly_agenda(LazyMode::Date.new('2012-09-05'))

      expect(agenda.notes.size).to eq(1)
    end
  end

  describe '#where' do
    before(:each) do
      file = LazyMode.create_file('notes') do
        note 'important', :important do
          scheduled '2012-12-12'
          status :topostpone
          body 'Important note'
        end

        note 'not important', :not_important do
          scheduled '2012-12-12'
          status :postponed
          body 'Not important note'
        end

        note 'very important', :important do
          scheduled '2012-12-12'
          status :topostpone
          body 'Very important note'
        end
      end

      @agenda = file.daily_agenda(LazyMode::Date.new('2012-12-12'))
    end

    it 'filters by tag' do
      notes = @agenda.where(tag: :important).notes
      expect(notes.size).to eq(2)
      important_note = notes.find { |note| note.header == 'important' }
      expect(important_note.file_name).to eq('notes')
      expect(important_note.header).to eq('important')
      expect(important_note.tags).to eq([:important])
      expect(important_note.status).to eq(:topostpone)
      expect(important_note.body).to eq('Important note')

      very_important_note = notes.find { |note| note.header == 'very important' }
      expect(very_important_note.file_name).to eq('notes')
      expect(very_important_note.header).to eq('very important')
      expect(very_important_note.tags).to eq([:important])
      expect(very_important_note.status).to eq(:topostpone)
      expect(very_important_note.body).to eq('Very important note')
    end

    it 'filters by body text' do
      notes = @agenda.where(text: /Very/).notes

      expect(notes.size).to eq(1)
      very_important_note = notes.first
      expect(very_important_note.file_name).to eq('notes')
      expect(very_important_note.header).to eq('very important')
      expect(very_important_note.tags).to eq([:important])
      expect(very_important_note.status).to eq(:topostpone)
      expect(very_important_note.body).to eq('Very important note')
    end

    it 'filters by header text' do
      notes = @agenda.where(text: /not important/).notes

      expect(notes.size).to eq(1)
      note = notes.first
      expect(note.file_name).to eq('notes')
      expect(note.header).to eq('not important')
      expect(note.tags).to eq([:not_important])
      expect(note.status).to eq(:postponed)
      expect(note.body).to eq('Not important note')
    end

    it 'filters by status' do
      notes = @agenda.where(status: :postponed).notes
      expect(notes.size).to eq(1)
      note = notes.first
      expect(note.file_name).to eq('notes')
      expect(note.header).to eq('not important')
      expect(note.tags).to eq([:not_important])
      expect(note.status).to eq(:postponed)
      expect(note.body).to eq('Not important note')
    end

    it 'filters by multiple filters' do
      notes = @agenda.where(text: /important/, status: :postponed).notes
      expect(notes.size).to eq(1)
      note = notes.first
      expect(note.file_name).to eq('notes')
      expect(note.header).to eq('not important')
      expect(note.tags).to eq([:not_important])
      expect(note.status).to eq(:postponed)
      expect(note.body).to eq('Not important note')
    end
  end

  describe '.create_file' do
    it 'can assign name to files' do
      file = LazyMode.create_file('important_notes_and_todos') do
        # not important
      end
      expect(file.name).to eq('important_notes_and_todos')
    end

    it 'can build notes in the block' do
      file = LazyMode.create_file('not_important') do
        note 'one' do
          # not important
        end

        note 'two' do
          # not important
        end

        note 'three' do
          # not important
        end
      end
      expect(file.notes.size).to eq(3)
    end
  end
end
