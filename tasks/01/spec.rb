describe "Integer#prime?" do
  it "checks if a number is prime" do
    -13.prime?.should eq false
    0.prime?.should   eq false
    1.prime?.should   eq false
    2.prime?.should   eq true
    4.prime?.should   eq false
    5.prime?.should   eq true
    13.prime?.should  eq true
    27.prime?.should  eq false
    97.prime?.should  eq true
    144.prime?.should eq false
    401.prime?.should eq true
  end
end

describe "Integer#prime_factors" do
  it "constructs an array containing the prime factors in ascending order" do
    360.prime_factors.should eq [2, 2, 2, 3, 3, 5]
    42.prime_factors.should  eq [2, 3, 7]
    4.prime_factors.should   eq [2, 2]
    61.prime_factors.should  eq [61]
    738.prime_factors.should eq [2, 3, 3, 41]
  end

  it "works with negative numbers" do
    (-4).prime_factors.should   eq [2, 2]
    (-61).prime_factors.should  eq [61]
    (-738).prime_factors.should eq [2, 3, 3, 41]
  end
end

describe "Integer#harmonic" do
  it "returns the n-th harmonic number" do
    1.harmonic.should  eq 1
    2.harmonic.should  eq 3/2r
    10.harmonic.should eq 7381/2520r
    42.harmonic.should eq 12309312989335019/2844937529085600r
  end
end

describe "Integer#digits" do
  it "constructs an array containing the digits of a number" do
    0.digits.should      eq [0]
    33.digits.should     eq [3, 3]
    42.digits.should     eq [4, 2]
    123345.digits.should eq [1, 2, 3, 3, 4, 5]
  end

  it "works with negative numbers" do
    (-33).digits.should     eq [3, 3]
    (-42).digits.should     eq [4, 2]
    (-123345).digits.should eq [1, 2, 3, 3, 4, 5]
  end
end

describe "Array#frequencies" do
  it "returns a map from distinct items to the number of times they appear" do
    [].frequencies.should                    == {}
    [:a, :a, :a].frequencies.should          == { :a => 3 }
    [:a, :b, :c].frequencies.should          == { :a => 1, :b => 1, :c => 1 }
    [1, 2, :c, 1, 1].frequencies.should      == { 1 => 3, 2 => 1, :c => 1 }
    [:a, :a, 42, "ZOMG!"].frequencies.should == { :a => 2, 42 => 1, "ZOMG!" => 1 }
  end

  it "doesn't change the array" do
    array = [1, 2, :c, 1, 1]
    expect { array.frequencies }.to_not change { array }
  end
end

describe "Array#average" do
  it "calculates the average of the numbers in the array" do
    [42].average.should                   eq 42
    [4, 8, 15, 16, 23, 42].average.should eq 18.0
    [1, 2, 3, -1, -2, -3].average.should  eq 0.0
    (1..10).to_a.average.should           eq 5.5
  end

  it "doesn't change the array" do
    array = (1..10).to_a
    expect { array.average }.to_not change { array }
  end
end

describe "Array#drop_every" do
  it "drops every n-th element from an array." do
    [].drop_every(2).should eq []
    [42].drop_every(2).should eq [42]
    (1..10).to_a.drop_every(2).should eq [1, 3, 5, 7, 9]
    (1..10).to_a.drop_every(3).should eq [1, 2, 4, 5, 7, 8, 10]
    (1..10).to_a.drop_every(4).should eq [1, 2, 3, 5, 6, 7, 9, 10]
    [4, 8, 15, 16, 23, 42].drop_every(3).should eq [4, 8, 16, 23]
  end

  it "doesn't change the array" do
    array = (1..10).to_a
    expect { array.drop_every(3) }.to_not change { array }
  end
end

describe "Array#combine_with" do
  it "combines two arrays by alternatingly taking elements" do
    [].combine_with([]).should                          eq []
    [].combine_with([1, 2, 3]).should                   eq [1, 2, 3]
    [:a, :b, :c].combine_with([]).should                eq [:a, :b, :c]
    [:a, :b, :c].combine_with([1, 2, 3]).should         eq [:a, 1, :b, 2, :c, 3]
    [1, 2, 3].combine_with([:a, :b, :c, :d, :e]).should eq [1, :a, 2, :b, 3, :c, :d, :e]
    [1, 2, 3, 4, 5].combine_with([:a, :b, :c]).should   eq [1, :a, 2, :b, 3, :c, 4, 5]
    [:a, :b, :c].combine_with([1, nil, 3]).should       eq [:a, 1, :b, nil, :c, 3]
  end

  it "doesn't change the array" do
    array = [:a, :b, :c]
    expect { array.combine_with [1, 2, 3] }.to_not change { array }
  end
end
