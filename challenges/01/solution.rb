def zig_zag(n)
  1.upto(n ** 2).each_slice(n).each_with_index.map do |row, index|
    index.even? ? row : row.reverse
  end
end
