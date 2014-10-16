def generic_series(n, first_value, second_value)
  return first_value if n == 1
  return second_value if n == 2

  generic_series(n - 1, first_value, second_value) +
  generic_series(n - 2, first_value, second_value)
end

def series(type, n)
  case type
  when 'fibonacci' then generic_series(n, 1, 1)
  when 'lucas'     then generic_series(n, 2, 1)
  when 'summed'    then series('fibonacci', n) + series('lucas', n)
  end
end
