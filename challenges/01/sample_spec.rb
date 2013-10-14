describe "zig_zag" do
  it "works for n = 1" do
    zig_zag(1).should == [[1]]
  end

  it "works for n = 2" do
    zig_zag(2).should == [[1, 2], [4, 3]]
  end
end
