describe 'button_presses' do
  it 'works for simple words' do
    expect(button_presses('LOL')).to eq 9
  end

  it 'works for phrases with spaces' do
    expect(button_presses('HOW R U')).to eq 13
  end

  it 'works for phrases with numbers' do
    expect(button_presses('WHERE DO U WANT 2 MEET L8R')).to eq 47
  end

  it 'allows input in lowercase' do
    expect(button_presses('lol')).to eq 9
  end

  it 'handles the 0 digit' do
    expect(button_presses('0')).to eq 2
    expect(button_presses('ZER0')).to eq 11
  end

  it 'handles the 1 digit' do
    expect(button_presses('1')).to eq 1
    expect(button_presses('IS NE1 OUT THERE')).to eq 31
  end

  it 'handles digits only' do
    expect(button_presses('2015')).to eq 11
  end

  it 'handles *' do
    expect(button_presses('**OMG**')).to eq 9
  end

  it 'handles #' do
    expect(button_presses('canon in c#')).to eq 22
  end
end
