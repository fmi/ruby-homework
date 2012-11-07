require 'treetop'
Treetop.load 'parser'

describe "Expressions" do
  def parse(input)
    ArithmeticParser.new.parse(input).to_sexp
  end

  def build(string)
    Expr.build parse(string)
  end

  def evaluate(string, env = {})
    build(string).evaluate(env)
  end

  def simplify(string)
    build(string).simplify
  end

  def derive(string)
    build(string).derive(:x)
  end

  it "supports evaluation" do
    evaluate('x + y', x: 1, y: 2).should eq 3
    evaluate('sin(0)').should eq 0
    evaluate("cos(#{Math::PI / 2})").should be_within(0.0001).of(0)
    evaluate('-2').should eq(-2)
  end

  it "supports comparison" do
    build('1 + 2 * 3').should eq build('1 + 2 * 3')
    build('x + 2').should_not eq build('2 + x')
  end

  it "supports simplification" do
    simplify('x + 0').should eq build('x')
    simplify('0 + x').should eq build('x')
    simplify('0 * x').should eq build('0')

    simplify('x * 0').should eq build('0')
    simplify('x * 1').should eq build('x')
    simplify('1 * x').should eq build('x')
    simplify('1 * x').should eq build('x')

    simplify('2 * (x * 0)').should eq build('0')

    simplify('0 + 1 * (3 * 0)').should eq build('0')
  end

  it "can derive expressions" do
    derive('x').should eq build('1')
    derive('y').should eq build('0')

    derive('x + x').should eq build('2')
    derive('x * x').should eq build('x + x')
    derive('x * x * x').should eq build('x * x + x * (x + x)')
  end
end
