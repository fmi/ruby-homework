describe "Spy" do
  it "calls the target methods" do
    string = 'Bond. James Bond.'
    spied_string = Spy.new string

    spied_string.class.should eq String
    spied_string.length.should eq string.length
  end

  it "tracks calls" do
    string = 'Bond. James Bond.'
    spied_string = Spy.new string

    spied_string.length
    spied_string.calls.should eq [:length]
  end

  it "calls only public methods" do
    c = Class.new { private def hidden; end }
    spied_c = Spy.new c.new

    ->{ spied_c.hidden }.should raise_error Spy::Error
  end

  it "raises ProxyError for methods absent in the target" do
    spied_string = Spy.new 'Bond. James Bond.'

    ->{ spied_string.foo }.should raise_error Spy::Error
  end
end
