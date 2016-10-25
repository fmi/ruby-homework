def common_digits_count(first_number, second_number)
  (first_number.abs.to_s.chars & second_number.abs.to_s.chars).count
end
