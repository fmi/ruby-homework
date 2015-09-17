describe 'remove_duplicates' do
  before :each do
    expect_any_instance_of(Array).to_not receive(:uniq)
    expect_any_instance_of(Array).to_not receive(:uniq!)
  end

  it 'returns an empty array when empty array is given' do
    expect(remove_duplicates []).to eq []
  end

  it 'handles array with one element' do
    expect(remove_duplicates [42]).to eq [42]
  end

  it 'handles array with no duplicates' do
    expect(remove_duplicates [4, 8, 15, 16, 23, 42]).to eq [4, 8, 15, 16, 23, 42]
  end

  it 'removes duplicates and preserves the order' do
    expect(remove_duplicates [42, 2, -2, 4, 5, 5, 7, 33, 42, 5, 14, -2]).
      to eq [42, 2, -2, 4, 5, 7, 33, 14]
  end
end
