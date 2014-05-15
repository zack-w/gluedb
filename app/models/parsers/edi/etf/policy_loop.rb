module Parsers
  module Edi
    module Etf
      class PolicyLoop
        def initialize(l2300)
          @loop = l2300
        end

        def id
          c_policy_id = nil
          c_pol_node = @loop["REFs"].detect do |ref|
            ref[1] == "X9"
          end
          if !c_pol_node.blank?
            c_policy_id = c_pol_node[2]
          end 
          c_policy_id 
        end

        def coverage_start
          bgn_date = nil
          bgn_node = @loop["DTPs"].detect do |dtp|
            dtp[1] == "348"
          end
          if bgn_node
            bgn_date = bgn_node[3]
          end  
          bgn_date 
        end

        def coverage_end
          bgn_end = nil
          bgn_end_node = @loop["DTPs"].detect do |dtp|
            dtp[1] == "349"
          end
          if bgn_end_node
            bgn_end = bgn_end_node[3]
          end
          bgn_end
        end

        def action
          action_val = @loop["HD"][1].strip
          case action_val
            when "001"
              :change
            when "024"
              :stop
            when "030"
              :audit
            when "025"
              :reinstate
            else
              :add
          end
        end
      end
    end
  end
end