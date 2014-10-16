require_relative 'solution'

describe "series" do
  it "handles fibonacci series" do
    series('fibonacci', 1).should eq 1
    series('fibonacci', 5).should eq 5
    series('fibonacci', 10).should eq 55
    series('fibonacci', 15).should eq 610
    series('fibonacci', 20).should eq 6765
  end

  it "handles lucas series" do
    series('lucas', 1).should eq 2
    series('lucas', 5).should eq 7
    series('lucas', 10).should eq 76
    series('lucas', 15).should eq 843
    series('lucas', 20).should eq 9349
  end

  it "handles summed series" do
    series('summed', 1).should eq 3
    series('summed', 5).should eq 12
    series('summed', 10).should eq 131
    series('summed', 15).should eq 1453
    series('summed', 20).should eq 16114
  end
end
