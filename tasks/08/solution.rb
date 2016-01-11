class Spreadsheet
  class Error < RuntimeError
  end

  class CellIndex
    PATTERN         = /\A([A-Z]+)([0-9]+)\z/.freeze
    ALPHABET_SIZE   = 'Z'.ord - 'A'.ord + 1
    ALPHABET_OFFSET = 'A'.ord - 1

    attr_reader :row, :column

    def initialize(index)
      @row, @column = parse(index)
    end

    private

    def parse(cell_index)
      if cell_index =~ PATTERN
        column_index = letter_index_to_number($1) - 1
        row_index    = $2.to_i - 1
      else
        raise Error.new("Invalid cell index '#{cell_index}'")
      end

      [row_index, column_index]
    end

    def letter_index_to_number(letter_index)
      letter_index.chars.reverse.map.with_index do |char, position|
        (char.ord - ALPHABET_OFFSET) * ALPHABET_SIZE**position
      end.reduce(:+)
    end
  end

  class Number
    PATTERN = /\A([\d\.]+)\z/

    def self.matches?(expression)
      PATTERN =~ expression
    end

    def initialize(expression)
      if expression.is_a?(String)
        @number = PATTERN.match(expression).captures.first.to_f
      else
        @number = expression
      end
    end

    def value_for(sheet)
      @number
    end

    def to_s
      if @number == @number.to_i
        @number.to_i.to_s
      else
        '%.2f' % @number
      end
    end
  end

  class Function
    PATTERN   = /\A([A-Z]+)\((.*)\)\z/
    FUNCTIONS = {
      'ADD'       => ->(a, b, *more) { [a, b, more].flatten.reduce(:+) },
      'MULTIPLY'  => ->(a, b, *more) { [a, b, more].flatten.reduce(:*) },
      'SUBTRACT'  => ->(x, y) { x - y },
      'DIVIDE'    => ->(x, y) { x / y },
      'MOD'       => ->(x, y) { x % y },
    }

    def self.matches?(expression)
      PATTERN =~ expression
    end

    def initialize(expression)
      name, arguments = PATTERN.match(expression).captures

      @name      = name
      @function  = FUNCTIONS[name]
      @arguments = arguments.split(/\s*,\s*/)

      raise Error.new("Unknown function '#{name}'") unless @function

      check_arguments_count
    end

    def value_for(sheet)
      Number.new @function.call(*evaluated_arguments_for(sheet))
    end

    private

    def evaluated_arguments_for(sheet)
      @arguments.map do |argument|
        Expression.new(argument, expression_types: [Number, CellReference])
          .value_for(sheet)
      end
    end

    def check_arguments_count
      if @function.arity > 0 and @function.arity != @arguments.size
        raise Error.new "Wrong number of arguments for '#{@name}': expected " \
          "#{@function.arity}, got #{@arguments.size}"
      elsif @function.arity < -1 and @function.arity.abs - 1 > @arguments.size
        raise Error.new "Wrong number of arguments for '#{@name}': expected " \
          "at least #{@function.arity.abs - 1}, got #{@arguments.size}"
      end
    end
  end

  class CellReference
    def self.matches?(expression)
      CellIndex::PATTERN =~ expression
    end

    def initialize(expression)
      @reference = expression
    end

    def value_for(sheet)
      Expression.new(sheet[@reference], expression_types: [Number])
        .value_for(sheet)
    end
  end

  class Expression
    ALL_EXPRESSION_TYPES = [
      Number,
      CellReference,
      Function,
    ]

    def initialize(expression, expression_types: nil)
      @expression_types = expression_types || ALL_EXPRESSION_TYPES
      @expression       = expression
    end

    def value_for(sheet)
      expression_type_for(@expression).value_for(sheet)
    end

    private

    def expression_type_for(expression)
      type = @expression_types.find { |type| type.matches?(expression) }

      if type
        type.new(expression)
      else
        raise Error.new("Invalid expression '#{expression}'")
      end
    end
  end

  def initialize(sheet = '')
    @cells = sheet
      .strip
      .split("\n")
      .map { |line| line.strip.split(/\t|  +/).map(&:strip) }
  end

  def empty?
    @cells.empty?
  end

  def cell_at(cell_index)
    index = CellIndex.new(cell_index)

    cell = @cells[index.row][index.column] if @cells[index.row]

    if cell
      cell
    else
      raise Error.new("Cell '#{cell_index}' does not exist")
    end
  end

  def [](cell_index)
    evaluate(cell_at(cell_index))
  end

  def to_s
    @cells.map do |row|
      row.map { |cell| evaluate(cell) }.join("\t")
    end.join("\n")
  end

  private

  def evaluate(raw_value)
    return unless raw_value

    if raw_value.start_with?('=')
      expression = raw_value[1..-1].strip

      Expression.new(expression).value_for(self).to_s
    else
      raw_value
    end
  end
end
