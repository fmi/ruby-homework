KEYPAD = %w(
  1      ABC2  DEF3
  GHI4   JKL5  MNO6
  PQRS7  TUV8  WXYZ9
  *      \ 0   #
)

def button_presses(message)
  message.upcase.chars.map do |character|
    KEYPAD.detect { |button| button.include?(character) }.index(character).succ
  end.reduce(:+)
end
