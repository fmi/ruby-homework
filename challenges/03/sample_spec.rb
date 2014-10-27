describe 'String#word_wrap' do
  it 'reduces the empty string to an empty array' do
    expect(''.word_wrap(2)).to eq []
  end

  it 'can split words given exact length' do
    expect('one two'.word_wrap(3)).to eq ['one', 'two']
  end
end
