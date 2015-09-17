def remove_duplicates(integers)
  integers.each_with_object([]) do |integer, uniques|
    uniques << integer unless uniques.include? integer
  end
end
