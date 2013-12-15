describe '#longest_sequence' do
  context 'for an empty string' do
    it 'should return an empty Array' do
      ''.longest_sequence.should eq []
    end
  end

  context 'for a string with only one longest sequence' do
    it 'should return only the symbol that it is comprised of' do
      'aab'.longest_sequence.should eq ['a']
      '989899777'.longest_sequence.should eq ['7']
      'I am ...'.longest_sequence.should eq ['.']
      '.....??????&gh'.longest_sequence.should eq ['?']
    end
  end

  context 'for a string with multiple longest sequences' do
    it 'should return an array containing the symbols they are comprised of' do
      'aabb'.longest_sequence.should =~ ['a','b']
      '9898999777'.longest_sequence.should =~ ['7', '9']
      'I    am ....'.longest_sequence.should =~ ['.', ' ']
      '.....??????&ggggggh'.longest_sequence.should =~ ['g', '?']
    end

    context 'comprised of the same symbol' do
      it 'should return an array that contains the symbol only once' do
        'aaabbbaaa'.longest_sequence.should =~ ['a', 'b']
      end
    end

    context 'for a string with a longest sequence of new line symbols' do
      it 'should return an array containing only the new line symbol' do
        "aa\n\n\n".longest_sequence.should =~ ["\n"]
      end
    end
  end
end
