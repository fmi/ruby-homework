describe ObjectStore do
  RSpec::Matchers.define :be_success do |message, result|
    match do |actual|
      actual.message == message &&
      actual.result == result &&
      actual.success? == true &&
      actual.error? == false
    end
  end

  it "can commit objects" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    expect(repo.commit("So cool!")).to be_success("So cool!\n\t2 objects changed", repo.head.result)
  end
end
