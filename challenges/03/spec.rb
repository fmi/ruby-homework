describe "Object.thread" do
  it "works with multiple operations" do
    42.thread(->(x) { x / 6 }, :succ, ->(x) { [1] * x }, :size).should eq 8

    "Chunky bacon".thread(->(x) { x.sub "Chu", "Ki" }, :split, :count).should eq 2
  end
end
