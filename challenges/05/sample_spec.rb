describe "Enumerable#split_up" do
  let(:numbers_list) { 1.upto(10) }
  let(:numbers_hash) { { one: 1, two: 2, three: 3, four: 4 } }
  let(:pad)          { [:a, :b, :c] }

  it "splits up a collection in slices with step and pad" do
    numbers_list.split_up(length: 2, step: 3, pad: pad).should eq [[1, 2],
                                                                   [4, 5],
                                                                   [7, 8],
                                                                   [10, :a]]

    numbers_hash.split_up(length: 2, step: 3, pad: pad).should eq [[[:one, 1], [:two, 2]],
                                                                   [[:four, 4], :a]]
  end
end
