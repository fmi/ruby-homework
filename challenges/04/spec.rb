describe 'DrunkProxy' do
  it 'calls targets methods' do
    number = -42
    string = 'something'
    array = [444, 44]
    proxy = DrunkProxy.new [number, string, array]

    expect(proxy.abs).to eq [number.abs]
    expect(proxy.upcase).to eq [string.upcase]
    expect(proxy.reverse).to eq [string.reverse, array.reverse]
    expect(proxy.length).to eq [string.length, array.length]
  end

  it 'proxies most of the methods' do
    string = 'foo'
    array = [1, 2, 3]
    proxy = DrunkProxy.new [string, array]

    expect(proxy.class).to eq [string.class, array.class]
    expect(proxy.is_a?(String)).to eq [true, false]
  end

  it 'raises error when calling missing methods' do
    expect { DrunkProxy.new([]).abs }.to raise_error(NoMethodError)
    expect { DrunkProxy.new(['string']).abs }.to raise_error(NoMethodError)
  end

  it 'raises error when calling private methods' do
    klass = Class.new { private def private_method; end }
    proxy = DrunkProxy.new [klass.new]

    expect { proxy.private_method }.to raise_error(NoMethodError)
  end
end
