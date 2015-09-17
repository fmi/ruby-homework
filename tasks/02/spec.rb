describe NumberSet do
  it 'can store integers' do
    can_store 42
  end

  it 'can store floating point numbers' do
    can_store 3.14
  end

  it 'can store complex numbers' do
    can_store 0.3+2i
  end

  it 'can store rational numbers' do
    can_store Rational(22, 7)
  end

  it 'can compare numbers of different types' do
    can_store Rational(4, 2), and_get_it_as: 2
  end

  it 'starts as empty collection' do
    numbers = NumberSet.new
    expect(numbers.size).to eq 0
  end

  it 'contains multiple numbers' do
    numbers = NumberSet.new
    numbers << Rational(22, 7)
    numbers << 42
    numbers << 3.14
    expect(numbers.size).to eq 3
  end

  it 'contains only unique numbers' do
    numbers = NumberSet.new
    numbers << Rational(22, 2)
    numbers << 11
    expect(numbers.size).to eq 1
  end

  it 'can filter by complex type' do
    can_filter [0.3+2i, 3.14, 11], using: TypeFilter.new(:complex),
                                   expecting: [0.3+2i],
                                   not_expecting: [3.14, 11]
  end

  it 'can filter by integer type' do
    can_filter [Rational(5, 2), 8.0, 7, Rational(9, 1)], using: TypeFilter.new(:integer),
                                                         expecting: [7],
                                                         not_expecting: [Rational(5, 2), 8.0, Rational(9, 1)]
  end

  it 'can filter by real type' do
    can_filter [Rational(5, 2), 8.3, 7], using: TypeFilter.new(:real),
                                         expecting: [2.5, 8.3],
                                         not_expecting: [7]
  end

  it 'can filter by custom filter' do
    can_filter [Rational(5, 2), 7.6, 5], using: Filter.new { |number| number > 4 },
                                         expecting: [7.6, 5],
                                         not_expecting: [Rational(5, 2)]
  end

  it 'can filter positive numbers' do
    can_filter [Rational(-5, 2), 7.6, 0], using: SignFilter.new(:positive),
                                          expecting: [7.6],
                                          not_expecting: [Rational(-5, 2), 0]
  end

  it 'can filter non-positive numbers' do
    can_filter [Rational(-5, 2), 7.6, 0], using: SignFilter.new(:non_positive),
                                          expecting: [-2.5, 0],
                                          not_expecting: [7.6]
  end

  it 'can filter negative numbers' do
    can_filter [Rational(-5, 2), 7.6, 0], using: SignFilter.new(:negative),
                                          expecting: [-2.5],
                                          not_expecting: [7.6, 0]
  end

  it 'can filter non-negative numbers' do
    can_filter [Rational(-5, 2), 7.6, 0], using: SignFilter.new(:non_negative),
                                          expecting: [7.6, 0],
                                          not_expecting: [Rational(-5, 2)]
  end

  it 'can combine two filters with "and" rule' do
    filter = SignFilter.new(:non_negative) & Filter.new { |number| number != 0 }
    can_filter [Rational(-5, 2), 7.6, 0], using: filter,
                                          expecting: [7.6],
                                          not_expecting: [Rational(-5, 2), 0]
  end

  it 'can combine two filters with "or" rule' do
    filter = Filter.new { |number| number % 2 == 0 } | Filter.new { |number| number > 5 }
    can_filter [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], using: filter,
                                                expecting: [2, 4, 6, 7, 8, 9, 10],
                                                not_expecting: [1, 3, 5]
  end

  it 'can combine multiple filters with "and" rule' do
    non_negative  = SignFilter.new(:non_negative)
    non_zero      = Filter.new { |number| number != 0 }
    mod_3_is_zero = Filter.new { |number| number % 3 == 0 }
    filter        = non_negative & non_zero & mod_3_is_zero
    can_filter [-200, -3, -1, 0, 1, 3, 4, 9, 10, 11, 24, 77, 99, 100, 101, 1337, 9000], using: filter,
                                          expecting: [3, 9, 24, 99, 9000],
                                          not_expecting: [-200, -3, -1, 0, 1, 4, 10, 11, 77, 100, 101, 1337]
  end

  it 'can combine multiple filters with "or" rule' do
    even          = Filter.new(&:even?)
    negative      = SignFilter.new(:negative)
    more_than_100 = Filter.new { |number| number > 100 }
    filter        = even | negative | more_than_100
    can_filter [-200, -3, -1, 0, 1, 3, 4, 9, 10, 11, 24, 77, 99, 100, 101, 1337, 9000], using: filter,
                                          expecting: [-200, -3, -1, 0, 4, 10, 24, 100, 101, 1337, 9000],
                                          not_expecting: [1, 3, 9, 11, 77, 99]
  end

  it 'can combine multiple filters with "and" and "or" rules' do
    even          = Filter.new(&:even?)
    negative      = SignFilter.new(:negative)
    mod_3_is_zero = Filter.new { |number| number % 3 == 0 }
    filter        = even & negative | mod_3_is_zero
    can_filter [-200, -3, -1, 0, 1, 3, 4, 9, 10, 11, 24, 77, 99, 100, 101, 1337, 9000], using: filter,
                                          expecting: [-200, -3, 0, 3, 9, 24, 99, 9000],
                                          not_expecting: [-1, 1, 4, 10, 11, 77, 100, 101, 1337]
  end

  it 'can combine multiple filters with "and", "or" and parenthesis' do
    even          = Filter.new(&:even?)
    negative      = SignFilter.new(:negative)
    mod_3_is_zero = Filter.new { |number| number % 3 == 0 }
    filter        = even & (negative | mod_3_is_zero)
    can_filter [-200, -3, -1, 0, 1, 3, 4, 9, 10, 11, 24, 77, 99, 100, 101, 1337, 9000], using: filter,
                                          expecting: [-200, 0, 24, 9000],
                                          not_expecting: [-3, -1, 1, 3, 4, 9, 10, 11, 77, 99, 100, 101, 1337]
  end

  it 'is enumerable' do
    numbers = NumberSet.new
    [Rational(5, 2), 8.0, 7, Rational(9, 1)].each do |number|
      numbers << number
    end
    expect(numbers).to be_a Enumerable

    values = []
    numbers.each do |number|
      values << number
    end
    expect(values.size).to eq [Rational(5, 2), 8, 7, 9].size
    expect(values).to include Rational(5, 2), 8, 7, 9
  end

  it 'returns enumerable of set\'s contents if no block is given to each' do
    numbers = NumberSet.new
    [1, 3, 5].each do |number|
      numbers << number
    end
    expect(numbers.each.to_a.size).to eq [1, 3, 5].size
    expect(numbers.each).to include 1, 3, 5
  end

  def can_store(number, and_get_it_as: number)
    numbers = NumberSet.new
    numbers << number
    expect(numbers).to include and_get_it_as
  end

  def can_filter(values, using:, expecting:, not_expecting:)
    numbers = NumberSet.new
    values.each do |number|
      numbers << number
    end
    filtered_numbers = numbers[using]
    expect(filtered_numbers.size).to eq expecting.size
    expect(filtered_numbers).to include *expecting
    expect(filtered_numbers).not_to include *not_expecting
  end
end
