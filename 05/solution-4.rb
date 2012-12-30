class PrivacyFilter
    attr_accessor :text, :preserve_phone_country_code,
	                :preserve_email_hostname, :partially_preserve_email_username
	
	  def initialize(text)
	    @partially_preserve_email_username = false
	    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @text = text
	  end
	
	  def filtered
	    if preserve_email_hostname or partially_preserve_email_username or preserve_phone_country_code
	    filter_with_flags
	    else filter
	    end
	    text
	  end
	
	  def regex_for(value)
	    if value == "email"
	      /[A-Z0-9][A-Z0-9_+.-]{1,200}@([A-Z0-9][A-Z0-9-]{,61}[A-Z0-9]\.)+[A-Z]{2,3}/i
	    elsif value == "phone"
	      /(?<prefix>(0|(?<international>00|\+))[1-9](\d){0,2})([-( )]{0,2}\d){6,11}/
	    end
	  end
	
	
	  def filter
	    filter_emails
	    filter_phones
	    text
	  end
	
	  def filter_with_flags
	    if partially_preserve_email_username then filter_emails_h_u
	    elsif preserve_email_hostname then filter_emails_h
	    elsif filter_emails
	    end
	    preserve_phone_country_code ? filter_phones_c : filter_phones
	  end
	
	  def filter_emails_h_u
	    text.gsub!(regex_for "email") do |match|
	      match = match[0..2] + "[FILTERED]" + match[match.index("@")..-1]
	    end
	  end
	
	  def filter_emails_h
	    text.gsub!(regex_for "email") do |match|
	      match = "[FILTERED]" + match[match.index("@")..-1]
	    end
	  end
	
	  def filter_emails
	    text.gsub!(regex_for("email"), "[EMAIL]")
	  end
	
	  def filter_phones
	    text.gsub!(regex_for("phone"), "[PHONE]")
	  end
	
	  def filter_phones_c
	    (regex_for ("phone")).match text do |match|
	      if match[:international]
	        text.gsub!((regex_for ("phone")), match[:prefix].to_s + " [FILTERED]")
      else text.gsub!(regex_for ("phone"),"[PHONE]")
	      end
	    end
	  end
	
	end
	
	class Validations
	
	  def self.email?(value)
	    if /[A-Z0-9][A-Z0-9_+.-]{1,200}@([A-Z0-9][A-Z0-9-]{,61}[A-Z0-9]\.)+[A-Z]{2,3}/i.match value
	      return true
	    end
	      false
	  end
	
	  def self.phone?(value)
	    if /(0|(00|\+))[1-9](\d){0,2}([-( )]{0,2}\d){6,11}/.match value
	      return true
	    end
	    false
	  end
	
	  def self.hostname?(value)
	    if /([A-Z0-9][A-Z0-9-]{,61}[A-Z0-9]\.)+[A-Z]{2,3}/i.match value
	      return true
	    end
	    false
	  end
	
	  def self.ip_address?(value)
	    if /((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.){3}(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])/.match value
	      return true
	    end
	    false
	  end
	
	  def self.number?(value)
	    if /\b\-?0|([1-9]\d*)((\.\d)?\d*)?\b/.match value
	      return true
	    end
	    false
	  end
	
	  def self.integer?(value)
	    if /\b\-?0|([1-9]\d*)\b/.match value
	      return true
	    end
	    false
	  end
	
	  def self.date?(value)
	    if /\b\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|(1|2)\d|3(0|1))/.match value
	      return true
	    end
	    false
	  end
	
	  def self.time?(value)
	    if /\b(0\d|1\d|2[0-3])(:(0\d|[1-5]\d)){2}/.match value
	      return true
	    end
	    false
	  end
	
	  def self.date_time?(value)
	    if /\b\d{4}\-(0[1-9]|1[0-2])\-(0[1-9]|(1|2)\d|3(0|1))[ T]\b(0\d|1\d|2[0-3])(:(0\d|[1-5]\d)){2}/.match value
	      return true
	    end
	    false
	  end
	
	end
