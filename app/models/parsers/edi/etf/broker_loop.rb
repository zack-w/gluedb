module Parsers
  module Edi
    module Etf
      class BrokerLoop
        def initialize(l1000C)
          @loop = l1000C
        end

        def name
          @loop["N1"][2]
        end

        def npn
          @loop["N1"][4]
        end

        def valid?
          return false if @loop.blank?
          !npn.blank?
        end
      end
    end
  end
end
