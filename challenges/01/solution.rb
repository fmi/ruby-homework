def format_string(string, width)
  string.strip.squeeze(' ').upcase.center(width)
end
