Xml::Parser.new(Nokogiri::XML::Reader(open("../../spec/fixtures/shop_enrollment.xml"))) do
  inside_element 'User' do
    for_element 'name_first' do puts "first name: #{inner_xml}" end
    for_element 'name_last' do puts "last name: #{inner_xml}" end

    for_element 'address' do
      puts 'Start of address:'
      inside_element do
        for_element 'address_1' do puts "Street: #{inner_xml}" end
        for_element 'city' do puts "City: #{inner_xml}" end
        for_element 'zipcode' do puts "Zipcode: #{inner_xml}" end
      end
      puts 'End of address'
    end
  end
end