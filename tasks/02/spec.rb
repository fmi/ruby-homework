describe '#move' do
  let(:snake) { [[2, 2], [2, 3], [2, 4], [2, 5]] }

  it 'moves snake up/right/left/down' do
    expect(move(snake, [0, 1])).to eq([[2, 3], [2, 4], [2, 5], [2, 6]])
    expect(move(snake, [1, 0])).to eq([[2, 3], [2, 4], [2, 5], [3, 5]])
    expect(move(snake, [-1, 0])).to eq([[2, 3], [2, 4], [2, 5], [1, 5]])
    expect(move(snake, [0, -1])).to eq([[2, 3], [2, 4], [2, 5], [2, 4]])
  end

  it 'moves one-position-sized snake' do
    expect(move([[2, 2]], [-1, 0])).to eq([[1, 2]])
  end

  it 'does not mutate the given arguments' do
    direction = [0, 1]
    expect { move(snake, direction) }.not_to change { snake }
    expect { move(snake, direction) }.not_to change { direction }
  end
end

describe '#grow' do
  let(:snake) { [[2, 2], [2, 3], [2, 4], [2, 5]] }

  it 'grows snake up/right/left/down' do
    expect(grow(snake, [0, 1])).to eq([[2, 2], [2, 3], [2, 4], [2, 5], [2, 6]])
    expect(grow(snake, [1, 0])).to eq([[2, 2], [2, 3], [2, 4], [2, 5], [3, 5]])
    expect(grow(snake, [-1, 0])).to eq([[2, 2], [2, 3], [2, 4], [2, 5], [1, 5]])
    expect(grow(snake, [0, -1])).to eq([[2, 2], [2, 3], [2, 4], [2, 5], [2, 4]])
  end

  it 'grows one-position-sized snake' do
    expect(grow([[2, 2]], [-1, 0])).to eq([[2, 2], [1, 2]])
  end

  it 'does not mutate the given arguments' do
    direction = [0, 1]
    expect { grow(snake, direction) }.not_to change { snake }
    expect { grow(snake, direction) }.not_to change { direction }
  end
end

describe '#new_food'do
  let(:snake) { [[0, 1], [1, 1], [2, 1], [2, 2]] }
  let(:food) { [[0, 0], [0, 2], [2, 0]] }
  let(:dimensions) { {width: 3, height: 3} }
  let(:next_food) { new_food(food, snake, dimensions) }

  it 'generates food on empty position' do
    xs, ys = (0...dimensions[:width]).to_a, (0...dimensions[:height]).to_a
    empty_positions = xs.product(ys)

    expect(empty_positions).to include(next_food)
  end

  it 'does not generate food outside of borders (width)' do
    expect(next_food[0]).to be_between(0, dimensions[:width].pred)
  end

  it 'does not generate food outside of borders (height)' do
    expect(next_food[1]).to be_between(0, dimensions[:height].pred)
  end

  it 'does not generate food on position where the snake is' do
    expect(snake).not_to include(next_food)
  end

  it 'does not generate food on position where food is already present' do
    expect(food).not_to include(next_food)
  end

  it 'does not mutate the given arguments' do
    expect { new_food(food, snake, dimensions) }.not_to change { snake }
    expect { new_food(food, snake, dimensions) }.not_to change { food }
    expect { new_food(food, snake, dimensions) }.not_to change { dimensions }
  end
end

describe '#obstacle_ahead?' do
  let(:dimensions) { {width: 10, height: 10} }

  it 'returns true if snake body ahead' do
    expect(
      obstacle_ahead?([[5, 5], [4, 5], [4, 4], [5, 4]], [0, 1], dimensions)
    ).to eq true
  end

  it 'returns true if wall ahead' do
    expect(obstacle_ahead?([[8, 8], [8, 9]], [0, 1], dimensions)).to eq true
  end

  it 'returns false if no obstacle ahead' do
    expect(obstacle_ahead?([[3, 4], [3, 5]], [0, 1], dimensions)).to eq false
  end

  it 'does not mutate the given arguments' do
    snake, direction = [[1, 2], [1, 3]], [0, 1]

    expect { obstacle_ahead?(snake, direction, dimensions) }.not_to change { snake }
    expect { obstacle_ahead?(snake, direction, dimensions) }.not_to change { direction }
    expect { obstacle_ahead?(snake, direction, dimensions) }.not_to change { dimensions }
  end
end

describe '#danger?' do
  let(:dimensions) { {width: 10, height: 10} }

  it 'returns true if obstacle in one turn' do
    expect(danger?([[7, 6], [8, 6], [9, 6]], [1, 0], dimensions)).to eq true
  end

  it 'returns true if obstacle in two turns' do
    expect(danger?([[6, 6], [7, 6], [8, 6]], [1, 0], dimensions)).to eq true
  end

  it 'returns false if obstacle in three turns' do
    expect(danger?([[5, 6], [6, 6], [7, 6]], [1, 0], dimensions)).to eq false
  end

  it 'does not mutate the given arguments' do
    snake, direction = [[1, 2], [1, 3]], [0, 1]

    expect { danger?(snake, direction, dimensions) }.not_to change { snake }
    expect { danger?(snake, direction, dimensions) }.not_to change { direction }
    expect { danger?(snake, direction, dimensions) }.not_to change { dimensions }
  end
end
