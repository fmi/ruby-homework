module RBFS
  class Parser
    def initialize(string_data)
      @data = string_data
    end

    def each
      size = read_next_record.to_i

      size.times do
        entity_name   = read_next_record
        entity_string = read_next_entity

        yield entity_name, entity_string
      end
    end

    private

    def read_next_entity
      size   = read_next_record.to_i
      entity = @data[0...size]

      @data = @data[size...@data.size]

      entity
    end

    def read_next_record
      record, @data = @data.split(':', 2)

      record
    end
  end

  class Directory
    attr_reader :files, :directories

    def initialize(files={}, directories={})
      @files       = files
      @directories = directories
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory=Directory.new)
      @directories[name] = directory
    end

    def [](name)
      @directories[name] || @files[name]
    end

    def serialize
      files       = "#{@files.size}:#{serialize_entities(@files)}"
      directories = "#{@directories.size}:#{serialize_entities(@directories)}"

      "#{files}#{directories}"
    end

    def self.parse(string_data)
      parser = Parser.new(string_data)

      files       = {}
      directories = {}

      parser.each { |name, entity| files[name]       = File.parse(entity)      }
      parser.each { |name, entity| directories[name] = Directory.parse(entity) }

      Directory.new(files, directories)
    end

    private

    def serialize_entities(entities)
      entities.map do |name, entity|
        serialized_entity = entity.serialize

        "#{name}:#{serialized_entity.size}:#{serialized_entity}"
      end.join('')
    end
  end

  class File
    attr_accessor :data

    def initialize(data=nil)
      @data = data
    end

    def data_type
      case @data
      when nil     then :nil
      when String  then :string
      when Symbol  then :symbol
      when Numeric then :number
      else              :boolean
      end
    end

    def serialize
      "#{data_type}:#{@data.to_s}"
    end

    def self.parse(string)
      data = parse_data *string.split(':', 2)

      File.new data
    end

    private

    def self.parse_data(type, data)
      case type
      when 'nil'    then nil
      when 'string' then data
      when 'symbol' then data.to_sym
      when 'number' then parse_number(data)
      else               data == 'true'
      end
    end

    def self.parse_number(data)
      if data.include? '.'
        data.to_f
      else
        data.to_i
      end
    end
  end
end
