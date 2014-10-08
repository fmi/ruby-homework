describe 'series' do
  it 'handles fibonacci series' do
    series('fibonacci', 1).should eq 1
    series('fibonacci', 20).should eq 6765
  end

  it 'handles lucas series' do
    series('lucas', 1).should eq 2
  end

  it 'handles summed series' do
    series('summed', 1).should eq 3
  end
end
