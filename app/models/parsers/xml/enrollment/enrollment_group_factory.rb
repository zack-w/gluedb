module Parsers::Xml::Enrollment
  class EnrollmentGroupFactory
    def self.from_xml(doc)
      payload = doc.at_xpath('/proc:Operation/proc:payload', NAMESPACES)
      type = payload.first_element_child.name

      case type
      when 'individual_market_enrollment_group'
        IndividualEnrollmentGroup.new(payload.at_xpath('./ins:individual_market_enrollment_group', NAMESPACES))
      when 'shop_market_enrollment_group'
        ShopEnrollmentGroup.new(payload.at_xpath('./ins:shop_market_enrollment_group', NAMESPACES))
      end
    end
  end
end

