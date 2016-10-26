RSpec.describe 'Task 2' do
  describe 'README' do
    it 'works for all examples' do
      order = {
        dessert: {
          type: 'cake',
          variant: 'chocolate',
          rating: 10,
          comments: [
            {text: 'So sweet!'},
            {text: 'A perfect blend of milk chocolate and cookies. With a cherry on top.'}
          ]
        }
      }

      expect(order.fetch_deep('dessert.variant')).to eq('chocolate')
      expect(order.fetch_deep('dessert.comments.0.text')).to eq('So sweet!')

      dessert = {
        type: 'cake',
        'variant' => 'chocolate'
      }

      expect(dessert.fetch_deep('type')).to eq('cake')
      expect(dessert.fetch_deep('variant')).to eq('chocolate')

      order = {
        dessert: {type: 'cake', variant: 'chocolate'}
      }
      shape = {
        food: 'dessert.type',
        taste: 'dessert.variant'
      }

      expect(order.reshape(shape)).to eq({food: 'cake', taste: 'chocolate'})

      order = {
        dessert: {type: 'cake', variant: 'chocolate'}
      }
      shape = {
        food: {type: 'dessert.type', taste: 'dessert.variant'}
      }

      expect(order.reshape(shape)).to eq({food: {type: 'cake', taste: 'chocolate'}})

      inventory = [
        {item: {type: 'musaka', price: 4.0, quantity: 30}},
        {item: {type: 'cake',   price: 3.5, quantity: 20}}
      ]
      shape = {food: 'item.type', price: 'item.price'}

      expect(inventory.reshape(shape)).to eq([{food: 'musaka', price: 4.0}, {food: 'cake', price: 3.5}])
    end
  end

  describe 'Hash#fetch_deep' do
    it 'can look up simple values' do
      input = {meal: 'musaka'}

      expect(input.fetch_deep('meal')).to eq 'musaka'
    end

    it 'can look up deeply nested values' do
      input = {
        order: {
          meal: {type: 'dessert'}
        }
      }

      expect(input.fetch_deep('order.meal.type')).to eq 'dessert'
    end

    it 'can find values in arrays by index' do
      input = {
        orders: [
          {meal: 'cake'},
          {meal: 'ice cream'}
        ]
      }

      expect(input.fetch_deep('orders.0.meal')).to eq 'cake'
      expect(input.fetch_deep('orders.1.meal')).to eq 'ice cream'
    end

    it 'returns nil for non-existant keys' do
      input = {orders: []}

      expect(input.fetch_deep('meal')).to be nil
      expect(input.fetch_deep('meal.0.type')).to be nil
    end

    it 'is indifferent to symbols and strings' do
      input = {order: 'cake', 'dessert' => 'ice cream'}

      expect(input.fetch_deep('order')).to eq 'cake'
      expect(input.fetch_deep('dessert')).to eq 'ice cream'
    end

    it 'does not modify the input hash' do
      input = {menu: {order: 'cake', 'dessert' => 'ice cream', 3 => 4}}

      input.fetch_deep('menu.order')
      input.fetch_deep('menu.dessert')

      expect(input).to eq menu: {order: 'cake', 'dessert' => 'ice cream', 3 => 4}
    end

    it 'can fetch integer-like keys from hashes' do
      input = {nested: {'1' => :a, '2': :b}}

      expect(input.fetch_deep('nested.1')).to eq :a
      expect(input.fetch_deep('nested.2')).to eq :b
    end
  end

  describe 'Hash#reshape' do
    it 'can rename fields' do
      input = {name: 'Georgi'}
      shape = {first_name: 'name'}
      output = {first_name: 'Georgi'}

      expect(input.reshape(shape)).to eq output
    end

    it 'can extract fields to nested objects' do
      input = {
        profile: {name: 'Georgi'}
      }

      shape = {me: {first_name: 'profile.name'}}
      output = {me: {first_name: 'Georgi'}}

      expect(input.reshape(shape)).to eq output
    end

    it 'can create nested objects' do
      input = {name: 'Georgi'}
      shape = {
        profile: {first_name: 'name'}
      }

      output = {
        profile: {first_name: 'Georgi'}
      }

      expect(input.reshape(shape)).to eq output
    end

    it 'assigns nil to unknown keys' do
      input = {a: 1}
      shape = {b: 'b'}

      expect(input.reshape(shape)).to eq b: nil
    end

    it 'can extract fields from arrays by index' do
      input = {
        users: [
          {name: 'Georgi'},
          {name: 'Ivan'}
        ]
      }
      shape = {
        me: {
          first_name: 'users.0.name',
          second_name: 'users.1.name'
        }
      }

      output = {
        me: {
          first_name: 'Georgi',
          second_name: 'Ivan'
        }
      }

      expect(input.reshape(shape)).to eq output
    end

    it 'does not modify the input hash' do
      input = {
        menu: {
          order: 'cake',
          'dessert' => 'ice cream',
          3 => 4
        }
      }

      shape = {
        order: 'menu.order',
        dessert: 'menu.dessert'
      }

      input.reshape(shape)

      expect(input).to eq menu: {
        order: 'cake',
        'dessert' => 'ice cream',
        3 => 4
      }
    end
  end

  describe 'Array#reshape' do
    it 'maps each element with the result of Hash#fetch_deep' do
      input = [
        {order: {item: 'meal'}},
        {order: {item: 'dessert'}}
      ]

      shape = {type: 'order.item'}

      expect(input.reshape(shape)).to eq [
        {type: 'meal'},
        {type: 'dessert'}
      ]
    end
  end
end
