class HashStore
  attr_reader :storage

  def initialize
    @storage = {}
    @id_counter = 0
  end

  def next_id
    @id_counter += 1
  end

  def create(record)
    @storage[record[:id]] = record
  end

  def find(query)
    @storage.values.select do |record|
      query.all? { |key, value| record[key] == value }
    end
  end

  def delete(query)
    find(query).each { |record| @storage.delete(record[:id]) }
  end

  def update(id, record)
    return unless @storage.key? id

    @storage[id] = record
  end
end

class ArrayStore
  attr_reader :storage

  def initialize
    @storage = []
    @id_counter = 0
  end

  def next_id
    @id_counter += 1
  end

  def create(record)
    @storage << record
  end

  def find(query)
    @storage.select { |record| match_record? query, record }
  end

  def delete(query)
    @storage.reject! { |record| match_record? query, record }
  end

  def update(id, record)
    index = @storage.find_index { |record| record[:id] == id }
    return unless index

    @storage[index] = record
  end

  private

  def match_record?(query, record)
    query.all? { |key, value| record[key] == value }
  end
end

module DataModelClassMethods
  def attributes(*attributes)
    return @attributes if attributes.empty?

    @attributes = attributes + [:id]

    @attributes.each do |attribute|
      define_singleton_method "find_by_#{attribute}" do |value|
        where(attribute => value)
      end

      define_method(attribute)       { @attributes[attribute] }
      define_method("#{attribute}=") { |value| @attributes[attribute] = value }
    end
  end

  def data_store(store = nil)
    return @data_store unless store

    @data_store = store
  end

  def where(query)
    query.keys.reject { |key| @attributes.include? key }.each do |key|
      raise DataModel::UnknownAttributeError.new(key)
    end

    map_to_model_instances data_store.find(query)
  end

  def all
    where({})
  end

  private

  def map_to_model_instances(records)
    records.map { |record| new(record) }
  end
end

class DataModel
  class UnknownAttributeError < ArgumentError
    def initialize(attribute_name)
      super "Unknown attribute #{attribute_name}"
    end
  end

  class DeleteUnsavedRecordError < StandardError
  end

  extend DataModelClassMethods

  def initialize(attributes = {})
    @attributes = attributes.select { |key, _| self.class.attributes.include? key }
  end

  def save
    if id
      data_store.update(id, @attributes)
    else
      self.id = data_store.next_id
      data_store.create(@attributes)
    end

    self
  end

  def delete
    raise DeleteUnsavedRecordError.new unless id

    data_store.delete(id: id)
  end

  def ==(other)
    return id == other.id if id && other.id

    equal? other
  end

  private

  def data_store
    self.class.data_store
  end
end
