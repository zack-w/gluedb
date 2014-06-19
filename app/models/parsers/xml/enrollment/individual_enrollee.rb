module Parsers::Xml::Enrollment
  class IndividualEnrollee < Enrollee
    def rate_period_date
      benefit_begin_date
    end
  end
end