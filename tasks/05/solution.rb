require 'digest/sha1'
require 'set'

# Tracks history of objects.
module ObjectStore
  def self.init(&block)
    repository = MainInterface.new

    if block_given?
      repository.instance_eval(&block)
    end

    repository
  end
end

# Holds modified objects.
class ObjectStore::Stage
  attr_reader :added, :removed

  def initialize
    @added = {}
    @removed = Set.new
  end

  def add(name, object)
    @added[name] = object
  end

  def remove(name)
    @removed << name
  end

  def empty?
    @added.empty? && @removed.empty?
  end

  def count
    @added.size + @removed.size
  end
end

# Represents a commit in the repository.
class ObjectStore::Commit
  attr_accessor :parent, :message, :hash, :date

  def initialize(parent, message, stage)
    @parent = parent
    @message = message
    @stage = stage
    @date = Time.new
    @hash = Digest::SHA1.hexdigest("#{formatted_date}#{@message}")
  end

  def has_object?(name)
    merged_stage.has_key?(name)
  end

  def objects
    merged_stage.values
  end

  def object(name)
    merged_stage[name]
  end

  def changed_objects_count
    @stage.added.size + @stage.removed.size
  end

  def to_s
    "Commit #{@hash}\n" +
    "Date: #{formatted_date}\n\n" +
    "\t#{@message}"
  end

  protected

  def merged_stage
    return @stage.added if parent == nil

    parent.merged_stage.merge(@stage.added).reject do |name, object|
      @stage.removed.include?(name)
    end
  end

  private

  def formatted_date
    @date.strftime("%a %b %d %H:%M %Y %z")
  end
end

# Main repository logic.
class ObjectStore::Repository
  def initialize
    @branches = { master: nil }
    @active = :master
    @stage = ObjectStore::Stage.new
  end

  def branches
    @branches.keys.sort
  end

  def create_branch(name)
    @branches[name] = @branches[@active]
  end

  def active_branch
    @active
  end

  def active_branch=(name)
    @active = name
  end

  def delete_branch(name)
    @branches.delete(name.to_sym)
  end

  def add_object(name, object)
    @stage.add(name, object)
  end

  def remove_object(name)
    @stage.remove(name)
    head.object(name)
  end

  def has_object?(name)
    return false if empty?

    head.has_object?(name)
  end

  def objects
    return {} if empty?

    head.objects
  end

  def object(name)
    head.object(name)
  end

  def empty?
    head == nil || head.objects.empty?
  end

  def modified?
    !@stage.empty?
  end

  def commit(message)
    commit = ObjectStore::Commit.new(head, message, @stage)
    update_head(commit)
    @stage = ObjectStore::Stage.new
    commit
  end

  def commits
    commits = []
    commit = head
    while commit
      commits << commit
      commit = commit.parent
    end
    commits
  end

  def checkout(hash)
    commit = head
    while commit != nil && commit.hash != hash
      commit = commit.parent
    end

    if commit != nil
      update_head(commit)
    end

    commit
  end

  private

  def head
    @branches[@active]
  end

  def update_head(commit)
    @branches[@active] = commit
  end
end

# Represents the result of an ObjectStore command.
class ObjectStore::Result
  attr_reader :message

  def initialize(message, success)
    @message = message
    @success = success
  end

  def success?
    @success
  end

  def error?
    !@success
  end
end

# Error command result.
class ObjectStore::Error < ObjectStore::Result
  def initialize(message)
    super(message, false)
  end
end

# Success command result.
class ObjectStore::Success < ObjectStore::Result
  attr_reader :result

  def initialize(message, result = nil)
    super(message, true)

    @result = result
  end
end

# Helpers for building commands.
module ObjectStore::CommandHelpers
  def error(message)
    ObjectStore::Error.new(message)
  end

  def success(message, result = nil)
    ObjectStore::Success.new(message, result)
  end
end

# Deals with the main commands in the ObjectStore interface.
class ObjectStore::MainInterface
  include ObjectStore::CommandHelpers

  def initialize
    @repository = ObjectStore::Repository.new
  end

  def branch
    ObjectStore::BranchInterface.new(@repository)
  end

  def add(name, object)
    @repository.add_object(name, object)

    success("Added #{name} to stage.", object)
  end

  def remove(name)
    unless @repository.has_object?(name)
      return error("Object #{name} is not committed.")
    end

    removed_object = @repository.remove_object(name)

    success("Added #{name} for removal.", removed_object)
  end

  def commit(message)
    unless @repository.modified?
      return error("Nothing to commit, working directory clean.")
    end

    commit = @repository.commit(message)
    success("#{commit.message}\n" +
            "\t#{commit.changed_objects_count} objects changed",
            commit)
  end

  def head
    if @repository.empty?
      return error("Branch #{@repository.active_branch} " +
                   "does not have any commits yet.")
    end

    head_commit = @repository.commits.first
    success(head_commit.message, head_commit)
  end

  def log
    if @repository.empty?
      return error("Branch #{@repository.active_branch} " +
                   "does not have any commits yet.")
    end

    success(@repository.commits.map(&:to_s).join("\n\n"))
  end

  def get(name)
    unless @repository.has_object?(name)
      return error("Object #{name} is not committed.")
    end

    object = @repository.object(name)

    success("Found object #{name}.", object)
  end

  def checkout(hash)
    commit = @repository.checkout(hash)

    if commit == nil
      return error("Commit #{hash} does not exist.")
    end

    success("HEAD is now at #{hash}.", commit)
  end
end

# Deals with the branch commands in the ObjectStore interface.
class ObjectStore::BranchInterface
  include ObjectStore::CommandHelpers

  def initialize(repository)
    @repository = repository
  end

  def list
    branch_list = @repository.branches.map do |name|
      if @repository.active_branch == name
        "* #{name}"
      else
        "  #{name}"
      end
    end.join("\n")
    success(branch_list)
  end

  def create(name)
    name = name.to_sym

    if @repository.branches.include?(name)
      return error("Branch #{name} already exists.")
    end

    @repository.create_branch(name)
    success("Created branch #{name}.")
  end

  def remove(name)
    name = name.to_sym

    unless @repository.branches.include?(name)
      return error("Branch #{name} does not exist.")
    end

    if @repository.active_branch == name
      return error("Cannot remove current branch.")
    end

    @repository.delete_branch(name)
    success("Removed branch #{name}.")
  end

  def checkout(name)
    name = name.to_sym

    unless  @repository.branches.include?(name)
      return error("Branch #{name} does not exist.")
    end

    @repository.active_branch = name
    success("Switched to branch #{name}.")
  end
end

