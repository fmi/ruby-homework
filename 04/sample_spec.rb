describe PrivacyFilter do
  it 'obfuscates simple emails' do
    PrivacyFilter.new('Contact: someone@example.com').filtered.should eq 'Contact: [EMAIL]'
  end

  it 'allows email hostname to be preserved' do
    filter = PrivacyFilter.new 'someone@example.com'
    filter.preserve_email_hostname = true
    filter.filtered.should eq '[FILTERED]@example.com'
  end

  it 'allows email usernames to be partially preserved' do
    filter = PrivacyFilter.new 'someone@example.com'
    filter.partially_preserve_email_username = true
    filter.filtered.should eq 'som[FILTERED]@example.com'
  end

  it 'filters phone numbers' do
    PrivacyFilter.new('Reach me at: 0885123123').filtered.should eq 'Reach me at: [PHONE]'
  end

  it 'allows country code to be preserved for internationally-formatted phone numbers' do
    filter = PrivacyFilter.new 'Phone: +35925551212'
    filter.preserve_phone_country_code = true
    filter.filtered.should eq 'Phone: +359 [FILTERED]'
  end
end

describe Validations do
  it 'allows validation for emails' do
    Validations.email?('foo@bar.com').should be_true
    Validations.email?('invalid@email').should be_false
  end

  it 'returns boolean true or false' do
    Validations.email?('foo@bar.com').should be(true)
    Validations.email?('invalid@email').should be(false)
  end

  it 'validates phone numbers' do
    Validations.phone?('+35929555111').should be_true
    Validations.phone?('123123').should be_false
  end

  it 'validates hostnames' do
    Validations.hostname?('domain.tld').should be_true
    Validations.hostname?('not-a-hostname').should be_false
  end

  it 'validates IP addresses' do
    Validations.ip_address?('1.2.3.4').should be_true
  end

  it 'validates numbers' do
    Validations.number?('42').should be_true
    Validations.number?('x').should be_false
    Validations.number?('42.42').should be_true
  end

  it 'validates integers' do
    Validations.integer?('42').should be_true
    Validations.integer?('universe').should be_false
  end

  it 'validates dates' do
    Validations.date?('2012-11-19').should be_true
    Validations.date?('Jamaica').should be_false
  end

  it 'validates times' do
    Validations.time?('12:00:00').should be_true
    Validations.time?('not a time').should be_false
  end

  it 'validates datetime values' do
    Validations.date_time?('2012-11-19 19:00:00').should be_true
    Validations.date_time?('foo').should be_false
  end
end
