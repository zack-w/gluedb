module Parsers
  module Edi
    class TransmissionFile
      attr_reader :result
      attr_accessor :transmission_kind
      
      def initialize(path, t_kind, r_data, blist = [])
        @raw = r_data
        @result = Oj.load(r_data)
        @file_name = File.basename(path)
        @transmission_kind = t_kind
        @bgn_blacklist = blist
      end

      def transaction_set_kind(l834)
        etf = Etf::EtfLoop.new(l834)

        if(@transmission_kind == "effectuation" && etf.cancellation_or_termination?)
          @transmission_kind = "maintenance"
        end
        @transmission_kind
      end

      def persist_edi_transactions(
        l834,
        policy_id,
        carrier_id,
        employer_id,
        edi_transmission,
        error_list = [])
        st = l834["ST"]
        bgn = l834["BGN"]
        fs = FileString.new(bgn[2] + "_" + @file_name, l834["RAW_CONTENT"])
        Protocols::X12::TransactionSetEnrollment.create!(
          :st01 => st[1],
          :st02 => st[2],
          :st03 => st[3],
          :bgn01 => bgn[1],
          :bgn02 => bgn[2],
          :bgn03 => bgn[3],
          :bgn04 => bgn[4],
          :bgn05 => bgn[5],
          :bgn06 => bgn[6],
          :bgn08 => bgn[8],
          :carrier_id => carrier_id,
          :receiver_id => edi_transmission.isa08,
          :employer_id => employer_id,
          :policy_id => policy_id,
          :error_list => error_list,
          :transmission => edi_transmission,
          :transaction_kind => transaction_set_kind(l834),
          :body => fs
        )
      end

      def parse_edi_transmission(top_doc)
        isa = top_doc["ISA"]
        gs = top_doc["GS"]
        sender_id = isa[6].strip
        @carrier = Carrier.for_fein(sender_id)
        Protocols::X12::Transmission.create!({
          :isa06 => sender_id,
          :isa08 => isa[8].strip,
          :isa09 => isa[9].strip,
          :isa10 => isa[10].strip,
          :isa12 => isa[12].strip,
          :isa13 => isa[13].strip,
          :isa15 => isa[15].strip,
          :gs01 => gs[1],
          :gs02 => gs[2],
          :gs03 => gs[3],
          :gs04 => gs[4],
          :gs05 => gs[5],
          :gs06 => gs[6],
          :gs07 => gs[7],
          :gs08 => gs[8],
          :file_name => @file_name
        })
      end

      def persist_834(etf_loop, edi_transmission)
        etf_checker = create_etf_validator(etf_loop)
        if !etf_checker.valid?
          persist_edi_transactions(
            etf_loop,
            nil,
            nil,
            nil,
            edi_transmission,
            etf_checker.errors.full_messages
          )
          return nil
        end
        etf = Etf::EtfLoop.new(etf_loop)

        carrier = Carrier.for_fein(etf.carrier_fein)
        carrier ||= @carrier
        carrier_id = carrier._id

        coverage_loop = Parsers::Edi::Etf::CoverageLoop.new(etf.subscriber_loop["L2300s"].first)

        employer_id = persist_employer_get_id(etf_loop, carrier_id)

        plan = Plan.find_by_hios_id(coverage_loop.hios_id)

        policy = nil

        if etf.is_shop? && is_carrier_maintenance?(etf_loop, edi_transmission)
          policy = Policy.find_by_subkeys(coverage_loop.eg_id, carrier_id, plan._id)
          
          if policy
            edi_transmission.save!
          end
        else
          responsible_party_id = persist_responsible_party_get_id(etf_loop)
          broker_id = persist_broker_get_id(etf_loop)
          
          if(plan)
            policy = persist_policy(etf_loop, carrier_id, plan._id, coverage_loop.eg_id, employer_id, responsible_party_id, broker_id)
            
            if policy
              edi_transmission.save!
              
              persist_people(etf_loop, employer_id)
              persist_application_group(etf_loop)
            end
          end
        end

        #persist transaction
        policy_id = (policy.nil?) ? nil : policy._id
        persist_edi_transactions(etf_loop, policy_id, carrier_id, employer_id, edi_transmission)
      end

      # FIXME: pull sep reason
      def persist_policy(etf_loop, carrier_id, plan_id, eg_id, employer_id, rp_id, broker_id)
        etf = Etf::EtfLoop.new(etf_loop)

        reporting_categories = Etf::ReportingCatergories.new(etf.subscriber_loop["L2700s"])

        new_policy = Policy.new(
          :plan_id => plan_id,
          :enrollment_group_id => eg_id,
          :carrier_id => carrier_id,
          :tot_res_amt => reporting_categories.tot_res_amt,
          :pre_amt_tot => reporting_categories.pre_amt_tot,
          :applied_aptc => reporting_categories.applied_aptc,
          :tot_emp_res_amt => reporting_categories.tot_emp_res_amt,
          :carrier_to_bill => reporting_categories.carrier_to_bill?,
          :employer_id => employer_id,
          :broker_id => broker_id,
          :responsible_party_id => rp_id,
          :enrollees => []
        )
        policy = Policy.find_or_update_policy(new_policy)
        if transaction_set_kind(etf_loop) == "effectuation"
          policy.aasm_state = 'effectuated'
        end

        etf.people.each do |person_loop|
          policy_loop = person_loop.policy_loops.first
          create_enrollee(person_loop)
          policy.merge_enrollee(new_member, policy_loop.action)
        end
        policy.unsafe_save!

        policy
      end

      def create_enrollee(person, policy)
        new_member = Enrollee.new(
          :m_id => person.member_id,
          :pre_amt => person.reporting_catergories.pre_amt,
          :c_id => person.carrier_member_id,
          :cp_id => policy.id,
          :coverage_start => policy.coverage_start,
          :coverage_end => policy.coverage_end,
          :ben_stat => map_benefit_status_code(person.ben_stat),
          :rel_code => map_relationship_code(person.rel_code),
          :emp_stat => map_employment_status_code(person.emp_stat, policy.action)
        )
      end

      def persist_application_group(etf_loop)
        Etf::ApplicationGroupParser.new(etf_loop).persist!
      end

      def persist_responsible_party_get_id(etf_loop)
        rp_loop = responsible_party_loop(etf_loop["L2000s"])
        return(nil) if rp_loop.blank?
#        begin
          Etf::ResponsiblePartyParser.parse_persist_and_return_id(rp_loop)
#        rescue
#         raise rp_loop.to_s
#        end
      end

      def responsible_party_loop(all_l2000s)
        l2100Fs = all_l2000s.map { |l| l["L2100F"] }.compact
        l2100Gs = all_l2000s.map { |l| l["L2100G"] }.compact
        rp_loops = l2100Fs + l2100Gs
        rp_loops.first
      end

      def persist_broker_get_id(etf_loop)
        broker_loop = Etf::BrokerLoop.new(etf_loop["L1000C"])
        return nil if !broker_loop.valid?

        new_broker = Broker.new(
          :name_full => broker_loop.name,
          :npn => broker_loop.npn,
          :b_type => "broker"
        )
        broker = Broker.find_or_create(new_broker)
        broker._id
      end

      def persist_employer_get_id(etf_loop, carrier_id)
        etf = Etf::EtfLoop.new(etf_loop)
        employer_loop = Etf::EmployerLoop.new(etf.employer_loop)

        return(nil) if !etf.is_shop?
        
        employer = nil

        if employer_loop.specified_as_group?
          employer = Employer.find_for_carrier_and_group_id(carrier_id, employer_loop.group_id)
        end
        
        if employer.nil?
          new_employer = Employer.new(
            :name => employer_loop.name,
            :fein => employer_loop.fein
          )
          employer = Employer.find_or_create_employer_by_fein(new_employer)
        end

        begin
          employer._id
        rescue
          raise("Unknown employer ID: #{employer_loop.id_qualifer} #{employer_loop.fein}")
        end
      end

      def persist_people(etf_loop, employer_id)
        etf_loop["L2000s"].each do |l2000|
          Etf::PersonParser.parse_and_persist(l2000, employer_id)
        end
      end

      def create_etf_validator(etf_loop)
        EtfValidation.new(
          @file_name,
          transaction_set_kind(etf_loop),
          etf_loop,
          @bgn_blacklist
        )
      end

      def persist!
        return(nil) if incomplete_isa?
        return(nil) if transmission_already_exists?
        edi_transmission = parse_edi_transmission(@result)
        return(nil) if @result["L834s"].first.blank?
        @result["L834s"].each do |l834|
          if !l834["ST"][3].to_s.strip.blank?
            persist_834(l834, edi_transmission)
          end
        end
      end

      private

      def map_employment_status_code(es_code, p_action)
        return("terminated") if p_action == :stop
        employment_status_codes = {
          "AC" => "active",
          "FT" => "full-time",
          "RT" => "retired",
          "PT" => "part-time",
          "TE" => "terminated"
        }
        result = employment_status_codes[es_code]
        result.nil? ? "active" : result
      end

      def map_relationship_code(r_code)
        relationship_codes = {
          "18" => "self",
          "01" => "spouse",
          "19" => "child",
          "15" => "ward"
        }
        result = relationship_codes[r_code]
        result.nil? ? "child" : result
      end

      def map_benefit_status_code(b_code)
        benefit_codes = {
          "C" => "cobra",
          "T" => "tefra",
          "S" => "surviving insured",
          "A" => "active"
        }
        result = benefit_codes[b_code]
        result.nil? ? "active" : result
      end

      def is_carrier_maintenance?(etf_loop, edi_transmission)
        val = ((edi_transmission.isa06.strip != ExchangeInformation.receiver_id)  &&
          (transaction_set_kind(etf_loop) == "maintenance"))
        val
      end

      def incomplete_isa?
        return(true) if @result["ISA"].blank?
        @result["ISA"].length < 15
      end

      def transmission_already_exists?
        Protocols::X12::Transmission.where({
          :file_name => @file_name
        }).any?
      end
    end
  end
end
