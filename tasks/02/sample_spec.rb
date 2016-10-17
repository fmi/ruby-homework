describe 'Hash#fetch_deep' do
  it 'can look up simple values' do
    input = {meal: 'musaka'}

    expect(input.fetch_deep('meal')).to eq 'musaka'
  end
end

describe 'Hash#reshape' do
  it 'can rename fields' do
    input = {name: 'Georgi'}
    shape = {first_name: 'name'}
    output = {first_name: 'Georgi'}

    expect(input.reshape(shape)).to eq output
  end
end

describe 'Array#reshape' do
  it 'can rename fields in each element' do
    input = [
      {item: 'musaka'}
    ]

    shape = {meal: 'item'}

    expect(input.reshape(shape)).to eq [
      {meal: 'musaka'}
    ]
  end
end
