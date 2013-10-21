class Integer
  def prime?
    return false if self < 2
    2.upto(pred).all? { |divisor| remainder(divisor).nonzero? }
  end

  def prime_factors
    return [] if self == 1
    factor = (2..abs).find { |x| remainder(x).zero? }
    [factor] + (abs / factor).prime_factors
  end

  def harmonic
    (1..self).map(&:reciprocal).reduce(:+) if positive?
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
    each_with_object Hash.new(0) do |value, result|
      result[value] += 1
    end
  end

  def average
    reduce(:+) / length.to_f unless empty?
  end

  def drop_every(n)
    each_slice(n).map { |slice| slice.take(n - 1) }.reduce(:+) or []
  end

  def combine_with(other)
    longer, shorter = self.length > other.length ? [self, other] : [other, self]

    combined = take(shorter.length).zip(other.take(shorter.length)).flatten
    rest     = longer.drop(shorter.length)

    combined + rest
  end
end
