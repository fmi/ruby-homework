# encoding: utf-8

describe PrivacyFilter do
  def filter(text)
    PrivacyFilter.new(text).filtered
  end

  def filter_email_usernames(text)
    filter = PrivacyFilter.new(text)
    filter.preserve_email_hostname = true
    filter.filtered
  end

  def partially_filter_email_usernames(text)
    filter = PrivacyFilter.new(text)
    filter.partially_preserve_email_username = true
    filter.filtered
  end

  it 'works with blank or whitespace strings and preserves whitespace' do
    filter('').should eq ''
    filter('   ').should eq '   '
    filter(" \n \n ").should eq " \n \n "
  end

  it 'obfuscates simple emails' do
    filter('Contact: someone@example.com').should eq 'Contact: [EMAIL]'
  end

  it 'obfuscates more complicated emails' do
    {
      'some.user+and-more-here@gmail.com' => '[EMAIL]',
      'some.user+and-more-here@nihon.co.jp' => '[EMAIL]',
      'some.user+and-more-here@lawn.co.uk' => '[EMAIL]',
      'larodi@x.com' => '[EMAIL]',
      'xyz@sunny.com.br' => '[EMAIL]',
      'Contact:someone@example.com' => 'Contact:[EMAIL]',
      'Contact: 1someone@example.com,someone.new@sub.example123.co.uk' => 'Contact: [EMAIL],[EMAIL]',
    }.each do |text, filtered|
      filter(text).should eq filtered
    end
  end

  it 'does not filter invalid emails' do
    [
      'Contact me here: _invalid@email.com',
      'And more: someone@invalid.domaintld',
      'someone@invalid.domaintld',
      'someone@invalid.domaint.l.d',
      'Whaa? -@example.com',
    ].each do |text_with_invalid_emails|
      filter(text_with_invalid_emails).should eq text_with_invalid_emails
      filter(text_with_invalid_emails).should eq text_with_invalid_emails
      filter_email_usernames(text_with_invalid_emails).should eq text_with_invalid_emails
      partially_filter_email_usernames(text_with_invalid_emails).should eq text_with_invalid_emails
    end
  end

  it 'allows email hostname to be preserved' do
    filter_email_usernames('someone@example.com').should eq '[FILTERED]@example.com'
    filter_email_usernames('some12-+3@exa.mple.com').should eq '[FILTERED]@exa.mple.com'
  end

  it 'allows email usernames to be partially preserved' do
    partially_filter_email_usernames('someone@example.com').should eq 'som[FILTERED]@example.com'
  end

  it 'filters whole email usernames if too short' do
    partially_filter_email_usernames('me@example.com').should eq '[FILTERED]@example.com'
  end

  it 'does not brake with unicode' do
    partially_filter_email_usernames('За връзка: me@example.com').should eq 'За връзка: [FILTERED]@example.com'
  end

  it 'filters more complex phone numbers' do
    {
      'Reach me at: 0885123123' => 'Reach me at: [PHONE]',
      '+155512345699' => '[PHONE]',
      '+1 555 123-456' => '[PHONE]',
      '+1 (555) 123-456-99' => '[PHONE]',
      '004412125543' => '[PHONE]',
      '0044 1 21 25 543' => '[PHONE]',
    }.each do |text, filtered|
      filter(text).should eq filtered
    end
  end

  it 'does not filter invalid phone numbers' do
    {
      'Reach me at: 0885123' => 'Reach me at: 0885123',
      '0005551234569' => '0005551234569',
      '+1555 123, 55555' => '+1555 123, 55555',
      '95551212' => '95551212',
    }.each do |text, filtered|
      filter(text).should eq filtered
    end
  end

  it 'preserves whitespace around phones' do
    filter(' +359881212-12-1 2 or...').should eq ' [PHONE] or...'
  end

  it 'filters more than one phone or email' do
    text = "
      Contacts

      Phones: +1 (555) 123-456-99 or 004412125543
      Email: contact@company.co.uk or sales@office.us
    "

    filtered = "
      Contacts

      Phones: [PHONE] or [PHONE]
      Email: [EMAIL] or [EMAIL]
    "

    filter(text).should eq filtered
  end

  it 'allows country code to be preserved for internationally-formatted phone numbers' do
    {
      'Phone: +359 2 555-1212' => 'Phone: +359 [FILTERED]',
      'Phone: +35925551212' => 'Phone: +359 [FILTERED]',
      'Phone: 08825551212' => 'Phone: [PHONE]',
      'Phone: 0 88 255-512 12 !' => 'Phone: [PHONE] !',
      'Phone: 0025 5512 12255' => 'Phone: 0025 [FILTERED]',
    }.each do |text, filtered|
      filter = PrivacyFilter.new(text)
      filter.preserve_phone_country_code = true
      filter.filtered.should eq filtered
    end
  end

  it 'separates preserved country code from filtered phone with a space' do
    {
      'Phone: 0025 (55) 12 12255' => 'Phone: 0025 [FILTERED]',
      'Phone: 0025(55) 12 12255' => 'Phone: 0025 [FILTERED]',
      'Phone: +25( 55 )12 12255' => 'Phone: +25 [FILTERED]',
    }.each do |text, filtered|
      filter = PrivacyFilter.new(text)
      filter.preserve_phone_country_code = true
      filter.filtered.should eq filtered
    end
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

  it 'can validate more complex emails' do
    {
      'someone.else@example.org' => true,
      'someone.else+and.some-more@foo.org.uk' => true,
      'someone.else+and.some-more@foo.org.invalidtld' => false,
      'x@@foo.org' => false,
      '_x@foo.org' => false,
      '42@universe.com' => true,
      ' foo@universe.com' => false,
      'foo@universe.com ' => false,
    }.each do |email, valid|
      Validations.email?(email).should be(valid)
    end
  end

  it 'does not break on emails in multiline strings' do
    Validations.email?("foo@bar.com\nwat?").should be_false
  end

  it 'validates phone numbers' do
    Validations.phone?('+35929555111').should be_true
    Validations.phone?('123123').should be_false
  end

  it 'can validate more complex phone numbers' do
    {
      '0885123123' => true,
      '+155512345699' => true,
      '+1 555 123-456' => true,
      '+101 555 123-456-12' => true,
      '+1 (555) 123-456-99' => true,
      '004412125543' => true,
      '0044 1 21 25 543' => true,
      ' 0044 1 21 25 543 ' => false,
      'Why? 0044 1 21 25 543' => false,
      '0885123' => false,
      '0005551234569' => false,
      '+1555 123, 55555' => false,
      '95551212' => false,
      '+35929555111' => true,
      '0040 295551111' => true,
      '0896841090' => true,
      '0(896) 84-10-90' => true,
      '+359 89 684-109-05' => true,
      '123123' => false,
      '0896 - 841090' => false,
      '+896 701 841 090 808' => false,
      '+896 701 841 090 ' => false,
      '+0896 701 841 090' => false,
    }.each do |phone, valid|
      Validations.phone?(phone).should be(valid)
    end
  end

  it 'does not break on phones in multiline strings' do
    Validations.phone?("0885123123\nwat?").should be_false
  end

  it 'validates hostnames' do
    Validations.hostname?('domain.tld').should be_true
    Validations.hostname?('some.long-subdomain.domain.co.ul').should be_true
    Validations.hostname?('localhost').should be_false
    Validations.hostname?('1.2.3.4.xip.io').should be_true
    Validations.hostname?('x.io').should be_true
    Validations.hostname?('sub0domain.not-a-hostname.com').should be_true
    Validations.hostname?('sub-sub.sub.not123a-hostname.co.uk').should be_true
    Validations.hostname?('not-a-hostname').should be_false
    Validations.hostname?('not-a-hostname-.com').should be_false
    Validations.hostname?('not-a-hostname.c-m').should be_false
    Validations.hostname?('not-a-hostname.com.12').should be_false
  end

  it 'handles multiline strings in hostname validation properly' do
    Validations.hostname?("foo.com\n").should be_false
    Validations.hostname?("foo.com\nbar.com").should be_false
  end

  it 'validates IP addresses' do
    Validations.ip_address?('1.2.3.4').should be_true
    Validations.ip_address?('300.2.3.4').should be_false
    Validations.ip_address?('0.0.0.0').should be_true
    Validations.ip_address?('255.255.255.255').should be_true
  end

  it 'handles multiline strings in IP validation properly' do
    Validations.ip_address?("8.8.8.8\n").should be_false
    Validations.ip_address?("\n8.8.8.8").should be_false
    Validations.ip_address?("1.2.3.4\n8.8.8.8").should be_false
  end

  it 'validates numbers' do
    Validations.number?('42').should be_true
    Validations.number?('x').should be_false
    Validations.number?('42.42').should be_true
    Validations.number?('9').should be_true
  end

  it 'validates more complex numbers' do
    Validations.number?(' 42 ').should be_false
    Validations.number?('42.5555550555555555').should be_true
    Validations.number?('0.5555550555555555').should be_true
    Validations.number?('-0.5555550555555555').should be_true
    Validations.number?('0').should be_true
    Validations.number?('00').should be_false
    Validations.number?('.42').should be_false
    Validations.number?('0.0').should be_true
    Validations.number?('-0.0').should be_true
    Validations.number?('0.000000').should be_true
    Validations.number?('0.0000001').should be_true
    Validations.number?('-0.0000001').should be_true
    Validations.number?('1.00 00001').should be_false
  end

  it 'handles multiline strings in numbers validation properly' do
    Validations.number?("42\n24").should be_false
    Validations.number?("\n24.12").should be_false
  end

  it 'validates integers' do
    Validations.integer?('42').should be_true
    Validations.integer?('universe').should be_false
  end

  it 'validates more complex integers' do
    Validations.integer?(' 42 ').should be_false
    Validations.integer?('-42 ').should be_false
    Validations.integer?('00').should be_false
    Validations.integer?('0').should be_true
    Validations.integer?('9').should be_true
    Validations.integer?('-0').should be_true
    Validations.integer?('--2132').should be_false
    Validations.integer?('-10000000000000').should be_true
  end

  it 'handles multiline strings in integer validation properly' do
    Validations.number?("42\n24").should be_false
    Validations.number?("\n24\n").should be_false
  end

  it 'validates dates' do
    Validations.date?('2012-11-19').should be_true
    Validations.date?(' ').should be_false
    Validations.date?('').should be_false
    Validations.date?('Jamaica').should be_false
  end

  it 'allows zero years in date validation' do
    Validations.date?('0000-01-01').should be_true
  end

  it 'allows huge years in date validation' do
    Validations.date?('9999-01-01').should be_true
  end

  it 'does not allow zero months or days in dates' do
    Validations.date?('1000-00-01').should be_false
    Validations.date?('1000-01-00').should be_false
    Validations.date?('2012-00-00').should be_false
  end

  it 'does not allow invalid months or days in dates' do
    Validations.date?('2012-13-01').should be_false
    Validations.date?('2012-06-32').should be_false
    Validations.date?('2012-06-99').should be_false
  end

  it 'handles newlines in date validation' do
    Validations.date?("2012-11-19\n").should be_false
    Validations.date?("2012-11-19\n2012-10-10").should be_false
  end

  it 'validates times' do
    Validations.time?('12:00:00').should be_true
    Validations.time?('not a time').should be_false
    Validations.time?('00:00:00').should be_true
    Validations.time?('23:59:59').should be_true
    Validations.time?('3:59:59').should be_false
  end

  it 'does not allow invalid hours, minutes or seconds' do
    Validations.time?('24:00:00').should be_false
    Validations.time?('12:69:00').should be_false
    Validations.time?('12:01:99').should be_false
    Validations.time?('12:1:9').should be_false
    Validations.time?(' 12:01:09 ').should be_false
  end

  it 'validates datetime values' do
    Validations.date_time?('2012-11-19 19:00:00').should be_true
    Validations.date_time?('2012-11-19T19:00:00').should be_true
    Validations.date_time?('foo').should be_false
    Validations.date_time?('9999-11-19T23:59:00').should be_true
    Validations.date_time?('2012-00-19T23:59:00').should be_false
    Validations.date_time?('2012-01-00T23:59:00').should be_false
    Validations.date_time?('2012-01-01T24:59:00').should be_false
    Validations.date_time?('2012-01-01T12:60:00').should be_false
    Validations.date_time?('2012-01-01T12:04:60').should be_false
  end

  it 'handles newlines in time and datetime validation' do
    Validations.time?("12:01:01\n").should be_false
    Validations.time?("12:01:01\n12:02:02").should be_false
    Validations.date_time?("2012-11-19 12:01:01\n").should be_false
  end
end
