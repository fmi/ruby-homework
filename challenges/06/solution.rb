class Polynomial
  def initialize(coefficients)
    @coefficients = coefficients
  end

  def to_s
    return '0' if @coefficients.all?(&:zero?)

    @coefficients.each_with_index.select do |coefficient, _|
      coefficient.nonzero?
    end.map do |coefficient, index|
      format_coefficent(coefficient) + format_power(@coefficients.count - index - 1)
    end.join(' ').sub(/^\+ /, '')
  end

  private

  def format_coefficent(coefficient)
    ((coefficient >= 0) ? '+ ' : '- ') + ((coefficient.abs == 1) ? '' : coefficient.abs.to_s)
  end

  def format_power(power)
    ['', 'x'].fetch(power, "x^#{power}")
  end
end
