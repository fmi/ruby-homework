def partition(number)
  0.upto(number / 2).map { |addend| [number - addend, addend] }
end
