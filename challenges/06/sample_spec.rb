describe "Class.attr_initializer" do

  class Point
    attr_initializer :x, :y
  end

  it "can be used to initialize a Point" do
    expect(Point.new(2, 4).instance_variable_get("@x")).to eq(2)
    expect(Point.new(4, 4.2).instance_variable_get("@y")).to eq(4.2)
  end

  it "can be used to detect wrong number of arguments in initialization" do
    expect { Point.new(2) }.to raise_error(ArgumentError).with_message("wrong number of arguments (1 for 2)")
  end
end
