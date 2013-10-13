describe "Integer#prime?" do
  it "checks if a number is prime" do
    2.prime?.should eq true
    4.prime?.should eq false
    5.prime?.should eq true
    7.prime?.should eq true
    13.prime?.should eq true
    101.prime?.should eq true
  end
end

describe "Integer#prime_factors" do
  it "constructs an array containing the prime factors in ascending order" do
    5.prime_factors.should eq [5]
    9.prime_factors.should eq [3, 3]
    12.prime_factors.should eq [2, 2, 3]
    35.prime_factors.should eq [5, 7]
    36.prime_factors.should eq [2, 2, 3, 3]
  end
end

describe "Integer#harmonic" do
  it "returns the n-th harmonic number" do
    1.harmonic.should eq 1/1r
    2.harmonic.should eq 3/2r
    10.harmonic.should eq 7381/2520r
    42.harmonic.should eq 12309312989335019/2844937529085600r
  end
end

describe "Integer#digits" do
  it "constructs an array containing the digits of a number" do
    82.digits.should eq [8, 2]
    123345.digits.should eq [1, 2, 3, 3, 4, 5]
  end
end

describe "Array#frequencies" do
  it "returns a map from distinct items to the number of times they appear" do
    [:a, :a, :a].frequencies.should == { :a => 3 }
    [:a, :a, 42, "ZOMG!"].frequencies.should == { :a => 2, 42 => 1, "ZOMG!" => 1 }
  end
end

describe "Array#average" do
  it "calculates the average of the numbers in the array" do
    (1..10).to_a.average.should eq 5.5
    [4, 8, 15, 16, 23, 42].average.should eq 18.0
    [1, 1, 1].average.should eq 1.0
  end
end

describe "Array#drop_every" do
  it "drops every n-th element from an array." do
    (1..10).to_a.drop_every(2).should eq [1, 3, 5, 7, 9]
    [4, 8, 15, 16, 23, 42].drop_every(2).should eq [4, 15, 23]
    [4, 8, 15, 16, 23, 42].drop_every(3).should eq [4, 8, 16, 23]
  end
end

describe "Array#combine_with" do
  it "combines two arrays by alternatingly taking elements" do
    [:a, :b, :c].combine_with([1, 2, 3]).should eq [:a, 1, :b, 2, :c, 3]
    [:a, :b, :c].combine_with([]).should eq [:a, :b, :c]
    [1, 2, 3, 4, 5].combine_with([:a, :b, :c]).should eq [1, :a, 2, :b, 3, :c, 4, 5]
    [].combine_with([]).should eq []
    [].combine_with([:baba]).should eq [:baba]
    [1, 2, 3, 4, 5].combine_with([:a, :b, :c, 5, 6, 7, 8]).should eq [1, :a, 2, :b, 3, :c, 4, 5, 5, 6, 7, 8]
  end
end
