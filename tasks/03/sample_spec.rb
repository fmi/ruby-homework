describe 'Third task' do
  describe RationalSequence do
    it 'can calculate the first rational number' do
      expect(RationalSequence.new(1).to_a).to eq ['1/1'.to_r]
    end
  end

  describe FibonacciSequence do
    it 'can calculate the first Fibonacci number' do
      expect(FibonacciSequence.new(1).to_a).to eq [1]
    end
  end

  describe PrimeSequence do
    it 'can calculate the first prime (and it is not Optimus)' do
      expect(PrimeSequence.new(1).to_a).to eq [2]
    end
  end

  describe DrunkenMathematician do
    it 'is drunk' do
      expect(->_{_%_}["->_{_%%_}[%p]"]).to eq '->_{_%_}["->_{_%%_}[%p]"]'
    end

    describe '#meaningless' do
      it 'can calculate for 1' do
        expect(DrunkenMathematician.meaningless(1)).to eq Rational(1, 1)
      end
    end

    describe '#aimless' do
      it 'can calculate for 2' do
        expect(DrunkenMathematician.aimless(2)).to eq '2/3'.to_r
      end
    end

    describe '#worthless' do
      it 'can calculate for 1' do
        expect(DrunkenMathematician.worthless(1)).to eq %w(1/1).map(&:to_r)
      end
    end
  end
end
