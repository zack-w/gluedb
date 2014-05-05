module Parsers
  module Edi
    module Etf
      class PersonLoop
        def initialize(l2000)
          @loop = l2000
        end

        def member_id
          @member_id ||= (@loop["REFs"].detect do |r|
              r[1] == "17"
            end)[2]            
        end
      end
    end
  end
end
