describe PrivacyFilter do
  it 'obfuscates simple emails' do
    PrivacyFilter.new('Contact: someone@example.com').filtered.should eq 'Contact: [EMAIL]'
    PrivacyFilter.new('someone@example.com').filtered.should eq '[EMAIL]'
    PrivacyFilter.new('Contact:someone@example.com').filtered.should eq 'Contact:[EMAIL]'
    PrivacyFilter.new('Contact: 1someone@example.com,someone.new@sub.example123.co.uk').filtered.should eq 'Contact: [EMAIL]+[EMAIL]'
  end

  it 'allows email hostname to be preserved' do
    filter = PrivacyFilter.new 'someone@example.com'
    filter.preserve_email_hostname = true
    filter.filtered.should eq '[FILTERED]@example.com'
    
    filter1 = PrivacyFilter.new 'some12-+3@exa.mple.com'
    filter1.preserve_email_hostname = true
    filter1.filtered.should eq '[FILTERED]@exa.mple.com'
  end

  it 'allows email usernames to be partially preserved' do
    filter = PrivacyFilter.new 'someone@example.com'
    filter.partially_preserve_email_username = true
    filter.filtered.should eq 'som[FILTERED]@example.com'
  end

  it 'filters phone numbers' do
    PrivacyFilter.new('Reach me at: 0885123123').filtered.should eq 'Reach me at: [PHONE]'
    PrivacyFilter.new('Reach me at: 00359885123123').filtered.should eq 'Reach me at: [PHONE]'
    PrivacyFilter.new('Reach me at: +359885123123').filtered.should eq 'Reach me at: [PHONE]'
  end

  it 'allows country code to be preserved for internationally-formatted phone numbers' do
    filter = PrivacyFilter.new 'Phone: +35925551212'
    filter.preserve_phone_country_code = true
    filter.filtered.should eq 'Phone: +359 [FILTERED]'
    
    filter1 = PrivacyFilter.new 'Phone: 0025 5512 12255'
    filter1.preserve_phone_country_code = true
    filter1.filtered.should eq 'Phone: 0025 [FILTERED]'
  end

  it 'doesn\'t allow country code to be preserved for normally-formatted phone numbers' do
    filter = PrivacyFilter.new 'Phone: 025551212'
    filter.preserve_phone_country_code = true
    filter.filtered.should eq 'Phone: [PHONE]'
  end
end

describe Validations do
  it 'allows validation for emails' do
    Validations.email?('foo@bar.com').should be_true
    Validations.email?('invalid@email').should be_false
  end

  it 'returns boolean true or false' do
    Validations.email?('foo@bar.com').should be(true)
    Validations.email?('foo.bar-emo1234+@ba-r.co.uk').should be(true)
    Validations.email?('invalid@email').should be(false)
    Validations.email?('inva$lid@email.com').should be(false)
    Validations.email?('_inva$lid@email.com').should be(false)
  end
  
  it 'validates hostnames' do
    Validations.hostname?('domain.tld').should be_true
    Validations.hostname?('sub0domain.not-a-hostname.com').should be_true
    Validations.hostname?('sub-sub.sub.not123a-hostname.co.uk').should be_true
    Validations.hostname?('not-a-hostname').should be_false
    Validations.hostname?('not-a-hostname-.com').should be_false
    Validations.hostname?('not-a-hostname.c-m').should be_false
    Validations.hostname?('not-a-hostname.com.12').should be_false
  end

  it 'validates phone numbers' do
    Validations.phone?('+35929555111').should be_true
    Validations.phone?('0040 295551111').should be_true
    Validations.phone?('0896841090').should be_true
    Validations.phone?('0(896) 84-10-90').should be_true
    Validations.phone?('+359 89 684-109-05').should be(true)
    Validations.phone?('123123').should be_false
    Validations.phone?('0896 - 841090').should be(false)
    Validations.phone?('+896 701 841 090 808').should be_false
    Validations.phone?('+896 701 841 090 ').should be_false
    Validations.phone?('+0896 701 841 090').should be_false
  end

  it 'validates IP addresses' do
    Validations.ip_address?('1.2.3.4').should be(true)
    Validations.ip_address?('193.22.38.0').should be(true)
    Validations.ip_address?('10.0.0.4').should be(true)
    Validations.ip_address?('255.201.3.43').should be(true)
    Validations.ip_address?('1.2.3.403').should be(false)
    Validations.ip_address?('1.02.3.4').should be(false)
    Validations.ip_address?('100.299.39.40').should be(false)
    Validations.ip_address?('2555.2.3.40').should be(false)
  end

  it 'validates numbers' do
    Validations.number?('42').should be(true)
    Validations.number?('x').should be(false)
    Validations.number?('-42.42').should be(true)
    Validations.number?('42.-42').should be(false)
    Validations.number?('-0.42').should be(true)
    Validations.number?('02.42').should be(false)
    Validations.number?('42.').should be(false)
    Validations.number?('0').should be(true)
  end

  it 'validates integers' do
    Validations.integer?('42').should be(true)
    Validations.integer?('20.3').should be(false)
    Validations.integer?('--2132').should be(false)
    Validations.integer?('094234').should be(false)
    Validations.integer?('0').should be(true)
    Validations.integer?('universe').should be(false)
  end

  it 'validates dates' do
    Validations.date?('2012-11-19').should be(true)
    Validations.date?('3012-01-31').should be(true)
    Validations.date?('12-11-19').should be(false)
    Validations.date?('2012-00-19').should be(false)
    Validations.date?('2012-11-00').should be(false)
    Validations.date?('2012-11-32').should be(false)
    Validations.date?('Jamaica').should be(false)
  end

  it 'validates times' do
    Validations.time?('12:00:00').should be_true
    Validations.time?('22:50:00').should be(true)
    Validations.time?('12:59:05').should be(true)
    Validations.time?('12-00-00').should be(false)
    Validations.time?('12:00:60').should be(false)
    Validations.time?('2:00:00').should be(false)
    Validations.time?('24:00:00').should be(false)
    Validations.time?('not a time').should be_false
  end

  it 'validates datetime values' do
    Validations.date_time?('2012-11-19 19:00:00').should be_true
    Validations.date_time?('2012-11-19T19:00:00').should be(true)
    Validations.date_time?('2012-11-19  19:00:00').should be(false)
    Validations.date_time?('2012-11-19 T19:00:00').should be(false)
    Validations.date_time?('foo').should be_false
  end
end
