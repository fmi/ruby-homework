describe "partition" do
  it "returns an array containing partitions of the integer" do
    partition(0).should eq [[0, 0]]
    partition(3).map { |addends| addends.reduce(:+) }.all? { |sum| sum.should eq 3 }
  end
end
