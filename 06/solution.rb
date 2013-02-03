require 'bigdecimal'
require 'bigdecimal/util'

class ExchangeRate
  class Unknown < RuntimeError
  end

  def initialize
    @rates = {}
  end

  def set(from_currency, to_currency, rate)
    return if from_currency == to_currency

    @rates[tuple(from_currency, to_currency)] = rate
    @rates[tuple(to_currency, from_currency)] = 1.to_d / rate
  end

  def get(from_currency, to_currency)
    return 1.to_d if from_currency == to_currency
    @rates[tuple(from_currency, to_currency)]
  end

  def convert(from_currency, to_currency, amount)
    rate = get(from_currency, to_currency)
    raise Unknown, "Cannot convert from #{from_currency} to #{to_currency}" unless rate

    amount * rate
  end

  private

  def tuple(a, b)
    :"#{a}-#{b}"
  end
end

class Money
  class IncompatibleCurrencies < RuntimeError
  end

  include Comparable
  attr_reader :amount, :currency

  def initialize(amount, currency)
    @amount, @currency = amount, currency
  end

  def in(new_currency, exchange_rate)
    new_amount = exchange_rate.convert(currency, new_currency, amount)
    Money.new new_amount, new_currency
  end

  def *(other)
    apply_numeric :*, other
  end

  def /(other)
    apply_numeric :/, other
  end

  def +(money)
    apply_monetary :+, money
  end

  def -(money)
    apply_monetary :-, money
  end

  def ==(money)
    apply_comparison :==, money
  end

  def <=>(money)
    apply_comparison :<=>, money
  end

  def to_s
    "#{'%.2f' % amount} #{currency}"
  end

  private

  def apply_comparison(operation, argument)
    raise ArgumentError, "Comparing Money with #{argument.class}" unless argument.kind_of?(Money)
    raise IncompatibleCurrencies unless argument.currency == currency

    amount.public_send(operation, argument.amount)
  end

  def apply_numeric(operation, argument)
    if argument.kind_of?(Numeric)
      Money.new amount.public_send(operation, argument), currency
    else
      raise ArgumentError
    end
  end

  def apply_monetary(operation, argument)
    if argument.kind_of?(Money)
      raise IncompatibleCurrencies unless argument.currency == currency
      Money.new amount.public_send(operation, argument.amount), currency
    else
      raise ArgumentError
    end
  end
end
