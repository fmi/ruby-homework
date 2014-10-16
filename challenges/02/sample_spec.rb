describe 'render_tic_tac_toe_board_to_ascii' do
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
end
