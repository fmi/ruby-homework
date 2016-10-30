describe '#fibonacci_like?' do
  it 'works with fibonacci sequence' do
    expect(fibonacci_like?([0, 1, 1, 2, 3, 5, 8, 13])).to be true
    expect(fibonacci_like?([0, 1, 1, 2, 3, 6, 8, 14])).to be false
  end

  it 'handles different starting numbers' do
    expect(fibonacci_like?([2, 4, 6, 10, 16, 26, 42, 68])).to be true
    expect(fibonacci_like?([1, 4, 6, 10, 16, 26, 42, 68])).to be false
    expect(fibonacci_like?([5, 7, 12, 19, 31, 50, 81])).to be true
    expect(fibonacci_like?([5, 7, 12, 19, 31, 50, 89])).to be false
  end

  it 'handles sequences with negative numbers' do
    expect(fibonacci_like?([-2, -4, -6, -10, -16, -26, -42, -68])).to be true
    expect(fibonacci_like?([-1, -2, -3, -5, -9])).to be false
  end

  it 'works with bigger numbers' do
    sequence = [
      10000000000000000000000000000000000000000000,
      20000000000000000000000000000000000000000000,
      30000000000000000000000000000000000000000000,
      50000000000000000000000000000000000000000000,
      80000000000000000000000000000000000000000000
    ]
    expect(fibonacci_like?(sequence)).to be true
    expect(fibonacci_like?(sequence + [123])).to be false
  end
end
