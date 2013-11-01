describe TodoList do
  let(:text_input) do
    <<-END
      TODO    | Eat spaghetti.               | High   | food, happiness
      TODO    | Get 8 hours of sleep.        | Low    | health
      CURRENT | Party animal.                | Normal | socialization
      CURRENT | Grok Ruby.                   | High   | development, ruby
      DONE    | Have some tea.               | Normal |
      TODO    | Destroy Facebook and Google. | High   | save humanity, conspiracy
      TODO    | Hunt saber-toothed cats.     | Low    | wtf
      DONE    | Do the 5th Ruby challenge.   | High   | ruby course, FMI, development, ruby
      TODO    | Find missing socks.          | Low    |
      CURRENT | Grow epic mustache.          | High   | sex appeal
    END
  end

  let(:valid_status_symbols)   { [:todo, :current, :done] }
  let(:valid_priority_symbols) { [:high, :normal,  :low ] }

  let(:todo_list) { TodoList.parse text_input }


  it "implements Enumerable" do
    todo_list.should respond_to :each
    todo_list.should be_an Enumerable
  end

  it "has the neccessary getters" do
    todo_list.each do |task|
      task.should respond_to :status
      task.should respond_to :description
      task.should respond_to :priority
      task.should respond_to :tags
    end
  end

  it "has an array of tags" do
    todo_list.each do |task|
      task.tags.should be_an Array
    end
  end

  it "should preserve the order of tasks" do
    todo_list.map(&:description).should eq [
                                            'Eat spaghetti.',
                                            'Get 8 hours of sleep.',
                                            'Party animal.',
                                            'Grok Ruby.',
                                            'Have some tea.',
                                            'Destroy Facebook and Google.',
                                            'Hunt saber-toothed cats.',
                                            'Do the 5th Ruby challenge.',
                                            'Find missing socks.',
                                            'Grow epic mustache.',
                                           ]
  end

  it "filters tasks by tag" do
    todo_list.filter(Criteria.tags %w[wtf]).map(&:description).should =~ ['Hunt saber-toothed cats.']
  end

  it "creates a new object on filter" do
    todo_list.filter(Criteria.tags %w[wtf]).should_not be todo_list
  end

  it "supports a conjuction of filters" do
    filtered = todo_list.filter Criteria.status(:todo) & Criteria.priority(:high)
    filtered.map(&:description).should =~ ['Eat spaghetti.', 'Destroy Facebook and Google.']
  end

  it "supports a disjunction of filters" do
    filtered = todo_list.filter Criteria.status(:done) | Criteria.tags(['save humanity'])
    filtered.map(&:description).should =~ [
                                           'Have some tea.',
                                           'Destroy Facebook and Google.',
                                           'Do the 5th Ruby challenge.',
                                          ]
  end

  it "supports negation of a filter" do
    filtered = todo_list.filter !Criteria.status(:todo)
    filtered.map(&:description).should =~ [
                                           'Party animal.',
                                           'Grok Ruby.',
                                           'Have some tea.',
                                           'Do the 5th Ruby challenge.',
                                           'Grow epic mustache.',
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

  it "filters tasks by multiple tags" do
    todo_list.filter(Criteria.tags %w[development ruby]).map(&:description).should =~ [
                                                                                       'Grok Ruby.',
                                                                                       'Do the 5th Ruby challenge.'
                                                                                      ]
  end

  it "filters by multiple tags and matches only tasks with all the tags" do
    todo_list.filter(Criteria.tags %w[development FMI]).map(&:description).should =~ ['Do the 5th Ruby challenge.']
  end

  it "returns the number of the completed tasks" do
    todo_list.tasks_completed.should eq 2
  end

  it "returns the number of tasks in progress" do
    todo_list.tasks_in_progress.should eq 3
  end

  it "returns the number of completed tasks" do
    todo_list.tasks_completed.should eq 2
  end

  it "responds to completed?" do
    todo_list.should respond_to :completed?
  end

  it "uses correct symbols for status" do
    todo_list.should be_all { |task| valid_status_symbols.include? task.status }
  end

  it "uses correct symbols for priority" do
    todo_list.should be_all { |task| valid_priority_symbols.include? task.priority }
  end
end