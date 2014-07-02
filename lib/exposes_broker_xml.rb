require './lib/exposes_contact_xml'
require './lib/null_exposes_contact_xml'


class ExposesBrokerXml
  def initialize(parser)
    @parser = parser
  end

  def npn
    @parser.at_css('npn').text
  end

  def contact
    namespace = determine_vcard_namespace
    node = @parser.at_css('ns2|vcard', ns2: namespace)
    if(node.nil?)
      NullExposesContactXml.new
    else
      ExposesContactXml.new(node, namespace)
    end
  end

  private 
  def determine_vcard_namespace
    possible_namespaces = [
      'urn:ietf:params:xml:ns:vcard-4.0',
      'http://dchbx.dc.gov/broker'
    ]

    possible_namespaces.each do |ns|
      node = @parser.at_css('ns2|vcard', ns2: ns)
      return ns if !node.nil?
    end

    ''
  end
end