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

  let(:todo_list) { TodoList.parse text_input }

  it "filters tasks by tag" do
    todo_list.filter(Criteria.tags %w[wtf]).map(&:description).should =~ ['Hunt saber-toothed cats.']
  end

  it "supports a conjuction of filters" do
    filtered = todo_list.filter Criteria.status(:todo) & Criteria.priority(:high)
    filtered.map(&:description).should =~ ['Eat spaghetti.', 'Destroy Facebook and Google.']
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

  it "filtering by multiple tags matches only tasks with all the tags" do
    todo_list.filter(Criteria.tags %w[development FMI]).map(&:description).should =~ ['Do the 5th Ruby challenge.']
  end

  it "returns the number of the completed tasks" do
    todo_list.tasks_completed.should eq 2
  end
end
