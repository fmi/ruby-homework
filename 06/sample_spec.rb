describe ExchangeRate do
  let(:rate) { ExchangeRate.new }

  describe '#set' do
    it 'defines an exchange rate between A and B' do
      rate.set :EUR, :BGN, '1.95583'.to_d
    end
  end

  describe '#get' do
    it 'returns an existing exchange rate between A and B' do
      rate.set :EUR, :BGN, '1.96'.to_d
      rate.get(:EUR, :BGN).should eq '1.96'.to_d
    end
  end

  describe '#convert' do
    it 'converts from A to B using an existing rate A -> B' do
      rate.set :EUR, :BGN, '1.95583'.to_d
      rate.convert(:EUR, :BGN, 100.to_d).should eq '195.583'.to_d.to_d
    end
  end
end

describe Money do
  it 'can be constructed' do
    Money.new(10.to_d, :BGN)
  end

  it 'has accessors for amount and currency' do
    price = Money.new(42.to_d, :USD)
    price.amount.should eq 42.to_d
    price.currency.should eq :USD
  end

  it 'has a custom to_s representation' do
    Money.new('12.99'.to_d, :USD).to_s.should eq '12.99 USD'
  end

  describe 'convertion' do
    it 'allows convertion to other currencies' do
      rate = ExchangeRate.new
      rate.set(:EUR, :BGN, '1.96'.to_d)

      euros = Money.new 10.to_d, :EUR
      levas = euros.in(:BGN, rate)

      levas.amount.should eq '19.6'.to_d
      levas.currency.should eq :BGN
    end
  end

  describe 'arithmetic' do
    let(:bucks)  { Money.new(5.to_d, :USD) }
    let(:a_buck) { Money.new(1.to_d, :USD) }

    it 'works for multiplication with numerics' do
      result = bucks * 2

      result.currency.should eq :USD
      result.amount.should eq 10.to_d
    end

    it 'works for division with numerics' do
      result = bucks / 2

      result.currency.should eq :USD
      result.amount.should eq '2.5'.to_d
    end

    it 'works for subtraction with other money' do
      result = bucks - a_buck

      result.currency.should eq :USD
      result.amount.should eq 4.to_d
    end

    it 'works for addition with other money' do
      result = bucks + a_buck

      result.currency.should eq :USD
      result.amount.should eq 6.to_d
    end
  end

  describe 'comparison' do
    it 'works for other money objects' do
      Money.new('2.45'.to_d, :USD).should be <= Money.new('3.45'.to_d, :USD)
    end

    it 'works for equality' do
      Money.new('12.45'.to_d, :BGN).should eq Money.new('12.45'.to_d, :BGN)
    end
  end
end
