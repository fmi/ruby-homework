require 'digest/sha1'

describe ObjectStore do
  RSpec::Matchers.define :be_success do |message, result|
    match do |actual|
      actual.message == message &&
      actual.result == result &&
      actual.success? == true &&
      actual.error? == false
    end
  end

  RSpec::Matchers.define :be_error do |message|
    match do |result|
      result.message == message &&
      result.success? == false &&
      result.error? == true
    end
  end

  it "can add objects" do
    repo = ObjectStore.init
    expect(repo.add("object", "content")).to be_success("Added object to stage.", "content")
  end

  it "can commit objects" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    expect(repo.commit("So cool!")).to be_success("So cool!\n\t2 objects changed", repo.head.result)
  end

  it "cannot commit without changed objects" do
    repo = ObjectStore.init
    expect(repo.commit("So cool!!")).to be_error("Nothing to commit, working directory clean.")
  end

  it "can remove objects" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    repo.commit("So cool!")
    expect(repo.remove("object1")).to be_success("Added object1 for removal.", "content1")
  end

  it "can commit changes which include only removed objects" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    repo.commit("So cool!")

    repo.remove("object2")
    expect(repo.commit("Removed object2")).to be_success("Removed object2\n\t1 objects changed", repo.head.result)
  end

  it "cannot remove objects that are not committed" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.commit("So cool!")
    expect(repo.remove("object2")).to be_error("Object object2 is not committed.")
  end

  it "can show head" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.commit("First part... more to come...")
    repo.add("object2", "content2")
    last_commit = repo.commit("There we go").result
    expect(repo.head).to be_success("There we go", last_commit)
  end

  it "cannot show head for empty repository" do
    repo = ObjectStore.init
    expect(repo.head).to be_error("Branch master does not have any commits yet.")
  end

  it "can show log of changes for a single commit" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    commit = repo.commit("So cool!").result
    commit_hash = Digest::SHA1.hexdigest("#{commit.date.strftime("%a %b %d %H:%M %Y %z")}#{commit.message}")
    expect(repo.log).to be_success("Commit #{commit_hash}\nDate: #{Time.now.strftime("%a %b %d %H:%M %Y %z")}\n\n\tSo cool!")
  end

  it "can show log of changes for a single commit" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    commit = repo.commit("So cool!").result
    commit_hash = Digest::SHA1.hexdigest("#{commit.date.strftime("%a %b %d %H:%M %Y %z")}#{commit.message}")
    expect(repo.log).to be_success("Commit #{commit_hash}\nDate: #{Time.now.strftime("%a %b %d %H:%M %Y %z")}\n\n\tSo cool!")
  end

  it "can show log of changes for multiple commits" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    commit1 = repo.commit("First commit").result
    repo.add("object2", "content2")
    commit2 = repo.commit("Second commit").result

    time_format  = "%a %b %d %H:%M %Y %z"
    current_time = Time.now.strftime(time_format)

    commit1_hash = Digest::SHA1.hexdigest("#{commit1.date.strftime(time_format)}#{commit1.message}")
    commit2_hash = Digest::SHA1.hexdigest("#{commit2.date.strftime(time_format)}#{commit2.message}")

    expect(repo.log).to be_success("Commit #{commit2_hash}\nDate: #{current_time}\n\n\tSecond commit\n\nCommit #{commit1_hash}\nDate: #{current_time}\n\n\tFirst commit")
  end

  it "shows the log for the current branch only" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    commit1 = repo.commit("First commit").result

    repo.branch.create("develop")

    repo.add("object2", "content2")
    repo.commit("Second commit")

    repo.branch.checkout("develop")

    time_format  = "%a %b %d %H:%M %Y %z"
    current_time = Time.now.strftime(time_format)

    commit1_hash = Digest::SHA1.hexdigest("#{commit1.date.strftime(time_format)}#{commit1.message}")

    expect(repo.log).to be_success("Commit #{commit1_hash}\nDate: #{current_time}\n\n\tFirst commit")
  end

  it "cannot show log for empty repository" do
    repo = ObjectStore.init
    expect(repo.log).to be_error("Branch master does not have any commits yet.")
  end

  it "can list branches" do
    repo = ObjectStore.init
    repo.branch.create("develop")
    repo.branch.create("feature")
    expect(repo.branch.list).to be_success("  develop\n  feature\n* master")
  end

  it "can create branches" do
    repo = ObjectStore.init
    expect(repo.branch.create("develop")).to be_success("Created branch develop.")
  end

  it "cannot create branch if already exists" do
    repo = ObjectStore.init
    expect(repo.branch.create("master")).to be_error("Branch master already exists.")
  end

  it "can switch branches" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    first_commit = repo.commit("First commit").result
    repo.branch.create("develop")
    expect(repo.branch.checkout("develop")).to be_success("Switched to branch develop.")
    repo.add("object2", "content2")
    second_commit = repo.commit("Second commit").result
    expect(repo.head).to be_success("Second commit", second_commit)
    expect(repo.branch.checkout("master")).to be_success("Switched to branch master.")
    expect(repo.head).to be_success("First commit", first_commit)
  end

  it "cannot switch to nonexisting branch" do
    repo = ObjectStore.init
    expect(repo.branch.checkout("develop")).to be_error("Branch develop does not exist.")
  end

  it "can remove branch" do
    repo = ObjectStore.init
    repo.branch.create("develop")
    expect(repo.branch.remove("develop")).to be_success("Removed branch develop.")
  end

  it "cannot remove current branch" do
    repo = ObjectStore.init
    expect(repo.branch.remove("master")).to be_error("Cannot remove current branch.")
  end

  it "cannot remove nonexisting branch" do
    repo = ObjectStore.init
    expect(repo.branch.remove("develop")).to be_error("Branch develop does not exist.")
  end

  it "can be initialized with block" do
    repo = ObjectStore.init do
      add("object1", "content1")
      commit("First commit")

      add("object2", "content")
      $second_commit = commit("Second commit").result
    end
    expect(repo.head).to be_success("Second commit", $second_commit)
  end

  it "can return objects" do
    repo = ObjectStore.init
    repo.add("number", 21)
    repo.commit("Message!")
    expect(repo.get("number")).to be_success("Found object number.", 21)
  end

  it "cannot return not committed objects" do
    repo = ObjectStore.init
    repo.add("number", 21)
    repo.commit("Message!")
    expect(repo.get("string")).to be_error("Object string is not committed.")
  end

  it "cannot return objects when no commits" do
    repo = ObjectStore.init
    expect(repo.get("string")).to be_error("Object string is not committed.")
  end

  it "can checkout commits" do
    repo = ObjectStore.init
    repo.add("number", 42)
    first_commit = repo.commit("First commit").result
    repo.add("number", 21)
    repo.commit("Second commit")
    expect(repo.checkout(first_commit.hash)).to be_success("HEAD is now at #{first_commit.hash}.", first_commit)
    expect(repo.head).to be_success("First commit", first_commit)
  end

  it "cannot checkout commits with nonexisting hashes" do
    repo = ObjectStore.init
    repo.add("number", 42)
    repo.commit("Something")
    expect(repo.checkout("[not-present]")).to be_error("Commit [not-present] does not exist.")
  end

  it "cannot checkout commits in empty repository" do
    repo = ObjectStore.init
    expect(repo.checkout("[not-present]")).to be_error("Commit [not-present] does not exist.")
  end

  it "can show the objects in a repo after overwriting an object" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    first_commit = repo.commit("First commit").result
    expect(first_commit.objects).to match_array(["content1"])

    repo.add("object2", "content2")
    repo.add("object1", "content3")
    second_commit = repo.commit("Second commit").result
    expect(second_commit.objects).to match_array(["content2", "content3"])

    expect(repo.head.result.objects).to match_array(["content2", "content3"])
  end

  it "can show the objects of a repo after removing an object" do
    repo = ObjectStore.init
    repo.add("object1", "content1")
    repo.add("object2", "content2")
    repo.add("object3", "content3")
    first_commit = repo.commit("First commit").result
    expect(first_commit.objects).to match_array(["content1", "content2", "content3"])

    repo.remove("object2")
    second_commit = repo.commit("Second commit").result
    expect(second_commit.objects).to match_array(["content3", "content1"])

    expect(repo.head.result.objects).to match_array(["content3", "content1"])
  end
end

