module Parsers
  module Edi
    module Etf
      class ReportingCatergories
        def initialize(reporting_loops)
          @loops = reporting_loops
          @categories = @loops.map { |l| Category.new(l.fetch('L2750')) }
        end

        def pre_amt
          category_by_name('PRE AMT 1').value
        end

        def pre_amt_tot
          category_by_name('PRE AMT TOT').value
        end

        def tot_res_amt
          category_by_name('TOT RES AMT').value
        end

        def applied_aptc
          result = category_by_name('APTC AMT').value
          (result.blank?) ? 0.00 : result
        end

        def tot_emp_res_amt
          result = category_by_name('TOT EMP RES AMT').value
          (result.blank?) ? 0.00 : result
        end

        def carrier_to_bill?
          category_by_name('CARRIER_TO_BILL').present?
        end

        private 

        def category_by_name(name)
          @categories.detect { |c| c.name == name }
        end
      end
    end
  end
end
