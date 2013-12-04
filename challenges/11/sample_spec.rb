describe "Array#to_proc" do
  it "works for a single element" do
    [:abs].to_proc.call(-42).should eq [42]
  end
end

describe "Hash#to_proc" do
  let(:student) { Class.new { attr_accessor :points, :rank }.new }

  it "sets the properties of the object which correspond to its key value pairs" do
    {points: 0}.to_proc.call(student)
    student.points.should eq 0
  end
end
