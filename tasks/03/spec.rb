describe 'Fifth task' do
  describe 'RationalSequence' do
    it 'can calculate the first four rational numbers' do
      expect(RationalSequence.new(4).to_a).to eq %w(1/1 2/1 1/2 1/3).map(&:to_r)
    end

    it 'returns an empty array when count is 0' do
      expect(RationalSequence.new(0).to_a).to eq []
    end

    it 'can calculate the first 28 rational numbers' do
      expect(RationalSequence.new(28).to_a).to eq %w(
        1/1 2/1 1/2 1/3 3/1 4/1 3/2 2/3 1/4 1/5 5/1 6/1 5/2 4/3
        3/4 2/5 1/6 1/7 3/5 5/3 7/1 8/1 7/2 5/4 4/5 2/7 1/8 1/9
      ).map(&:to_r)
    end

    it 'is properly enumerable' do
      ones = RationalSequence.new(28).select { |r| r.numerator == 1 }
      expect(ones).to eq %w(1/1 1/2 1/3 1/4 1/5 1/6 1/7 1/8 1/9).map(&:to_r)
    end
  end

  describe 'FibonacciSequence' do
    it 'can return the first two Fibonacci numbers' do
      expect(FibonacciSequence.new(2).to_a).to eq [1, 1]
    end

    it 'can return the first 20 Fibonacci numbers' do
      expect(FibonacciSequence.new(20).to_a).to eq [
        1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597,
        2584, 4181, 6765
      ]
    end

    it 'can be used to calculate the Lucas numbers' do
      expect(FibonacciSequence.new(31, first: 2, second: 1).to_a).to eq [
        2, 1, 3, 4, 7, 11, 18, 29, 47, 76, 123, 199, 322, 521, 843, 1364, 2207,
        3571, 5778, 9349, 15127, 24476, 39603, 64079, 103682, 167761, 271443,
        439204, 710647, 1149851, 1860498
      ]
    end

    it 'is properly enumerable' do
      expect(FibonacciSequence.new(20).select { |x| x.even? }).to eq [
        2, 8, 34, 144, 610, 2584
      ]
    end
  end

  describe 'PrimeSequence' do
    it 'returns an empty array for 0 primes' do
      expect(PrimeSequence.new(0).to_a).to eq []
    end

    it 'can tell which the first two primes are' do
      expect(PrimeSequence.new(2).to_a).to eq [2, 3]
    end

    it 'can tell the first 58 primes' do
      expect(PrimeSequence.new(58).to_a).to eq [
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67,
        71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139,
        149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223,
        227, 229, 233, 239, 241, 251, 257, 263, 269, 271
      ]
    end
  end

  describe 'DrunkenMathematician' do
    describe '#meaningless' do
      it 'can calculate for 0 and 1' do
        expect(DrunkenMathematician.meaningless(0)).to eq 1
        expect(DrunkenMathematician.meaningless(1)).to eq 1
      end

      it 'can calculate for 3' do
        expect(DrunkenMathematician.meaningless(4)).to eq Rational(1, 3)
      end

      it 'can calculate for 42' do
        expect(DrunkenMathematician.meaningless(42)).to eq Rational(1, 11)
      end
    end

    describe '#aimless' do
      it 'can calculate for 3' do
        expect(DrunkenMathematician.aimless(3)).to eq(Rational(2, 3) + Rational(5, 1))
      end

      it 'can calculate for 4' do
        expect(DrunkenMathematician.aimless(4)).to eq(Rational(2, 3) + Rational(5, 7))
      end

      it 'can calculate for 42' do
        expected = '126481765191558862062699751684617707800/6619489496139348390798112786167608259'.to_r
        expect(DrunkenMathematician.aimless(42)).to eq expected
      end
    end

    describe '#worthless' do
      it 'can calculate for 2' do
        expect(DrunkenMathematician.worthless(2)).to eq %w(1/1).map(&:to_r)
      end

      it 'can calculate for 8' do
        expected = %w(1/1 2/1 1/2 1/3 3/1 4/1 3/2 2/3 1/4 1/5 5/1).map(&:to_r)
        expect(DrunkenMathematician.worthless(8)).to eq expected
      end

      it 'can calculate for 15' do
        expect(DrunkenMathematician.worthless(15)).to eq %w(
          1/1 2/1 1/2 1/3 3/1 4/1 3/2 2/3 1/4 1/5 5/1 6/1 5/2 4/3 3/4 2/5 1/6
          1/7 3/5 5/3 7/1 8/1 7/2 5/4 4/5 2/7 1/8 1/9 3/7 7/3 9/1 10/1 9/2 8/3
          7/4 6/5 5/6 4/7 3/8 2/9 1/10 1/11 5/7 7/5 11/1 12/1 11/2 10/3 9/4 8/5
          7/6 6/7 5/8 4/9 3/10 2/11 1/12 1/13 3/11 5/9 9/5 11/3 13/1 14/1 13/2
          11/4 8/7 7/8 4/11 2/13 1/14 1/15 3/13 5/11 7/9 9/7 11/5 13/3 15/1 16/1
          15/2 14/3 13/4 12/5 11/6 10/7 9/8 8/9 7/10 6/11 5/12 4/13 3/14 2/15
          1/16 1/17 5/13 7/11 11/7 13/5 17/1 18/1 17/2 16/3 15/4 14/5 13/6 12/7
          11/8 10/9 9/10 8/11 7/12 6/13 5/14 4/15 3/16 2/17 1/18 1/19 3/17 7/13
          9/11 11/9 13/7 17/3 19/1 20/1 19/2 17/4 16/5 13/8 11/10 10/11 8/13 5/16
          4/17 2/19 1/20 1/21 3/19 5/17 7/15 9/13 13/9 15/7 17/5 19/3 21/1 22/1
          21/2 20/3 19/4 18/5 17/6 16/7 15/8 14/9 13/10 12/11 11/12 10/13 9/14
          8/15 7/16 6/17 5/18 4/19 3/20 2/21 1/22 1/23 5/19 7/17 11/13 13/11 17/7
          19/5 23/1 24/1 23/2 22/3 21/4 19/6 18/7 17/8 16/9 14/11 13/12 12/13
          11/14 9/16 8/17 7/18 6/19 4/21 3/22 2/23 1/24 1/25 3/23 5/21 7/19 9/17
          11/15 15/11 17/9 19/7 21/5 23/3
        ).map(&:to_r)
      end
    end
  end
end
