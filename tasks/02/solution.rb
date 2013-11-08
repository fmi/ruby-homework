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

  def self.parse(text)
    parsing = Parsing.new(text) do |status, description, priority, tags|
      Task.new status, description, priority, tags
    end

    TodoList.new parsing.tasks
  end

  def initialize(tasks = [])
    @tasks = tasks
  end

  def filter(criteria)
    TodoList.new @tasks.select { |task| criteria.met_by? task }
  end

  def adjoin(other)
    TodoList.new self.tasks | other.tasks
  end

  def tasks_todo
    filter(Criteria.status :todo).count
  end

  def tasks_in_progress
    filter(Criteria.status :current).count
  end

  def tasks_completed
    filter(Criteria.status :done).count
  end

  def completed?
    tasks_completed == @tasks.count
  end

  def each(&block)
    @tasks.each &block
  end

  protected

  attr_reader :tasks
end

class TodoList::Parsing
  attr_reader :tasks

  def initialize(text, &block)
    @tasks = parse_lines(text).map(&block)
  end

  private

  def parse_lines(text)
    text.lines.map { |line| line.split('|').map(&:strip) }.map do |attributes|
      format_attributes *attributes
    end
  end

  def format_attributes(status, description, priority, tags)
    [
     status.downcase.to_sym,
     description,
     priority.downcase.to_sym,
     tags.split(',').map(&:strip)
    ]
  end
end

module Criteria
  class << self
    def status(status)
      Criterion.new { |task| task.status == status }
    end

    def priority(priority)
      Criterion.new { |task| task.priority == priority }
    end

    def tags(tags)
      Criterion.new { |task| (tags & task.tags).count == tags.count }
    end
  end
end

class Criterion
  def initialize(&condition)
    @condition = condition
  end

  def met_by?(task)
    @condition.call(task)
  end

  def &(other)
    Criterion.new { |task| self.met_by?(task) and other.met_by?(task) }
  end

  def |(other)
    Criterion.new { |task| self.met_by?(task) or other.met_by?(task) }
  end

  def !
    Criterion.new { |task| not met_by?(task) }
  end
end
