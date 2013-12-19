describe "Charlatan" do
  it "validates the trick" do
    Charlatan.trick do
      pick_from 1..10
      multiply_by 2
      multiply_by 5
      divide_by :your_number
      subtract 7
      you_should_get 3
    end.should be_true
  end
end
