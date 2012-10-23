describe "Integer#prime_divisors" do
  it "can partition a simple number" do
    10.prime_divisors.should eq [2, 5]
    30.prime_divisors.should eq [2, 3, 5]
    42.prime_divisors.should eq [2, 3, 7]
    4.prime_divisors.should eq [2]
    12.prime_divisors.should eq [2, 3]
  end

  it "works with negative numbers" do
    (-10).prime_divisors.should eq [2, 5]
    (-42).prime_divisors.should eq [2, 3, 7]
  end
end

describe "Range#fizzbuzz" do
  it "it works with the first 100 numbers" do
    (1..100).fizzbuzz.should eq [
      1,     2,     :fizz, 4,     :buzz,     :fizz, 7,     8,     :fizz, :buzz,
      11,    :fizz, 13,    14,    :fizzbuzz, 16,    17,    :fizz, 19,    :buzz,
      :fizz, 22,    23,    :fizz, :buzz,     26,    :fizz, 28,    29,    :fizzbuzz,
      31,    32,    :fizz, 34,    :buzz,     :fizz, 37,    38,    :fizz, :buzz,
      41,    :fizz, 43,    44,    :fizzbuzz, 46,    47,    :fizz, 49,    :buzz,
      :fizz, 52,    53,    :fizz, :buzz,     56,    :fizz, 58,    59,    :fizzbuzz,
      61,    62,    :fizz, 64,    :buzz,     :fizz, 67,    68,    :fizz, :buzz,
      71,    :fizz, 73,    74,    :fizzbuzz, 76,    77,    :fizz, 79,    :buzz,
      :fizz, 82,    83,    :fizz, :buzz,     86,    :fizz, 88,    89,    :fizzbuzz,
      91,    92,    :fizz, 94,    :buzz,     :fizz, 97,    98,    :fizz, :buzz,
    ]
  end

  it "works with tricky ranges" do
    (10...17).fizzbuzz.should eq [:buzz, 11, :fizz, 13, 14, :fizzbuzz, 16]
    (15..15).fizzbuzz.should eq [:fizzbuzz]
    (15...15).fizzbuzz.should eq []
  end
end

describe "Hash#group_values" do
  it "maps each value to an array of keys" do
    {a: 1}.group_values.should eq 1 => [:a]
  end

  it "takes repetitions into account" do
    {a: 1, b: 2, c: 1}.group_values.should eq 1 => [:a, :c], 2 => [:b]
  end
end

describe "Array#densities" do
  it "maps each element to the number of occurences in the original array" do
    [:a, :b, :c].densities.should eq [1, 1, 1]
    [:a, :b, :a].densities.should eq [2, 1, 2]
    [:a, :a, :a].densities.should eq [3, 3, 3]
  end

  it "maps each element to the number of occurences in the original array (again)" do
    [].densities.should eq []
    [:a, :b, :c].densities.should eq [1, 1, 1]
    [:a, :b, :a].densities.should eq [2, 1, 2]
    [:a, :a, :a].densities.should eq [3, 3, 3]
  end
end
