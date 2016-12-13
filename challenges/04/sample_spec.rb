describe 'DrunkProxy' do
  it 'calls targets methods' do
    string = 'hello'
    number = 2.3
    proxy = DrunkProxy.new [string, number]

    expect(proxy.length).to eq [string.length]
    expect(proxy.floor).to eq [number.floor]
  end
end
