def fibonacci(number)
  number <= 2 ? 1 : fibonacci(number - 1) + fibonacci(number - 2)
end

def lucas(number)
  if number == 1
    2
  elsif number == 2
    1
  else
    lucas(number - 1) + lucas(number - 2)
  end
end

def series(sequence, number)
  if sequence == 'fibonacci'
    fibonacci(number)
  elsif sequence == 'lucas'
    lucas(number)
  else
    fibonacci(number) + lucas(number)
  end
end