describe "Class.attr_initializer" do

  class FunctionCall
    attr_initializer :function, :args
    attr_reader     :function, :args
  end

  class Assignment
    attr_initializer :target, :value
  end

  it "can be used for initialization of attributes" do
    expect(FunctionCall.new(:display, [2]).function).to eq(:display)
    expect(FunctionCall.new(:zebra, [4, 5]).instance_variables).to eq([:@function, :@args])
  end

  it "can be used to detect wrong number of arguments in initialization" do
    expect { FunctionCall.new(:fail) }.to raise_error(ArgumentError).with_message("wrong number of arguments (1 for 2)")
    expect { FunctionCall.new(:feature, [2], [3]) }.to raise_error(ArgumentError).with_message("wrong number of arguments (3 for 2)")
  end

  it "doesn't expose attributes with reader/writer macros" do
    expect { Assignment.new(:x, 4).target }.to raise_error(NoMethodError)
  end
end
