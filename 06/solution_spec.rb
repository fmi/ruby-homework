describe ExchangeRate do
  let(:rate) { ExchangeRate.new }

  it 'can be instantiated' do
    rate
  end

  describe '#set' do
    it 'defines an exchange rate between A and B' do
      rate.set :EUR, :BGN, '1.95583'.to_d
    end

    it 'allows rates to be updated if called multiple times' do
      rate.set(:USD, :BGN, '1.5'.to_d)

      expect do
        rate.set(:USD, :BGN, '1.49'.to_d)
      end.to change { rate.get(:USD, :BGN) }.from('1.5'.to_d).to('1.49'.to_d)
    end

    it 'sets the exchange rate in both directions' do
      rate.set(:EUR, :BGN, 2.to_d)
      rate.get(:EUR, :BGN).should eq 2.to_d
      rate.set(:BGN, :EUR, '0.8'.to_d)
      rate.get(:EUR, :BGN).should eq '1.25'.to_d
    end
  end

  describe '#get' do
    it 'returns nil for non-existing rates' do
      rate.get(:EUR, :BGN).should be_nil
    end

    it 'returns an existing exchange rate between A and B' do
      rate.set :EUR, :BGN, '1.96'.to_d
      rate.get(:EUR, :BGN).should eq '1.96'.to_d
    end

    it 'returns the reversed rate between A and B, too' do
      rate.set :EUR, :BGN, '2'.to_d
      rate.get(:BGN, :EUR).should eq '0.5'.to_d
    end

    it 'always returns 1 as the exchange rate between two identical currencies' do
      rate.get(:JPY, :JPY).should eq 1.to_d
    end

    it 'does not allow changing the exchange rate between two identical currencies' do
      rate.set :EUR, :EUR, 2.to_d
      rate.get(:EUR, :EUR).should eq 1.to_d
    end
  end

  describe '#convert' do
    it 'raises an ExchangeRate::Unknown exception when the rate is not defined' do
      expect do
        rate.convert :EUR, :BGN, 42.to_d
      end.to raise_error(ExchangeRate::Unknown)
    end

    it 'converts from A to B using an existing rate A -> B' do
      rate.set :EUR, :BGN, '1.95583'.to_d
      rate.convert(:EUR, :BGN, 100.to_d).should eq '195.583'.to_d.to_d
    end

    it 'converts from B to A using an existing rate A -> B' do
      rate.set :EUR, :BGN, 2.to_d
      rate.convert(:BGN, :EUR, 100.to_d).should eq 50.to_d
    end

    it 'works for identical currencies without defining any rates' do
      rate.convert(:JPY, :JPY, 123.to_d).should eq 123.to_d
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
    Money.new('12.1'.to_d, :USD).to_s.should eq '12.10 USD'
    Money.new(42.to_d, :USD).to_s.should eq '42.00 USD'
  end

  describe 'convertion' do
    it 'allows convertion to other currencies' do
      rate = ExchangeRate.new
      rate.set(:EUR, :BGN, '1.96'.to_d)

      euros = Money.new 20.to_d, :EUR
      levas = euros.in(:BGN, rate)

      levas.amount.should eq '39.2'.to_d
      levas.currency.should eq :BGN
    end

    it 'does not change the amount if the same currency is passed' do
      Money.new(5.to_d, :EUR).in(:EUR, ExchangeRate.new).amount.should eq 5.to_d
    end

    it 'raises an ExchangeRate::Unknown exception for unknown rates' do
      expect do
        Money.new(10.to_d, :EUR).in(:BGN, ExchangeRate.new)
      end.to raise_error(ExchangeRate::Unknown)
    end
  end

  describe 'arithmetic' do
    [:*, :/].each do |operation|
      it "allows #{operation} with a numeric" do
        bucks   = Money.new(5.to_d, :USD)
        numeric = 42

        result = bucks.public_send(operation, numeric)
        result.currency.should eq :USD
        result.amount.should eq bucks.amount.public_send(operation, numeric)
      end

      it "#{operation} with money objects raises an ArgumentError" do
        expect do
          Money.new(10.to_d, :USD).public_send(operation, Money.new(5.to_d, :USD))
        end.to raise_error(ArgumentError)
      end
    end

    [:+, :-].each do |operation|
      it "#{operation} with numeric objects raises an ArgumentError" do
        expect do
          Money.new(10.to_d, :USD).public_send(operation, 42)
        end.to raise_error(ArgumentError)
      end

      it "allows #{operation} with money with the same currency" do
        a = Money.new(15.to_d, :EUR)
        b = Money.new('2.45'.to_d, :EUR)

        result = a.public_send(operation, b)
        result.currency.should eq :EUR
        result.amount.should eq a.amount.public_send(operation, b.amount)
      end

      it "raises Money::IncompatibleCurrencies for #{operation} with money with different currencies" do
        expect do
          Money.new(6.to_d, :BGN).public_send(operation, Money.new(12.to_d, :EUR))
        end.to raise_error(Money::IncompatibleCurrencies)
      end
    end

    [:+, :-, :*, :/].each do |operation|
      it "#{operation} with other objects raises an ArgumentError" do
        expect do
          Money.new(10.to_d, :USD).public_send(operation, 'foobar')
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'comparison' do
    it 'works when currencies are the same' do
      a = Money.new '12.45'.to_d, :USD
      b = Money.new '-2.45'.to_d, :USD

      (a < b).should be_false
      (a <= b).should be_false
      (a <=> b).should eq 1
      (a >= b).should be_true
      (a > b).should be_true

      a = Money.new '2.45'.to_d, :USD
      b = Money.new '2.451'.to_d, :USD

      (a < b).should be_true
      (a <= b).should be_true
      (a <=> b).should eq -1
      (a >= b).should be_false
      (a > b).should be_false
    end

    it 'works for equality when currencies are the same' do
      (Money.new('12.45'.to_d, :BGN) == Money.new('12.45'.to_d, :BGN)).should be_true
      (Money.new('12.45'.to_d, :BGN) == Money.new('12.451'.to_d, :BGN)).should be_false
    end

    [:<=>, :==, :<, :<=, :>, :>=].each do |operation|
      it "with #{operation} raises ArgumentError when comparing with other objects" do
        expect do
          Money.new(12.to_d, :USD).public_send(operation, :larodi)
        end.to raise_error(ArgumentError)
      end

      it "with #{operation} raises IncompatibleCurrencies when currencies differ" do
        expect do
          Money.new(12.to_d, :USD).public_send(operation, Money.new(10.to_d, :BGN))
        end.to raise_error(Money::IncompatibleCurrencies)
      end

    end
  end
end
