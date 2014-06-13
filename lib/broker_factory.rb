require 'open-uri'
require 'nokogiri'
require './lib/exposes_broker_xml'

class BrokerFactory
  def create_many_from_xml(xml)
    brokers = []
    doc = Nokogiri::XML(xml)
    doc.css('brokers broker').each do |broker|
      brokers << create_broker(ExposesBrokerXml.new(broker))
    end

    brokers
  end

  def create_broker(broker_data)
    broker = Broker.new(
      :npn => broker_data.npn.gsub(/[^0-9]/,""),
      :b_type => 'broker', # or tpa
      :name_pfx => broker_data.contact.prefix,
      :name_first => broker_data.contact.first_name,
      :name_middle => broker_data.contact.middle_initial,
      :name_last => broker_data.contact.last_name,
      :name_sfx => broker_data.contact.suffix
    )

    if !broker_data.contact.street1.blank?
      broker.addresses << create_address(broker_data.contact)
    end

    if !broker_data.contact.phone_number.blank?
      broker.phones << create_phones(broker_data.contact)
    end

    if !broker_data.contact.email_address.blank?
      broker.emails << create_emails(broker_data.contact)
    end

    broker
  end

  def create_address(contact_data)
    Address.new(
      :address_type => contact_data.address_type.downcase,
      :address_1 => contact_data.street1,
      :address_2 => contact_data.street2,
      :city => contact_data.city,
      :state => contact_data.state,
      :zip => contact_data.zip
      )
  end

  def create_phones(contact_data)
    Phone.new(
      :phone_type => contact_data.phone_type.downcase,
      :phone_number => contact_data.phone_number.gsub(/[^0-9]/,""),
    )
  end

  def create_emails(contact_data)
    Email.new(
      :email_type => contact_data.email_type.downcase,
      :email_address => contact_data.email_address,
    )
  end
end