Pattern_ip_address = /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\z/
Pattern_email =
/\A[a-zA-Z0-9][\w\+\.-]{0,200}\@(([a-zA-Z0-9]{1}[a-zA-Z0-9-]{,60})?[a-zA-Z0-9]{1}\.)+[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?\z/
Pattern_email_multiple =
/([a-zA-Z0-9][\w\+\.-]{0,200}\@(([a-zA-Z0-9]{1}[a-zA-Z0-9-]{,60})?[a-zA-Z0-9]{1}\.)+[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?)/
Pattern_hostname = /\A(([a-zA-Z0-9]{1}[a-zA-Z0-9-]{,60})?[a-zA-Z0-9]{1}\.)+[a-zA-Z]{2,3}(\.[a-zA-Z]{2})?\z/
Pattern_phone = /\A((00|\+)[1-9]\d{,2}|0)([ )(-]{,2}\d){6,11}\z/
Pattern_phone_multiple = /(((00|\+)[1-9]\d{,2}|0)([ )(-]{,2}\d){6,11})/
Pattern_number = /\A\-?(0?[1-9]{1}\d*|0)(\.\d+)?\z/
Pattern_integer = /\A\-?(0?[1-9]{1}\d*|0)\z/
Pattern_date = /\A\d{4}\-(\d{2})\-(\d{2})\z/
Pattern_time = /\A(\d{2}):(\d{2}):(\d{2})\z/
Pattern_date_time_split = /(.*)( |T)(.*)/

class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username

  def initialize(text)
    @preserve_phone_country_code, @preserve_email_hostname, @partially_preserve_email_username = false, false, false
    @text = text
  end

  def filtered
    filter_phones(filter_emails(@text))
  end

  private
  def filter_emails(text)
  text.scan(Pattern_email_multiple).each do |item|
	  #razbira se, ne bih gi podredil taka, ama ne minava skeptic...
	  if @partially_preserve_email_username then text.gsub!(item[0], partially_preserve(item[0]))
	  elsif preserve_email_hostname then text.gsub!(item[0], prsv_host(item[0])) else text.gsub!(item[0], "[EMAIL]") end
    end
	text
  end

  def partially_preserve(item_text)
    #ostavia se hosta i se krie chast ot imeto
	len = item_text.rindex('@')
	if len < 6
	  '[EMAIL]' + item_text.slice(len, item_text.length)
	else
	  item_text.slice(0, 3) + '[EMAIL]' + item_text.slice(len, item_text.length)
	end
  end

  def prsv_host(item_text)
    #ostavia se hosta i se krie cialoto ime
	len = item_text.rindex('@')
	'[EMAIL]' + item_text.slice(len, item_text.length)
  end

  def filter_phones(text)
    text.scan(Pattern_phone_multiple).each do |item|
	  if not @preserve_phone_country_code or item[1] == "0" then text.gsub!(item[0], '[PHONE]')
	  else text.gsub!(item[0], item[1] + '[PHONE]') end
	end
	text
  end
end

class Validations
  def self.email?(value)
    #Pattern_email.match(value) != false -> ne raboti
    matches = Pattern_email.match(value)
    if matches != false and matches != nil then true else false end
  end

  def self.phone?(value)
    matches = Pattern_phone.match(value)
    if matches != false and matches != nil then true else false end
  end

  def self.hostname?(value)
    matches = Pattern_hostname.match(value)
    if matches != false and matches != nil then true else false end
  end

  def self.ip_address?(value)
    Pattern_ip_address.match(value).to_a[1..-1].all? {|ip_part| ip_part and ip_part.to_i >= 0 and ip_part.to_i < 256}
  end

  def self.number?(value)
    matches = Pattern_number.match(value)
    if matches != false and matches != nil then true else false end
  end

  def self.integer?(value)
    matches = Pattern_integer.match(value)
    if matches != false and matches != nil then true else false end
  end

  def self.date?(value)
    Pattern_date.match value
    $1.to_i > 0 and $1.to_i < 13 and $2.to_i > 0 and $2.to_i < 32
  end

  def self.time?(value)
    Pattern_time.match value
	$1 and $2 and $3 and $1.to_i >= 0 and $1.to_i < 24 and $2.to_i >= 0 and $2.to_i < 60 and $3.to_i >= 0 and $3.to_i < 60
  end

  def self.date_time?(value)
    Pattern_date_time_split.match value
    Validations.date?($1) and Validations.time?($3)
  end
end
