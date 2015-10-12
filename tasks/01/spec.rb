describe '#convert_to_bgn' do
  it 'converts usd' do
    expect(convert_to_bgn(1000, :usd)).to eq 1740.8
  end

  it 'converts eur' do
    expect(convert_to_bgn(1000, :eur)).to eq 1955.7
  end

  it 'converts gbp' do
    expect(convert_to_bgn(1000, :gbp)).to eq 2641.5
  end

  it 'converts bgn' do
    expect(convert_to_bgn(333, :bgn)).to eq 333
  end

  it 'rounds to 2 digits after the point' do
    expect(convert_to_bgn(123, :usd)).to eq 214.12
  end
end

describe '#compare_prices' do
  it 'compares prices of the same currency' do
    expect(compare_prices(10, :usd, 13, :usd)).to be < 0
    expect(compare_prices(10, :eur, 10, :eur)).to eq 0
    expect(compare_prices(10, :gbp, 8, :gbp)).to be > 0
  end

  it 'compares usd and bgn' do
    expect(compare_prices(5, :usd, 10, :bgn)).to be < 0
    expect(compare_prices(100, :usd, 174.08, :bgn)).to eq 0
    expect(compare_prices(100, :usd, 10, :bgn)).to be > 0
  end

  it 'compares eur and gbp' do
    expect(compare_prices(5, :usd, 10, :gbp)).to be < 0
    expect(compare_prices(10, :usd, 2, :gbp)).to be > 0
  end
end
