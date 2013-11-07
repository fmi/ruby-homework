describe TodoList do
  let(:text_input) do
    <<-END
      TODO    | Eat spaghetti.               | High   | food, happiness
      TODO    | Get 8 hours of sleep.        | Low    | health
      CURRENT | Party animal.                | Normal | socialization
      CURRENT | Grok Ruby.                   | High   | development, ruby
      DONE    | Have some tea.               | Normal |
      TODO    | Destroy Facebook and Google. | High   | save humanity, conspiracy
      DONE    | Do the 5th Ruby challenge.   | High   | ruby course, FMI, development, ruby
      TODO    | Find missing socks.          | Low    |
      TODO    | Occupy Sofia University.     | High   | #ДАНСwithMe, #occupysu, #оставка
    END
  end

  let(:todo_list) { TodoList.parse text_input }

  it "filters tasks by status" do
    todo_list.filter(Criteria.status :done).map(&:description).should =~ [
                                                                          'Have some tea.',
                                                                          'Do the 5th Ruby challenge.'
                                                                         ]
  end

  it "filters tasks by priority" do
    todo_list.filter(Criteria.priority :high).map(&:description).should =~ [
                                                                            'Eat spaghetti.',
                                                                            'Grok Ruby.',
                                                                            'Destroy Facebook and Google.',
                                                                            'Do the 5th Ruby challenge.',
                                                                            'Occupy Sofia University.'
                                                                           ]
  end

  it "filters tasks by tag" do
    todo_list.filter(Criteria.tags %w[food]).map(&:description).should =~ ['Eat spaghetti.']
  end

  it "filters tasks by multiple tags" do
    todo_list.filter(Criteria.tags %w[development ruby]).map(&:description).should =~ [
                                                                                       'Grok Ruby.',
                                                                                       'Do the 5th Ruby challenge.'
                                                                                      ]
  end

  it "filtering by multiple tags matches only tasks with all the tags" do
    todo_list.filter(Criteria.tags %w[development FMI]).map(&:description).should =~ ['Do the 5th Ruby challenge.']
  end

  it "supports a conjuction of filters" do
    filtered = todo_list.filter Criteria.status(:todo) & Criteria.priority(:high)
    filtered.map(&:description).should =~ ['Eat spaghetti.', 'Destroy Facebook and Google.', 'Occupy Sofia University.']
  end

  it "supports a disjunction of filters" do
    filtered = todo_list.filter Criteria.status(:done) | Criteria.priority(:low)
    filtered.map(&:description).should =~ [
                                           'Get 8 hours of sleep.',
                                           'Have some tea.',
                                           'Do the 5th Ruby challenge.',
                                           'Find missing socks.'
                                          ]
  end

  it "supports a negation of filters" do
    filtered = todo_list.filter !Criteria.status(:todo)
    filtered.map(&:description).should =~ [
                                           'Party animal.',
                                           'Grok Ruby.',
                                           'Have some tea.',
                                           'Do the 5th Ruby challenge.'
                                          ]
  end

  it "supports simple filters combination" do
    filtered = todo_list.filter Criteria.priority(:high) & !Criteria.tags(['development'])
    filtered.map(&:description).should =~ ['Eat spaghetti.', 'Destroy Facebook and Google.', 'Occupy Sofia University.']
  end

  it "supports complex filters combination" do
    filtered = todo_list.filter Criteria.status(:todo) &
                                Criteria.priority(:high) |
                                Criteria.priority(:normal) &
                                !Criteria.tags(['development'])

    filtered.map(&:description).should =~ [
                                           'Eat spaghetti.',
                                           'Destroy Facebook and Google.',
                                           'Party animal.',
                                           'Have some tea.',
                                           'Occupy Sofia University.'
                                          ]
  end


  it "can be adjoined with another to-do list" do
    development = todo_list.filter Criteria.tags(['development'])
    food        = todo_list.filter Criteria.tags(['food'])
    adjoined    = development.adjoin food

    adjoined.count.should eq 3
    adjoined.map(&:description).should =~ [
                                           'Eat spaghetti.',
                                           'Grok Ruby.',
                                           'Do the 5th Ruby challenge.'
                                          ]
  end

  it "constructs an object for each task" do
    task = todo_list.filter(Criteria.tags ['health']).first

    task.status.should      eq :todo
    task.description.should eq 'Get 8 hours of sleep.'
    task.priority.should    eq :low
    task.tags.should        include('health')
  end

  it "returns the number of the tasks todo" do
    todo_list.tasks_todo.should eq 5
  end

  it "returns the number of the tasks in progress" do
    todo_list.tasks_in_progress.should eq 2
  end

  it "returns the number of the completed tasks" do
    todo_list.tasks_completed.should eq 2
  end

  it "checks if all tasks are completed" do
    todo_list.completed?.should eq false
    todo_list.filter(Criteria.status :done).completed?.should eq true
  end

  it "doesn't modify the to-do list when filtering" do
    todo_list.filter(Criteria.status :todo)
    todo_list.should have(text_input.lines.count).items
  end

  it "implements Enumerable" do
    todo_list.should respond_to :each
    todo_list.should be_an Enumerable
  end

  it "contains tasks with the neccessary interface" do
    task = todo_list.first

    task.should respond_to :status
    task.should respond_to :description
    task.should respond_to :priority
    task.should respond_to :tags
  end

  it "tasks have an array of tags" do
    todo_list.first.tags.should be_an Array
  end

  it "preserves the order of tasks" do
    todo_list.map(&:description).should eq [
                                            'Eat spaghetti.',
                                            'Get 8 hours of sleep.',
                                            'Party animal.',
                                            'Grok Ruby.',
                                            'Have some tea.',
                                            'Destroy Facebook and Google.',
                                            'Do the 5th Ruby challenge.',
                                            'Find missing socks.',
                                            'Occupy Sofia University.'
                                           ]
  end

  it "creates a new object on filter" do
    todo_list.filter(Criteria.tags %w[wtf]).should_not equal todo_list
  end
end
