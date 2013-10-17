describe "homogenize" do
  it "returns array of homogeneous arrays" do
    homogenize([1, :a, 2, :b, 3, :c]).should    =~ [[1, 2, 3], [:a, :b, :c]]
    homogenize([:a, "Jimi", "Kurt", :b]).should =~ [[:a, :b], ["Jimi", "Kurt"]]
  end
end
