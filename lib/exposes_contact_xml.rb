class ExposesContactXml
  def initialize(parser)
    @parser = parser
  end

  def first_name
    @parser.at_css('n given').text
  end

  def last_name
    @parser.at_css('n surname').text
  end

  def middle_initial
    @parser.at_css('n additional').text
  end

  def prefix
    @parser.at_css('n prefix').text
  end

  def suffix
    @parser.at_css('n suffix').text
  end

  def organization
    @parser.at_css('org').text
  end

  def address_type
    @parser.at_css('adr parameters type text').text
  end

  def street
    @parser.at_css('adr street').text
  end

  def city
    @parser.at_css('adr locality').text
  end

  def state
    @parser.at_css('adr region').text
  end

  def zip
    @parser.at_css('adr code').text
  end

  def phone_type
    @parser.at_css('tel parameters type text').text
  end

  def phone_number
    @parser.at_css('tel uri').text
  end
end