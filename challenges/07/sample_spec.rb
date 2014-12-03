describe "P" do
  it "could be used with one argument" do
    expect((1..5).map(&P ** 2)).to eq [1, 4, 9, 16, 25]
  end
end
