describe '#common_digits_count' do
  it 'works for the simple cases' do
    expect(common_digits_count(123, 321)).to eq 3
    expect(common_digits_count(1123, 456)).to eq 0
  end

  it 'avoids counting the same digit twice' do
    expect(common_digits_count(121212, 1111222234)).to eq 2
    expect(common_digits_count(1234567890, 987666666)).to eq 4
  end

  it 'handles negative numbers' do
    expect(common_digits_count(-887, -188889)).to eq 1
    expect(common_digits_count(2358, -235)).to eq 3
  end
end
