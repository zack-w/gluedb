module Parsers::Xml::Enrollment
  class Enrollee
    def initialize(parser)
      @parser = parser
      @coverage = @parser.at_xpath('./ins:coverage', NAMESPACES)
    end

    def birth_date
      text_date = @parser.at_xpath('./ins:DOB', NAMESPACES).text
      Date.parse(text_date)
    end

    def benefit_begin_date
      Date.parse(@coverage.at_xpath('./ins:benefit_begin_date', NAMESPACES).text)
    end

    def rate_period_date
      raise NotImplementedError
    end

    def premium_amount
      @coverage.at_xpath('./ins:premium_amount', NAMESPACES).text.to_f
    end
  end
end