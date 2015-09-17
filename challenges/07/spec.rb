describe "P" do
  it "could be used with one argument" do
    expect((1..5).map(&P ** 2)).to eq [1, 4, 9, 16, 25]
  end

  it "could be used with blocks" do
    expect([["some", "lists"], ["of", "words"]].map(&P.map(&:length))).to eq [[4, 5], [2, 5]]
  end

  it "could be used without method calls" do
    expect(["this", "should", "remain", "the", "same"].map(&P)).to eq ["this", "should", "remain", "the", "same"]
  end

  it "could be used with methods from BasicObject" do
    expect((1..5).select(&P == 2)).to eq [2]
  end

  it "could be really, really ugly but still works" do
    expect(["some", "scary", "meta", "stuff"].map(&P.__send__(:length))).to eq [4, 5, 4, 5]
  end
end
