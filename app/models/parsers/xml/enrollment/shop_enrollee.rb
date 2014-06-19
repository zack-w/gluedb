module Parsers::Xml::Enrollment 
  class ShopEnrollee < Enrollee
    def initialize(parser, employer)
      @employer = employer
      super(parser)
    end

    def rate_period_date
      @employer.open_enrollment_start
    end
  end
end