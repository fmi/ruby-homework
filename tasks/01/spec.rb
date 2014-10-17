require_relative 'solution'

describe "series" do
  it "handles fibonacci series for base cases" do
    series('fibonacci', 1).should eq 1
    series('fibonacci', 2).should eq 1
  end

  it "handles fibonacci series for odd numbers" do
    series('fibonacci', 7).should eq 13
    series('fibonacci', 9).should eq 34
  end

  it "handles fibonacci series for even numbers" do
    series('fibonacci', 8).should eq 21
    series('fibonacci', 10).should eq 55
  end

  it "handles fibonacci series for bigger numbers" do
    series('fibonacci', 15).should eq 610
    series('fibonacci', 20).should eq 6765
  end

  it "handles lucas series for base cases" do
    series('lucas', 1).should eq 2
    series('lucas', 2).should eq 1
  end

  it "handles lucas series for odd numbers" do
    series('lucas', 7).should eq 18
    series('lucas', 9).should eq 47
  end

  it "handles lucas series for even numbers" do
    series('lucas', 8).should eq 29
    series('lucas', 10).should eq 76
  end

  it "handles lucas series for bigger numbers" do
    series('lucas', 15).should eq 843
    series('lucas', 20).should eq 9349
  end

  it "handles summed series for base cases" do
    series('summed', 1).should eq 3
    series('summed', 2).should eq 2
  end

  it "handles summed series for odd numbers" do
    series('summed', 7).should eq 31
    series('summed', 9).should eq 81
  end

  it "handles summed series for even numbers" do
    series('summed', 8).should eq 50
    series('summed', 10).should eq 131
  end

  it "handles summed series for bigger numbers" do
    series('summed', 15).should eq 1453
    series('summed', 20).should eq 16114
  end
end