module Parsers::Xml::Enrollment
  class ShopEnrollmentGroup < EnrollmentGroup
    def credit
      @plan.at_xpath('./ins:total_employer_responsibility_amount', NAMESPACES).text.to_f
    end

    def enrollees
      enrollees = @parser.xpath('./ins:subscriber | ./ins:member', NAMESPACES)
      enrollees.collect { |e| ShopEnrollee.new(e) }
    end
  end
end