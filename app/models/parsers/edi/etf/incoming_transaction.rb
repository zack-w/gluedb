module Parsers
  module Edi
    class IncomingTransaction
      attr_reader :errors  

      def self.from_etf(etf)
        incoming_transaction = new(etf)

        find_carrier = FindCarrier.new(incoming_transaction)
        carrier = find_carrier.by_fein(etf.carrier_fein)

        subscriber_policy_loop = etf.subscriber_loop.policy_loops.first
        find_plan = FindPlan.new(incoming_transaction)
        plan = find_plan.by_hios_id(subscriber_policy_loop.hios_id)

        if(carrier && plan)
          find_policy = FindPolicy.new(incoming_transaction)
          policy = find_policy.by_subkeys({
            :eg_id => subscriber_policy_loop.eg_id, 
            :carrier_id => carrier._id, 
            :plan_id => plan._id
          })
        end
          
        person_loop_validator = PersonLoopValidator.new
        etf.people.each do |person_loop|
          person_loop_validator.validate(person_loop, incoming_transaction)
        end

        policy_loop_validator = PolicyLoopValidator.new
        policy_loop_validator.validate(subscriber_policy_loop, incoming_transaction)

        incoming_transaction
      end

      def initialize(etf)
        @etf = etf
        @errors = []
      end

      def valid?
        @errors.empty?
      end

      def import
        return unless valid?
        @etf.people.each do |person_loop|
          enrollee = @policy.enrollee_for_member_id(person_loop.member_id)

          policy_loop = person_loop.policy_loops.first

          enrollee.c_id = person_loop.carrier_member_id
          enrollee.cp_id = policy_loop.id

          if(!@etf.is_shop? && policy_loop.action == :stop )
            enrollee.coverage_status = 'inactive'
            if enrollee.subscriber?
              if enrollee.coverage_start == enrollee.coverage_end
                enrollee.policy.aasm_state = "canceled"
              else
                enrollee.policy.aasm_state = "terminated"
              end
            end
          end
        end  
        @policy.save
      end

      def policy_found(policy)
        @policy = policy
      end

      def policy_not_found(subkeys)
        @errors << "Policy not found. Details: #{subkeys}"
      end

      def plan_found(plan)
        @plan = plan
      end

      def plan_not_found(hios_id)
        @errors << "Plan not found. (hios id: #{hios_id})"
      end

      def carrier_found(carrier)
        @carrier = carrier
      end

      def carrier_not_found(fein)
        @errors << "Carrier not found. (fein: #{fein})"
      end

      def found_carrier_member_id(id)
      end

      def missing_carrier_member_id
        @errors << "Missing Carrier Member ID."
      end

      def found_carrier_policy_id(id)
      end

      def missing_carrier_policy_id
        @errors << "Missing Carrier Policy ID."
      end

      def policy_id
        @policy ? @policy._id : nil
      end

      def carrier_id
        @carrier ? @carrier._id : nil
      end

      def employer_id
        @employer ? @employer._id : nil
      end
    end
  end
end