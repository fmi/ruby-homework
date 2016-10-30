def fibonacci_like?(sequence)
  sequence.each_cons(3).all? { |first, second, third| first + second == third }
end
