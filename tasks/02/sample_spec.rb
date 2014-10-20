describe NumberSet do
  it 'contains multiple numbers' do
    numbers = NumberSet.new
    numbers << Rational(22, 7)
    numbers << 42
    numbers << 3.14
    expect(numbers.size).to eq 3
  end

  it 'contains only unique numbers' do
    numbers = NumberSet.new
    numbers << 42
    numbers << 42
    expect(numbers.size).to eq 1
  end

  it 'can combine two filters with "and" rule' do
    numbers = NumberSet.new
    [Rational(-5, 2), 7.6, 0].each do |number|
      numbers << number
    end
    filtered_numbers = numbers[SignFilter.new(:non_negative) & Filter.new { |number| number != 0 }]
    expect(filtered_numbers.size).to eq 1
    expect(filtered_numbers).to include 7.6
    expect(filtered_numbers).not_to include Rational(-5, 2), 0
  end
end
