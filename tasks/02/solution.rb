module Criteria
  class << self
    def status(status)
      Criterion.new { |task| task.status == status }
    end

    def priority(priority)
      Criterion.new { |task| task.priority == priority }
    end

    def tags(tags)
      Criterion.new { |task| tags.all? { |tag| task.tags.include? tag } }
    end
  end
end

class Criterion
  def initialize(&condition)
    @condition = condition
  end

  def matches?(task)
    @condition.call(task)
  end

  def &(other)
    Criterion.new { |task| self.matches?(task) and other.matches?(task) }
  end

  def |(other)
    Criterion.new { |task| self.matches?(task) or other.matches?(task) }
  end

  def !
    Criterion.new { |task| not matches?(task) }
  end
end

class Task
  attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags)
    @status      = status
    @description = description
    @priority    = priority
    @tags        = tags
  end
end

class TodoList
  include Enumerable

  attr_reader :tasks

  def self.parse(text_input)
    tasks = text_input.lines.map do |line|
      task = normalize_line *line.split('|').map(&:strip)
      Task.new *task
    end

    TodoList.new tasks
  end

  def self.normalize_line(status, description, priority, tags)
    [
     status.downcase.to_sym,
     description,
     priority.downcase.to_sym,
     tags.split(',').map(&:strip)
    ]
  end

  def initialize(tasks = [])
    @tasks = tasks
  end

  def filter(criteria)
    TodoList.new @tasks.select { |task| criteria.matches? task }
  end

  def adjoin(other)
    TodoList.new self.tasks | other.tasks
  end

  def tasks_todo
    @tasks.select { |task| task.status == :todo }.count
  end

  def tasks_in_progress
    @tasks.select { |task| task.status == :current }.count
  end

  def tasks_completed
    @tasks.select { |task| task.status == :done }.count
  end

  def completed?
    tasks_completed == tasks.count
  end

  def each
    @tasks.each { |song| yield song }
  end
end
