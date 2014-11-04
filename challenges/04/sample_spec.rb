describe 'remove_duplicates' do
  it 'removes duplicates' do
    expect(remove_duplicates [-2, 12, 33, -2, 42, -2, 4, 8, 4, 13, 12]).
      to eq [-2, 12, 33, 42, 4, 8, 13]
  end
end
