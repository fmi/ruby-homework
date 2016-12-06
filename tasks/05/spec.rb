RSpec.describe DataModel do
  let(:data_store) { HashStore.new }
  let(:user_model) do
    store = data_store

    Class.new DataModel do
      attributes :first_name, :last_name, :age
      data_store store
    end
  end

  it 'creates attribute accessors' do
    record = user_model.new
    record.first_name = 'Pesho'
    record.last_name  = 'Petrov'

    expect(record.first_name).to eq 'Pesho'
    expect(record.last_name ).to eq 'Petrov'
  end

  it 'has attributes and data_model getters' do
    expect(user_model.attributes).to include :first_name
    expect(user_model.attributes).to include :last_name
    expect(user_model.data_store).to eq data_store
  end

  it 'accepts attributes when initializing' do
    record = user_model.new(
      first_name: 'Pesho',
      last_name: 'Petrov',
      useless_attribute: 42
    )

    expect(record.first_name).to eq 'Pesho'
    expect(record.last_name ).to eq 'Petrov'
    expect(record.age       ).to be nil
  end

  it 'has #find_by_<attribute> methods' do
    record = user_model.new(first_name: 'Ivan', last_name: 'Ivanov')
    record.save

    expect(user_model.find_by_first_name('Ivan').map(&:id)).to eq [record.id]
    expect(user_model.find_by_last_name('Ivanov').map(&:id)).to eq [record.id]
  end

  describe 'id generation' do
    it 'creates id on first save and does not change it' do
      record = user_model.new(first_name: 'Ivan', last_name: 'Ivanov')
      expect(record.id).to be nil

      record.save

      expect(record.id).to eq 1

      id = record.id
      record.save

      expect(record.id).to eq 1
    end

    it 'does not reuse ids' do
      ivan = user_model.new(first_name: 'Ivan')
      ivan.save
      expect(ivan.id).to eq 1

      ivan.delete

      georgi = user_model.new(first_name: 'Georgi')
      georgi.save
      expect(georgi.id).to eq 2
    end

    it 'does not break when there are two models with the same store' do
      store = data_store
      admin_model = Class.new DataModel do
        attributes :first_name
        data_store store
      end

      ivan = user_model.new(first_name: 'Ivan')
      ivan.save
      expect(ivan.id).to eq 1

      picture = admin_model.new(first_name: 'Georgi')
      picture.save
      expect(picture.id).to eq 2
    end
  end

  describe 'equality comparison' do
    it 'compares by id if both records are saved' do
      ivan = user_model.new(first_name: 'Ivan')
      ivan.save

      petar = user_model.new(first_name: 'Petar')
      petar.save

      expect(ivan).to_not eq petar
      expect(ivan).to eq ivan

      modified_ivan = user_model.where(id: ivan.id).first
      modified_ivan.first_name = 'Gosho'

      expect(ivan).to eq modified_ivan
    end

    it 'uses #equal? if there are no ids' do
      first_user  = user_model.new(first_name: 'Ivan')
      second_user = user_model.new(first_name: 'Ivan')

      expect(first_user).to_not eq second_user
      expect(first_user).to eq first_user
    end
  end

  describe '.where' do
    before do
      user_model.new(first_name: 'Ivan', last_name: 'Ivanov').save
      user_model.new(first_name: 'Ivan', last_name: 'Petrov').save
      user_model.new(first_name: 'Georgi').save
    end

    it 'finds records by attributes' do
      records = user_model.where(first_name: 'Ivan').map(&:last_name)
      expect(records).to match_array ['Ivanov', 'Petrov']
    end

    it 'finds records by multiple attributes' do
      records = user_model.where(
        first_name: 'Ivan',
        last_name: 'Ivanov'
      ).map(&:last_name)

      expect(records).to eq ['Ivanov']
    end

    it 'returns empty collection when nothing is found' do
      expect(user_model.where(first_name: 'Petar')).to be_empty
    end

    it 'raises an error if the query is by an unknown key' do
      expect { user_model.where(middle_name: 'Ivanov') }.to raise_error(
        DataModel::UnknownAttributeError,
        'Unknown attribute middle_name'
      )
    end
  end

  describe '#delete' do
    it 'deletes only the record for which it is called' do
      ivan = user_model.new(first_name: 'Ivan').save
      user_model.new(first_name: 'Petar').save
      user_model.new(first_name: 'Georgi').save

      ivan.delete

      all_records = user_model.where({}).map(&:first_name)
      expect(all_records).to match_array ['Petar', 'Georgi']
    end

    it 'raises an error if the record is not saved' do
      expect { user_model.new(first_name: 'Ivan').delete }.to raise_error(
        DataModel::DeleteUnsavedRecordError
      )
    end
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

  describe '#find' do
    it 'can find elements by attributes' do
      user = {id: 2, name: 'Pesho'}
      store.create(user)

      expect(store.find(id: 2)).to eq [user]
      expect(store.find(name: 'Pesho')).to eq [user]

      expect(store.find(id: 1)).to be_empty
      expect(store.find(age: 42)).to be_empty
    end
  end

  describe '#update' do
    it 'updates the attributes of a record with a given ID' do
      user = {id: 2, name: 'Pesho'}
      store.create(user)
      store.update(2, {id: 2, name: 'Georgi'})

      expect(store.find(id: 2)).to eq [{id: 2, name: 'Georgi'}]
    end

    it 'only updates records with the correct IDs' do
      georgi = {id: 1, name: 'Georgi'}
      pesho = {id: 2, name: 'Pesho'}
      store.create(georgi)
      store.create(pesho)

      store.update(2, {id: 2, name: 'Sasho'})

      expect(store.find(id: 1)).to eq [georgi]
      expect(store.find(id: 2)).to eq [{id: 2, name: 'Sasho'}]
    end
  end

  describe '#delete' do
    it 'can delete multiple records with a single query' do
      first_pesho  = {id: 1, name: 'Pesho'}
      second_pesho = {id: 2, name: 'Pesho'}
      gosho = {id: 3, name: 'Gosho'}

      store.create(first_pesho)
      store.create(second_pesho)
      store.create(gosho)

      store.delete(name: 'Pesho')

      expect(store.find({})).to eq [gosho]
    end
  end
end

describe HashStore do
  it_behaves_like 'a data store'
end

describe ArrayStore do
  it_behaves_like 'a data store'
end
