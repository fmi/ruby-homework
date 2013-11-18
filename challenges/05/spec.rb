describe "Enumerable#split_up" do
  let(:numbers_list) { 1.upto(10).to_a }
  let(:numbers_hash) { { one: 1, two: 2, three: 3, four: 4 } }
  let(:pad)          { [:a, :b, :c] }

  it "iterates a block (if given) for each slice" do
    slices = []
    numbers_list.split_up(length: 2, step: 3, pad: pad) { |slice| slices << slice }
    slices.should eq [[1, 2], [4, 5], [7, 8], [10, :a]]
  end

  it "returns the processed input when a block is passed" do
    numbers_list.split_up(length: 2, step: 3, pad: pad) {}.should eq [[1, 2],
                                                                      [4, 5],
                                                                      [7, 8],
                                                                      [10, :a]]
  end

  it "requires the length: keyword argument" do
    expect { numbers_list.split_up }.to raise_error(ArgumentError)
  end

  it "does not mutate the input enumerable" do
    numbers_list.split_up(length: 2, step: 3, pad: [:a])
    numbers_list.should eq [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  end

  it "splits up a collection in slices" do
    numbers_list.split_up(length: 3).should eq [[1, 2, 3],
                                                [4, 5, 6],
                                                [7, 8, 9],
                                                [10]]

    numbers_list.split_up(length: 2).should eq [[1, 2],
                                                [3, 4],
                                                [5, 6],
                                                [7, 8],
                                                [9, 10]]

    numbers_hash.split_up(length: 2).should eq [[[:one, 1], [:two, 2]],
                                                [[:three, 3], [:four, 4]]]
  end

  it "splits up a collection in slices with step" do
    numbers_list.split_up(length: 2, step: 3).should eq [[1, 2],
                                                         [4, 5],
                                                         [7, 8],
                                                         [10]]

    numbers_hash.split_up(length: 2, step: 3).should eq [[[:one, 1], [:two, 2]],
                                                         [[:four, 4]]]
  end

  it "splits up a collection in slices with pad" do
    numbers_list.split_up(length: 3, pad: pad).should eq [[1, 2, 3],
                                                          [4, 5, 6],
                                                          [7, 8, 9],
                                                          [10, :a, :b]]

    numbers_hash.split_up(length: 3, pad: pad).should eq [[[:one, 1], [:two, 2], [:three, 3]],
                                                          [[:four, 4], :a, :b]]
  end

  it "splits up a collection in slices with step and pad" do
    numbers_list.split_up(length: 2, step: 3, pad: pad).should eq [[1, 2],
                                                                   [4, 5],
                                                                   [7, 8],
                                                                   [10, :a]]

    numbers_hash.split_up(length: 2, step: 3, pad: pad).should eq [[[:one, 1], [:two, 2]],
                                                                   [[:four, 4], :a]]
  end

  it "leaves the last partition with less than n items if not enough padding elements" do
    not_enough = [:not_enough]
    numbers_list.split_up(length: 3, pad: not_enough).should eq [[1, 2, 3],
                                                                 [4, 5, 6],
                                                                 [7, 8, 9],
                                                                 [10, :not_enough]]
  end
end
