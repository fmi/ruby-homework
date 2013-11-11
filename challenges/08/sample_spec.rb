describe "Spy" do
  it "tracks calls" do
    string = 'Spy me!'
    spied_string = Spy.new string

    spied_string.length.should eq string.length
    spied_string.calls.should eq [:length]
  end
end
