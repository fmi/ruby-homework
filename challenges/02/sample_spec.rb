describe '#ordinalize' do
  it { expect(ordinalize(5)).to eq('5th') }
  it { expect(ordinalize(12)).to eq('12th') }
  it { expect(ordinalize(-11)).to eq('-11th') }
end
