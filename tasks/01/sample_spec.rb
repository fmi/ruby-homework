describe '#convert_between_temperature_units' do
  it 'is defined and functions for simple values' do
    expect(convert_between_temperature_units(0, 'C', 'K')).to be_within(0.0001).of(273.15)
    expect(convert_between_temperature_units(1, 'C', 'F')).to be_within(0.0001).of(33.8)
  end
end

describe '#melting_point_of_substance' do
  it 'knows the melting point of water' do
    expect(melting_point_of_substance('water', 'C')).to be_within(0.01).of(0)
    expect(melting_point_of_substance('water', 'K')).to be_within(0.01).of(273.15)
  end
end

describe '#boiling_point_of_substance' do
  it 'knows the boiling point of water' do
    expect(boiling_point_of_substance('water', 'C')).to be_within(0.01).of(100)
    expect(boiling_point_of_substance('water', 'K')).to be_within(0.01).of(373.15)
  end
end
