class Filter
  def initialize(&block)
    @block = block
  end

  def &(other)
    Filter.new { |number| self.accepts?(number) and other.accepts?(number) }
  end

  def |(other)
    Filter.new { |number| self.accepts?(number) or other.accepts?(number) }
  end

  def accepts?(number)
    @block.call number
  end
end

class TypeFilter < Filter
  def initialize(type)
    @type = type
  end

  def accepts?(number)
    case @type
    when :integer then number.is_a? Integer
    when :real    then number.is_a? Float or number.is_a? Rational
    when :complex then number.is_a? Complex
    else               false
    end
  end
end

class SignFilter < Filter
  def initialize(sign)
    @sign = sign
  end

  def accepts?(number)
    case @sign
    when :positive     then number > 0
    when :non_positive then number <= 0
    when :negative     then number < 0
    when :non_negative then number >= 0
    else                    false
    end
  end
end

class NumberSet
  include Enumerable

  def initialize
    @numbers = []
  end

  def each(&block)
    @numbers.each(&block)
  end

  def <<(number)
    @numbers << number unless @numbers.include? number
  end

  def [](filter)
    @numbers.each_with_object(NumberSet.new) do |number, numbers|
      numbers << number if filter.accepts? number
    end
  end

  def size
    @numbers.size
  end

  def empty?
    @numbers.empty?
  end
end
