describe "String#anagrams" do
  def anagrams_for(word, amongst:, are:)
    expect(word.anagrams(amongst)).to match_array are
  end

  it "returns empty array when there are no matches" do
    anagrams_for "diaper", amongst: ["hello", "world", "zombies", "pants"], are: []
  end

  it "finds simple anagrams" do
    anagrams_for "ant", amongst: ["tan", "stand", "at"], are: ["tan"]
  end

  it "does not confuse different duplicates" do
    anagrams_for "galea", amongst: ["eagle"], are: []
  end

  it "eliminates anagram subsets" do
    anagrams_for "good", amongst: ["dog", "goody"], are: []
  end

  it "finds multiple anagrams" do
    anagrams_for "allergy", amongst: ["gallery", "ballerina", "regally",
                                      "clergy", "largely", "leading"],
                            are: ["gallery", "regally", "largely"]
  end

  it "finds case insensitive anagrams" do
    anagrams_for "Orchestra", amongst: ["cashregister", "Carthorse", "radishes"],
                              are: ["Carthorse"]
  end

  it "does not return the receiver word because it is not anagram for itself" do
    anagrams_for "banana", amongst: ["banana"], are: []
  end

  it "does not return the receiver word even if it is in different case" do
    anagrams_for "banana", amongst: ["BANANA"], are: []
  end
end
