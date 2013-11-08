describe "Bitmap" do
  it "renders bytes" do
    expect(Bitmap.new([9, 32], 1).render).to eq <<-ASCII.strip
....#..#
..#.....
    ASCII
  end

  it "supports different palettes" do
    expect(Bitmap.new([13, 2, 5, 1], 2).render(%w(. * x #))).to eq <<-ASCII.strip
..#*...x
..**...*
    ASCII
  end
end
