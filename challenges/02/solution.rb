def ordinalize(number)
  absolute_value = number.abs
  suffix =
    if (11..13).cover?(absolute_value % 100)
      'th'
    else
      case absolute_value % 10
      when 1 then 'st'
      when 2 then 'nd'
      when 3 then 'rd'
      else        'th'
      end
    end

  "#{number}#{suffix}"
end
