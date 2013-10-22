describe "Object.thread" do
  it "works with lambdas" do
    42.thread(->(x) { x / 2 }, ->(x) { x - 1 }).should eq 20
  end

  it "works with symbols" do
    42.thread(:succ, :odd?).should eq true
  end

  it "works with multiple operations" do
    "42".thread(:to_i, ->(x) { x / 6 }, :succ, ->(x) { x ** 2 }).should eq 64
  end
end
