class ImportBrokers
  def self.from_xml(xml)
    brokers = BrokerFactory.new.create_many_from_xml(xml)
    brokers.each do |b|
      Broker.find_or_create(b)
    end
  end
end