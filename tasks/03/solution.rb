class Integer
  def prime?
    return false if self == 1
    2.upto(self ** 0.5).all? { |n| self % n != 0 }
  end
end

class RationalSequence
  include Enumerable

  def initialize(count)
    @count = count
  end

  def each(&block)
    enum_for(:ordered_pairs).
      lazy.
      select { |numerator, denominator| numerator.gcd(denominator) == 1 }.
      map { |numerator, denominator| Rational(numerator, denominator) }.
      take(@count).
      each(&block)
  end

  private

  def ordered_pairs
    numerator = 1
    denominator = 1

    loop do
      yield [numerator, denominator]

      numerator += 1

      while numerator > 1
        yield [numerator, denominator]
        numerator -= 1
        denominator += 1
      end

      yield [numerator, denominator]

      denominator += 1

      while denominator > 1
        yield [numerator, denominator]
        denominator -= 1
        numerator += 1
      end
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(count, first: 1, second: 1)
    @first = first
    @second = second
    @count = count
  end

  def each(&block)
    enum_for(:all_numbers).
      lazy.
      take(@count).
      each(&block)
  end

  private

  def all_numbers
    a = @first
    b = @second

    yield a
    yield b

    loop do
      yield a + b
      a, b = b, a + b
    end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(count)
    @count = count
  end

  def each(&block)
    enum_for(:all_primes).
      lazy.
      take(@count).
      each(&block)
  end

  private

  def all_primes
    n = 2

    loop do
      yield n if n.prime?
      n += 1
    end
  end
end

module DrunkenMathematician
  extend self

  def meaningless(n)
    sequence = RationalSequence.new(n)
    primeish, non_primeish = sequence.partition { |r| r.denominator.prime? || r.numerator.prime? }

    primeish.reduce(1, :*) / non_primeish.reduce(1, :*)
  end

  def aimless(n)
    sequence = PrimeSequence.new(n)
    sequence.each_slice(2).map { |a, b| Rational(a, b || 1) }.reduce(:+)
  end

  def worthless(n)
    limit = FibonacciSequence.new(n).to_a.last

    sum = 0

    RationalSequence.new(limit ** 2).take_while do |m|
      sum += m
      sum <= limit
    end
  end
end
