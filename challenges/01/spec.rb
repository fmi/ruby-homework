describe 'format_string' do
  it 'does not change already formatted strings' do
    expect(format_string('BACON!!', 5)).to eq 'BACON!!'
  end

  it 'trims spaces' do
    expect(format_string('     BACON!!  ', 0)).to eq 'BACON!!'
  end

  it 'does not attempt to center the string if the width is less than the one after processing' do
    expect(format_string('  do YouR   challengE   NoW    ', 10)).to eq 'DO YOUR CHALLENGE NOW'
  end

  it 'does not attempt to center the string if the width is zero' do
    expect(format_string(' HAstA    LA vista,     bAbY!      ', 0)).to eq 'HASTA LA VISTA, BABY!'
  end

  it 'appends odd intervals at the end of the string when centering' do
    expect(format_string('odd', 4)).to eq 'ODD '
    expect(format_string('odds', 7)).to eq ' ODDS  '
    expect(format_string('  WELL   that  is   strange', 25)).to eq '  WELL THAT IS STRANGE   '
  end

  it 'centers strings properly when the length difference is even' do
    expect(format_string('try harder!', 13)).to eq ' TRY HARDER! '
    expect(format_string('  Run  FOrest   run!!', 20)).to eq '  RUN FOREST RUN!!  '
  end

  it 'works with already trimmed strings with greater width padding' do
    expect(format_string('chunky   bacon!! ', 20)).to eq '   CHUNKY BACON!!   '
  end
end
