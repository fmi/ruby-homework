class String
  def anagrams(words, &block)
    frequencies = -> word do
      word.chars.map { |char| [char, word.count(char)] }.to_h
    end

    words.lazy.select do |word|
      frequencies.call(word.downcase) == frequencies.call(downcase) and
      word.downcase != downcase
    end.each(&block)
  end
end
