describe "partition" do
  it "returns an array containing partitions of the integer" do
    partition(-42).should eq []
    partition(0).should eq [[0, 0]]

    partition(10).map { |addends| addends.reduce(:+) }.all? { |sum| sum.should eq 10 }
  end

  it "returns the correct number of partitions" do
    partition(5).should have_exactly(3).items
    partition(10).should have_exactly(6).items
  end

  it "does not return duplicate partitions" do
    partitions = partition(10)
    unique_partitions = partitions.uniq { |addends| addends.sort }
    partitions.should have_exactly(unique_partitions.count).items
  end
end
