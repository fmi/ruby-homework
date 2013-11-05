describe Polynomial do
  it "formats correctly a simple polynomial" do
    expect(Polynomial.new([1, 0, 2]).to_s).to eq 'x^2 + 2'
  end

  it "formats correctly a polynomial which contains negative and zero coefficients" do
    expect(Polynomial.new([-3, -4, 1, 0, 6]).to_s).to eq '- 3x^4 - 4x^3 + x^2 + 6'
  end

  it "formats correctly a polynomial containing zeros only" do
    expect(Polynomial.new([0, 0, 0, 0, 0]).to_s).to eq '0'
  end

  it "formats correctly a polynomial containing x^1" do
    expect(Polynomial.new([3, -2, 1, 0]).to_s).to eq '3x^3 - 2x^2 + x'
  end

  it "raises ArgumentError if not initiated with an array" do
    -> { Polynomial.new("-3, -4, 1, 0, 6").to_s }.should raise_error ArgumentError
  end
end