def degrees_to_celsius(degrees, from_units)
  case from_units
  when 'C' then degrees
  when 'K' then degrees - 273.15
  when 'F' then (degrees - 32) / 1.8
  end
end

def degrees_from_celsius(degrees, to_units)
  case to_units
  when 'C' then degrees
  when 'K' then degrees + 273.15
  when 'F' then degrees * 1.8 + 32
  end
end

def convert_between_temperature_units(from_degrees, from_units, to_units)
  degrees_in_celsius = degrees_to_celsius(from_degrees, from_units)

  degrees_from_celsius(degrees_in_celsius, to_units)
end

SUBSTANCES = {
  'water'   => {melting_point: 0,     boiling_point: 100  },
  'ethanol' => {melting_point: -114,  boiling_point: 78.37},
  'gold'    => {melting_point: 1_064, boiling_point: 2_700},
  'silver'  => {melting_point: 961.8, boiling_point: 2_162},
  'copper'  => {melting_point: 1_085, boiling_point: 2_567}
}

def melting_point_of_substance(substance, units)
  degrees_from_celsius(SUBSTANCES[substance][:melting_point], units)
end

def boiling_point_of_substance(substance, units)
  degrees_from_celsius(SUBSTANCES[substance][:boiling_point], units)
end
