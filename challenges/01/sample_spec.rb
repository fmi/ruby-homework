describe 'complement' do
  it 'complements a function' do
    is_answer = ->(n) { n == 42 }
    not_answer = complement(is_answer)

    expect(not_answer.call(42)).to eq false
  end
end

describe 'compose' do
  it 'returns a function composition of two functions' do
    add_two = ->(n) { n + 2 }
    is_answer = ->(n) { n == 42 }

    expect(compose(is_answer, add_two).call(40)).to eq true
  end
end
