class String
  def word_wrap(max_line_length)
    split(' ').slice_before(current_line_length: -1) do |word, state|
      state[:current_line_length] += word.length + 1

      if state[:current_line_length] > max_line_length
        state[:current_line_length] = word.length
        true
      else
        false
      end
    end.map { |words| words.join(' ') }
  end
end
