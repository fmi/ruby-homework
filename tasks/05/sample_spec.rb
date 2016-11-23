RSpec.describe DataModel do
  let(:user_model) do
    Class.new(DataModel) do
      attributes :first_name, :last_name
      data_store HashStore.new
    end
  end

  it 'creates attribute accessors' do
    record = user_model.new
    record.first_name = 'Pesho'
    record.last_name  = 'Petrov'

    expect(record).to have_attributes first_name: 'Pesho', last_name: 'Petrov'
  end
end

RSpec.shared_examples_for 'a data store' do
  subject(:store) { described_class.new }

  describe '#create' do
    it 'saves a new record' do
      user = {id: 2, name: 'Pesho'}
      store.create(user)

      expect(store.find(id: 2)).to eq [user]
    end
  end
end

describe HashStore do
  it_behaves_like 'a data store'
end

describe ArrayStore do
  it_behaves_like 'a data store'
end
