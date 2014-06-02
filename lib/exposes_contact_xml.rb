class ExposesContactXml
  def initialize(parser)
    @parser = parser
    @ns2 = "urn:ietf:params:xml:ns:vcard-4.0"
  end

  def first_name
    @parser.at_css('ns2|n ns2|given', ns2: @ns2).text
  end

  def last_name
    @parser.at_css('ns2|n ns2|surname', ns2: @ns2).text
  end

  def middle_initial
    @parser.at_css('ns2|n ns2|additional', ns2: @ns2).text
  end

  def prefix
    @parser.at_css('ns2|n ns2|prefix', ns2: @ns2).text
  end

  def suffix
    @parser.at_css('ns2|n ns2|suffix', ns2: @ns2).text
  end

  def organization
    @parser.at_css('ns2|org', ns2: @ns2).text
  end

  def address_type
    @parser.at_css('ns2|adr ns2|parameters ns2|type ns2|text', ns2: @ns2).text
  end

  def street1
    @parser.css('ns2|adr ns2|street', ns2: @ns2)[0].text
  end

  def street2
    result = @parser.css('ns2|adr ns2|street', ns2: @ns2)[1]
    (result.nil?) ? '' : result.text
  end

  def city
    @parser.at_css('ns2|adr ns2|locality', ns2: @ns2).text
  end

  def state
    @parser.at_css('ns2|adr ns2|region', ns2: @ns2).text
  end

  def zip
    @parser.at_css('ns2|adr ns2|code', ns2: @ns2).text
  end

  def phone_type
    @parser.at_css('ns2|tel ns2|parameters ns2|type ns2|text', ns2: @ns2).text
  end

  def phone_number
    @parser.at_css('ns2|tel ns2|uri', ns2: @ns2).text
  end
end