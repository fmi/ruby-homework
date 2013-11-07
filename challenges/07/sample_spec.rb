describe "Bitmap" do
  it "renders bytes" do
    Bitmap.new([9, 32], 1).render.should eq <<-ASCII.strip
....#..#
..#.....
    ASCII
  end

  it "supports different palettes" do
    Bitmap.new([13, 2, 5, 1], 2).render(%w[. * x #]).should eq <<-ASCII.strip
..#*...x
..**...*
    ASCII
  end
end
