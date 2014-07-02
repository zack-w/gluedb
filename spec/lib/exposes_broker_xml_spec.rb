require 'open-uri'
require 'nokogiri'
require './lib/exposes_broker_xml'

describe ExposesBrokerXml do
  it 'exposes npn' do
    npn = '1234'
    parser = Nokogiri::XML("<broker><npn>#{npn}</npn></broker>")
    broker = ExposesBrokerXml.new(parser)
    expect(broker.npn).to eq npn
  end

  it 'exposes broker contact' do
    parser = Nokogiri::XML("<broker><vcard>SOMETHING</vcard></broker>")
    broker = ExposesBrokerXml.new(parser)
    expect(broker.contact).not_to eq nil
  end
end