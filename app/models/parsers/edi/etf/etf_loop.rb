module Parsers
  module Edi
    module Etf
      class EtfLoop
        def initialize(etf_loop)
          @loop = etf_loop
        end

        def subscriber_loop
          @loop["L2000s"].detect do |l2000|
            l2000["INS"][2].strip == "18"
          end
        end

        def carrier_fein
          @loop["L1000B"]["N1"][4]
        end
      end
    end
  end
end