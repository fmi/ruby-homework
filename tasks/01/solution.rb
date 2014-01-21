class Integer
  def prime?
    return false if self < 2
    2.upto(pred).all? { |divisor| remainder(divisor).nonzero? }
  end

  def prime_divisors
    2.upto(abs).select { |divisor| remainder(divisor).zero? and divisor.prime? }
  end

  def times_divisible_by(x)
    return 0 if remainder(x).nonzero?
    div(x).times_divisible_by(x).succ
  end

  def prime_factors
    prime_divisors.map do |prime_divisor|
      [prime_divisor] * times_divisible_by(prime_divisor)
    end.flatten
  end

  def harmonic
    1.upto(self).map(&:reciprocal).reduce(:+) if positive?
  end

  def reciprocal
    1 / to_r
  end

  def positive?
    self > 0
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    Hash[uniq.map { |element| [element, count(element)] }]
  end

  def average
    return 0 if empty?
    reduce(:+).fdiv(length)
  end

  def drop_every(n)
    each_slice(n).map { |slice| slice.take(n - 1) }.reduce(:+) or []
  end

  def combine_with(other)
    common = [length, other.length].min
    excess = self[common...length] + other[common...other.length]
    self[0...common].zip(other[0...common]).flatten(1) + excess
  end
end
