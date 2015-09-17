describe 'String#word_wrap' do
  it 'reduces the empty string to an empty array' do
    expect(''.word_wrap(2)).to eq []
  end

  it 'reduces whitespace-only strings to an empty array' do
    expect("    \n      ".word_wrap(3)).to eq []
  end

  it 'can split words given exact length' do
    expect('one two'.word_wrap(3)).to eq ['one', 'two']
  end

  it 'correctly counts the whitespace between words' do
    expect('one word n two words'.word_wrap(9)).to eq ['one word', 'n two', 'words']
  end

  it 'can split words given more length' do
    expect('one two'.word_wrap(6)).to eq ['one', 'two']
  end

  it 'splits on the nearest left whitespace' do
    expect('point one two'.word_wrap(8)).to eq ['point', 'one two']
  end

  it 'can split more than once' do
    expect('point line parallelogram cube'.word_wrap(15)).to eq ['point line', 'parallelogram', 'cube']
  end

  it 'is not influenced by leading whitespace' do
    expect("  \n one\nmore string".word_wrap(7)).to eq ['one', 'more', 'string']
  end

  it 'is not influenced by trailing whitespace' do
    expect("one more string \n   ".word_wrap(7)).to eq ['one', 'more', 'string']
  end

  it 'ignores more than one whitespace between lines' do
    expect("one    more   \n        string".word_wrap(7)).to eq ['one', 'more', 'string']
  end

  it 'compacts whitespace inside lines' do
    expect("one   more        string".word_wrap(12)).to eq ['one more', 'string']
  end

  it 'keeps longer lines if it is a single word' do
    expect("one more string".word_wrap(2)).to eq ['one', 'more', 'string']
  end

  it 'splits text with cyrillic correctly' do
    expect("  Мерси   за търпението   и\nура за живота! ".word_wrap(20)).to eq ['Мерси за търпението', 'и ура за живота!']
  end

  it 'splits text with hiragana letters correctly' do
    expect("まつもとさんは Rubyのおとうさん. ".word_wrap(10)).to eq ['まつもとさんは', 'Rubyのおとうさん.']
  end

  it 'allows lines longer than max line length if there is nowhere to break the line' do
    expect('justonelongline here'.word_wrap(5)).to eq ['justonelongline', 'here']
  end
end
