def render_tic_tac_toe_board_to_ascii(board)
  board.each_slice(3).map do |row|
    render_tic_tac_toe_row_to_ascii(row)
  end.join("\n")
end

def render_tic_tac_toe_row_to_ascii(row)
  cells = row.map { |cell| "#{cell || ' '}" }

  '| ' + cells.join(' | ') + ' |'
end
