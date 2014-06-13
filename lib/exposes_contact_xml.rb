class ExposesContactXml
  def initialize(parser, namespace)
    @parser = parser
    @ns2 = namespace
  end

  def first_name
    @parser.at_css('ns2|n ns2|given', ns2: @ns2).text
  end

  def last_name
    @parser.at_css('ns2|n ns2|surname', ns2: @ns2).text
  end

  def middle_initial
    node = @parser.at_css('ns2|n ns2|additional', ns2: @ns2)
    (node.nil?) ? '' : node.text
  end

  def prefix
    node = @parser.at_css('ns2|n ns2|prefix', ns2: @ns2)
    (node.nil?) ? '' : node.text
  end

  def suffix
    node = @parser.at_css('ns2|n ns2|suffix', ns2: @ns2)
    (node.nil?) ? '' : node.text
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

  def email_type
    @parser.at_css('ns2|email ns2|parameters ns2|type ns2|text', ns2: @ns2).text
  end

  def email_address
    node = @parser.at_xpath('//ns2:email/ns2:text', ns2: @ns2)
    (node.nil?) ? nil : node.text
  end

end