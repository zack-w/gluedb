require 'open-uri'
require 'nokogiri'
require './lib/exposes_contact_xml'

describe ExposesContactXml do
  it 'exposes the first name' do
    first_name = 'Bob'
    parser = Nokogiri::XML("<vcard><n><given>#{first_name}</given></n></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.first_name).to eq first_name
  end
  
  it 'exposes the last name' do
    last_name = 'Bob'
    parser = Nokogiri::XML("<vcard><n><surname>#{last_name}</surname></n></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.last_name).to eq last_name
  end

  it 'exposes the middle initial' do
    middle_initial = 'A'
    parser = Nokogiri::XML("<vcard><n><additional>#{middle_initial}</additional></n></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.middle_initial).to eq middle_initial
  end

  it 'exposes prefix' do
    prefix = 'Mr'
    parser = Nokogiri::XML("<vcard><n><prefix>#{prefix}</prefix></n></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.prefix).to eq prefix  
  end

  it 'exposes suffix' do
    suffix = 'Jr'
    parser = Nokogiri::XML("<vcard><n><suffix>#{suffix}</suffix></n></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.suffix).to eq suffix  
  end

  it 'exposes organization' do
    organization = "Ziltoid's Finest Bean Coffeehouse"
    parser = Nokogiri::XML("<vcard><org>#{organization}</org></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.organization).to eq organization  
  end

  it 'exposes address type' do
    address_type = '1'
    parser = Nokogiri::XML("<vcard><adr><parameters><type><text>#{address_type}</text></type></parameters></adr></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.address_type).to eq address_type    
  end

  it 'exposes street' do
    street = '1'
    parser = Nokogiri::XML("<vcard><adr><street>#{street}</street></adr></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.street).to eq street  
  end

  it 'exposes city' do
    city = 'Washington'
    parser = Nokogiri::XML("<vcard><adr><locality>#{city}</locality></adr></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.city).to eq city  
  end

  it 'exposes state' do
    state = 'DC'
    parser = Nokogiri::XML("<vcard><adr><region>#{state}</region></adr></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.state).to eq state  
  end

  it 'exposes zip' do
    zip = '20002'
    parser = Nokogiri::XML("<vcard><adr><code>#{zip}</code></adr></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.zip).to eq zip  
  end

  it 'exposes telephone type' do
    phone_type = 'WORK'
    parser = Nokogiri::XML("<vcard><tel><parameters><type><text>#{phone_type}</text></type></parameters></tel></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.phone_type).to eq phone_type  
  end

  it 'exposes telephone number' do
    phone_number = '111-111-1111'
    parser = Nokogiri::XML("<vcard><tel><uri>#{phone_number}</uri></tel></vcard>")
    contact = ExposesContactXml.new(parser)
    expect(contact.phone_number).to eq phone_number  
  end

end