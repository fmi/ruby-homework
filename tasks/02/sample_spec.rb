describe '#move' do
  it 'moves snake right' do
    expect(move([[4, 5], [4, 6], [5, 6], [5, 7]], [0, 1])).
      to eq [[4, 6], [5, 6], [5, 7], [5, 8]]
  end
end

describe '#grow' do
  it 'grows snake right' do
    expect(grow([[4, 6], [5, 6], [5, 7]], [0, 1])).
      to eq [[4, 6], [5, 6], [5, 7], [5, 8]]
  end
end

describe '#new_food' do
  it 'generates new food' do
    expect(new_food([[0, 0]], [[0, 1], [1, 1]], {width: 2, height: 2})).
      to eq [1, 0]
  end
end

describe '#obstacle_ahead?' do
  it 'returns true if wall in front of snake' do
    expect(obstacle_ahead?([[3, 8], [3, 9]], [0, 1], {width: 10, height: 10})).
      to eq true
  end
end

describe '#danger?' do
  it 'returns true if position in front of snake is a wall' do
    expect(danger?([[3, 8], [3, 9]], [0, 1], {width: 10, height: 10})).to eq true
  end
end
