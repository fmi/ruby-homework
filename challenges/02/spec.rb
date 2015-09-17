describe 'render_tic_tac_toe_board_to_ascii' do
  it 'renders a blank board for an array with nils' do
    expect(render_tic_tac_toe_board_to_ascii([
      nil, nil, nil,
      nil, nil, nil,
      nil, nil, nil,
    ])).to eq(<<BOARD.chomp)
|   |   |   |
|   |   |   |
|   |   |   |
BOARD
  end

  it 'renders boards with x and o markers' do
    expect(render_tic_tac_toe_board_to_ascii([
      :x,  nil, nil,
      :o,  :x,  nil,
      :x,  :o,  :o,
    ])).to eq(<<BOARD.chomp)
| x |   |   |
| o | x |   |
| x | o | o |
BOARD
  end

  it 'renders boards with all x-es' do
    expect(render_tic_tac_toe_board_to_ascii([
      :x,  :x,  :x,
      :x,  :x,  :x,
      :x,  :x,  :x,
    ])).to eq(<<BOARD.chomp)
| x | x | x |
| x | x | x |
| x | x | x |
BOARD
  end

  it 'renders boards with all o-s' do
    expect(render_tic_tac_toe_board_to_ascii([
      :o,  :o,  :o,
      :o,  :o,  :o,
      :o,  :o,  :o,
    ])).to eq(<<BOARD.chomp)
| o | o | o |
| o | o | o |
| o | o | o |
BOARD
  end
end
