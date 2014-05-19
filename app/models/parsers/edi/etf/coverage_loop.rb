module Parsers
  module Edi
    module Etf
      class CoverageLoop
        def initialize coverage_loop
          @loop = coverage_loop
        end

        def eg_id
          (@loop["REFs"].detect do |r|
            r[1] == "1L"
          end)[2]
        end

        def hios_id
          (@loop["REFs"].detect do |r|
            r[1] == "CE"
          end)[2]
        end
      end
    end
  end
end