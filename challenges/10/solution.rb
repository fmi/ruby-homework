class String
  def longest_sequence
    return [] if empty?
    scan(/(.)(\1*)/).map(&:join).group_by(&:length).max.last.map(&:chr).uniq
  end
end
