module Parsers
  module Edi
    module Etf
      class HouseholdParser
        attr_reader :member_ids

        def initialize(etf_loop)
          parse_member_ids(etf_loop)
        end

        def parse_member_ids(etf_loop)
          @member_ids = etf_loop["L2000s"].map { |l2000|
            PersonLoop.new(l2000)
          }.map(&:member_id)
        end

        def persist!
          people = Person.find_for_members(@member_ids)
          Household.create_for_people(people)
        end
      end
    end
  end
end
