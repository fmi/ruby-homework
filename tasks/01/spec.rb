describe '#convert_between_temperature_units' do
  it 'can convert to the same unit' do
    expect_conversion 42, 'C', 42, 'C'
    expect_conversion 42, 'F', 42, 'F'
    expect_conversion 42, 'K', 42, 'K'
  end

  it 'can convert Celsius degrees to Kelvins' do
    expect_conversion 10,      'C', 283.15, 'K'
    expect_conversion 0,       'C', 273.15, 'K'
    expect_conversion -5,      'C', 268.15, 'K'
    expect_conversion -23.15,  'C', 250,    'K'
    expect_conversion -273.15, 'C', 0,      'K'
  end

  it 'can convert Kelvin to Celsius' do
    expect_conversion 273.15, 'K', 0,       'C'
    expect_conversion 0,      'K', -273.15, 'C'
    expect_conversion 285,    'K', 11.85,   'C'
  end

  it 'can convert Celsius to Fahrenheit' do
    expect_conversion 1,       'C', 33.8,    'F'
    expect_conversion 0,       'C', 32,      'F'
    expect_conversion -273.15, 'C', -459.67, 'F'
    expect_conversion -40,     'C', -40,     'F'
    expect_conversion 100,     'C', 212,     'F'
  end

  it 'can convert Fahrenheit to Celsius' do
    expect_conversion 33.8,    'F', 1,       'C'
    expect_conversion 32,      'F', 0,       'C'
    expect_conversion -459.67, 'F', -273.15, 'C'
    expect_conversion -40,     'F', -40,     'C'
    expect_conversion 212,     'F', 100,     'C'
  end

  it 'can convert Kelvin to Fahrenheit' do
    expect_conversion 274.15, 'K', 33.8,    'F'
    expect_conversion 273.15, 'K', 32,      'F'
    expect_conversion 0,      'K', -459.67, 'F'
    expect_conversion 233.15, 'K', -40,     'F'
    expect_conversion 373.15, 'K', 212,     'F'
  end

  it 'can convert Fahrenheit to Kelvin' do
    expect_conversion 33.8,    'F', 274.15, 'K'
    expect_conversion 32,      'F', 273.15, 'K'
    expect_conversion -459.67, 'F', 0,      'K'
    expect_conversion -40,     'F', 233.15, 'K'
    expect_conversion 212,     'F', 373.15, 'K'
  end

  def expect_conversion(from_value, from_units, expected_to_value, to_units)
    actual_to_value = convert_between_temperature_units(from_value.to_f, from_units, to_units)

    expect(actual_to_value).to be_within(0.0001).of(expected_to_value)
  end
end

describe '#melting_point_of_substance' do
  it 'knows the melting point of water' do
    expect_melting_point_of 'water', 0,      'C'
    expect_melting_point_of 'water', 273.15, 'K'
    expect_melting_point_of 'water', 32,     'F'
  end

  it 'knows the melting point of ethanol' do
    expect_melting_point_of 'ethanol', -114,   'C'
    expect_melting_point_of 'ethanol', 159.15, 'K'
    expect_melting_point_of 'ethanol', -173.2, 'F'
  end

  it 'knows the melting point of gold' do
    expect_melting_point_of 'gold', 1_064,   'C'
    expect_melting_point_of 'gold', 1337.15, 'K'
    expect_melting_point_of 'gold', 1947.2,  'F'
  end

  it 'knows the melting point of silver' do
    expect_melting_point_of 'silver', 961.8,   'C'
    expect_melting_point_of 'silver', 1234.95, 'K'
    expect_melting_point_of 'silver', 1763.24, 'F'
  end

  it 'knows the melting point of copper' do
    expect_melting_point_of 'copper', 1_085,   'C'
    expect_melting_point_of 'copper', 1358.15, 'K'
    expect_melting_point_of 'copper', 1985.0,  'F'
  end

  def expect_melting_point_of(substance, expected_degrees, units)
    expect(melting_point_of_substance(substance, units)).to be_within(0.01).of(expected_degrees)
  end
end

describe '#boiling_point_of_substance' do
  it 'knows the boiling point of water' do
    expect_boiling_point_of 'water', 100,    'C'
    expect_boiling_point_of 'water', 373.15, 'K'
    expect_boiling_point_of 'water', 212.0,  'F'
  end

  it 'knows the boiling point of ethanol' do
    expect_boiling_point_of 'ethanol', 78.37,   'C'
    expect_boiling_point_of 'ethanol', 351.52,  'K'
    expect_boiling_point_of 'ethanol', 173.066, 'F'
  end

  it 'knows the boiling point of gold' do
    expect_boiling_point_of 'gold', 2_700,   'C'
    expect_boiling_point_of 'gold', 2973.15, 'K'
    expect_boiling_point_of 'gold', 4892.0,  'F'
  end

  it 'knows the boiling point of silver' do
    expect_boiling_point_of 'silver', 2_162,   'C'
    expect_boiling_point_of 'silver', 2435.15, 'K'
    expect_boiling_point_of 'silver', 3923.6,  'F'
  end

  it 'knows the boiling point of copper' do
    expect_boiling_point_of 'copper', 2_567,   'C'
    expect_boiling_point_of 'copper', 2840.15, 'K'
    expect_boiling_point_of 'copper', 4652.6,  'F'
  end

  def expect_boiling_point_of(substance, expected_degrees, units)
    expect(boiling_point_of_substance(substance, units)).to be_within(0.01).of(expected_degrees)
  end
end
