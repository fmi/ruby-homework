module Patterns
  TLD           = /\b[a-z]{2,3}(\.[a-z]{2})?\b/i
  HOSTNAME_PART = /\b[0-9A-Za-z]([0-9a-z\-]{,61}[0-9A-Za-z])?\b/i
  DOMAIN        = /\b#{HOSTNAME_PART}\.#{TLD}\b/i
  HOSTNAME      = /\b(#{HOSTNAME_PART}\.)+#{TLD}\b/i
  EMAIL         = /\b(?<username>[a-z0-9][\w_\-+\.]{,200})@(?<hostname>#{HOSTNAME})\b/i
  COUNTRY_CODE  = /[1-9]\d{,2}/
  PHONE_PREFIX  = /((\b|(?<![\+\w]))0(?!0)|(?<country_code>\b00#{COUNTRY_CODE}|\+#{COUNTRY_CODE}))/
  PHONE         = /(?<prefix>#{PHONE_PREFIX})(?<number>[ \-\(\)]{,2}(\d[ \-\(\)]{,2}){6,10}\d)\b/
  ISO_DATE      = /(?<year>\d{4})-(?<month>\d\d)-(?<day>\d\d)/
  ISO_TIME      = /(?<hour>\d\d):(?<minute>\d\d):(?<second>\d\d)/
end

class PrivacyFilter
  attr_accessor :preserve_email_hostname
  attr_accessor :partially_preserve_email_username
  attr_accessor :preserve_phone_country_code

  def initialize(text)
    @text = text
  end

  def filtered
    filter_phone_numbers_in filter_emails_in(@text)
  end

  private

  def filter_emails_in(text)
    text.gsub Patterns::EMAIL do
      filtered_email $~[:username], $~[:hostname]
    end
  end

  def filtered_email(username, hostname)
    if preserve_email_hostname or partially_preserve_email_username
      "#{filtered_email_username(username)}@#{hostname}"
    else
      '[EMAIL]'
    end
  end

  def filtered_email_username(username)
    if partially_preserve_email_username and username.length >= 6
      username[0...3] + '[FILTERED]'
    else
      '[FILTERED]'
    end
  end

  def filter_phone_numbers_in(text)
    text.gsub Patterns::PHONE do
      filtered_phone_number $~[:country_code]
    end
  end

  def filtered_phone_number(country_code)
    if preserve_phone_country_code and country_code.to_s != ''
      "#{country_code} [FILTERED]"
    else
      '[PHONE]'
    end
  end
end

module Validations
  extend self

  def email?(value)
    Email.new(value).valid?
  end

  def phone?(value)
    Phone.new(value).valid?
  end

  def hostname?(value)
    Hostname.new(value).valid?
  end

  def ip_address?(value)
    IpAddress.new(value).valid?
  end

  def number?(value)
    Number.new(value).valid?
  end

  def integer?(value)
    Integer.new(value).valid?
  end

  def date?(value)
    Date.new(value).valid?
  end

  def time?(value)
    Time.new(value).valid?
  end

  def date_time?(value)
    DateTime.new(value).valid?
  end
end

module Validations
  class Validation
    def initialize(value)
      @value = value
    end

    def valid?
      !!validate
    end
  end

  class Email < Validation
    def validate
      @value =~ /\A#{Patterns::EMAIL}\z/
    end
  end

  class Phone < Validation
    def validate
      @value =~ /\A#{Patterns::PHONE}\z/
    end
  end

  class Hostname < Validation
    def validate
      @value =~ /\A#{Patterns::HOSTNAME}\z/
    end
  end

  class IpAddress < Validation
    def validate
      if @value =~ /\A(\d+)\.(\d+)\.(\d+)\.(\d+)\z/
        $~.captures.all? { |byte| (0..255).include? byte.to_i }
      end
    end
  end

  class Number < Validation
    def validate
      @value =~ /\A-?(0|[1-9]\d*)(\.[0-9]+)?\z/
    end
  end

  class Integer < Validation
    def validate
      @value =~ /\A-?(0|[1-9]\d*)\z/
    end
  end

  class Date < Validation
    def validate
      if @value =~ /\A#{Patterns::ISO_DATE}\z/
        month, day = $~[:month].to_i, $~[:day].to_i
        (1..12).include?(month) and (1..31).include?(day)
      end
    end
  end

  class Time < Validation
    def validate
      if @value =~ /\A#{Patterns::ISO_TIME}\z/
        hour, minute, second = $~[:hour].to_i, $~[:minute].to_i, $~[:second].to_i

        (0..23).include?(hour) and (0..59).include?(minute) and (0..59).include?(second)
      end
    end
  end

  class DateTime < Validation
    def validate
      if @value =~ /\A(?<date>#{Patterns::ISO_DATE})[ T](?<time>#{Patterns::ISO_TIME})\z/
        date, time = $~[:date], $~[:time]
        Date.new(date).valid? and Time.new(time).valid?
      end
    end
  end
end
