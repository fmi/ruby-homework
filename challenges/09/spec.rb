describe "Memoizer" do
  it "calls the methods of the target class" do
    string = "A string"
    memoizer = Memoizer.new string

    memoizer.length.should eq 8
  end

  it "raises NoMethodError when an unknown method is called" do
    memoizer = Memoizer.new "A string"

    -> { memoizer.no_such_string_method }.should raise_error NoMethodError
  end

  it "memoizes results" do
    call_count = 0

    object = Object.new
    object.define_singleton_method :foo do
      call_count += 1
      :bar
    end

    memoized = Memoizer.new object

    memoized.foo.should eq :bar
    memoized.foo.should eq :bar
    call_count.should eq 1
  end

  it "returns the actual class of the target object" do
    Memoizer.new(Object.new).class.should eq Object
  end

  it "works with nil return values" do
    call_count = 0

    object = Object.new
    object.define_singleton_method :foo do
      call_count += 1
      nil
    end

    memoized = Memoizer.new object

    memoized.foo.should be_nil
    memoized.foo.should be_nil
    call_count.should eq 1
  end

  it 'works with blocks' do
    array = [2]

    block_call_count = 0

    memoized = Memoizer.new array
    memoized.each { block_call_count += 1 }
    memoized.each { block_call_count += 1 }

    block_call_count.should eq 2
  end
end
