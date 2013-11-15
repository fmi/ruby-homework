describe "Memoizer" do
  it "calls the methods of the target class" do
    memoizer = Memoizer.new "Foo"

    memoizer.*(3).should eq "FooFooFoo"
  end
end
