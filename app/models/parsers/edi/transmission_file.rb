module Parsers
  module Edi
    class TransmissionFile
      attr_reader :result
      def initialize(path, t_kind, r_data)
        @raw = r_data
        @result = Oj.load(r_data)
        @file_name = File.basename(path)
        @transmission_kind = t_kind
      end

      def determine_transaction_set_kind(l834)
        assigned_transmission_kind = @transmission_kind
        if @transmission_kind == "effectuation"
          found_inses = l834["L2000s"].any? do |l2000|
            if !l2000["INS"].blank?
              ['024'].include?(l2000["INS"][3].strip)
            else
              false
            end
          end
          if found_inses
            assigned_transmission_kind = "maintenance"
          end
        end
        assigned_transmission_kind
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
          :transaction_kind => determine_transaction_set_kind(l834),
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

        eg_id = (etf.subscriber_loop["L2300s"].first["REFs"].detect do |r|
          r[1] == "1L"
        end)[2]
        hios_id = (etf.subscriber_loop["L2300s"].first["REFs"].detect do |r|
          r[1] == "CE"
        end)[2]

        employer_id = persist_employer_get_id(etf_loop, carrier_id)
        if etf.is_shop? && is_carrier_maintenance?(etf_loop, edi_transmission)
          persist_screened_834(etf_loop, carrier_id, eg_id, hios_id, employer_id, edi_transmission)
          return nil
        end
        # raise [carrier_id, eg_id, hios_id, employer_id, edi_transmission].inspect
        persist_unscreened_834(etf_loop, carrier_id, eg_id, hios_id, employer_id, edi_transmission)
      end

      def persist_screened_834(etf_loop, carrier_id, eg_id, hios_id, employer_id, edi_transmission)
        policy = find_policy(eg_id, carrier_id, hios_id,)
        unless policy
          persist_edi_transactions(etf_loop, nil, carrier_id, employer_id, edi_transmission)
          return nil
        end
        persist_edi_transactions(etf_loop, policy._id, carrier_id, employer_id, edi_transmission) 
        edi_transmission.save!
      end

      def persist_unscreened_834(etf_loop, carrier_id, eg_id, hios_id, employer_id, edi_transmission)
        responsible_party_id = persist_responsible_party_get_id(etf_loop)
        policy = persist_policy(etf_loop, carrier_id, hios_id, eg_id, employer_id, responsible_party_id)
        unless policy
          persist_edi_transactions(etf_loop, nil, carrier_id, employer_id, edi_transmission)
          return nil
        end
        persist_edi_transactions(etf_loop, policy._id, carrier_id, employer_id, edi_transmission)
        edi_transmission.save!
        persist_people(etf_loop, employer_id)
        #persist_household(etf_loop)
      end

      def find_policy(eg_id, carrier_id, hios_id)
        plan = Plan.find_by_hios_id(hios_id)
        unless plan
          return nil
        end
        Policy.find_by_subkeys(eg_id, carrier_id, plan._id)
      end

      # FIXME: pull sep reason
      def persist_policy(etf_loop, carrier_id, hios_id, eg_id, employer_id, rp_id)
        etf = Etf::EtfLoop.new(etf_loop)

        broker_id = persist_broker_get_id(etf_loop)
        s_loop = etf.subscriber_loop
        trans_kind = determine_transaction_set_kind(etf_loop)
        carrier_to_bill = s_loop["L2700s"].any? do |lth|
          lth["L2750"]["N1"][2] == "CARRIER TO BILL"
        end
        pre_amt_tot = l2700val(s_loop,"PRE AMT TOT")
        tot_res_amt = l2700val(s_loop,"TOT RES AMT")
        applied_aptc = opt_l2700val(s_loop,"APTC AMT",0.00)
        tot_emp_res_amt = opt_l2700val(s_loop,"TOT EMP RES AMT",0.00)
        plan = Plan.find_by_hios_id(hios_id)
        unless plan
          return nil
        end
        new_policy = Policy.new(
          :plan_id => plan._id,
          :enrollment_group_id => eg_id,
          :carrier_id => carrier_id,
          :tot_res_amt => tot_res_amt,
          :pre_amt_tot => pre_amt_tot,
          :applied_aptc => applied_aptc,
          :tot_emp_res_amt => tot_emp_res_amt,
          :carrier_to_bill => carrier_to_bill,
          :employer_id => employer_id,
          :broker_id => broker_id,
          :responsible_party_id => rp_id,
          :enrollees => []
        )
        policy = Policy.find_or_update_policy(new_policy)
        if trans_kind == "effectuation"
          policy.aasm_state = 'effectuated'
        end
        persist_policy_members(etf_loop, policy)
        policy
      end

      def opt_l2700val(l2000, tag, default = nil)
          node = (l2000["L2700s"].detect do |lth|
            lth["L2750"]["N1"][2] == tag
          end)
          (node.blank?) ? default : node["L2750"]["REF"][2]
      end

      def l2700val(l2000, tag)
          (l2000["L2700s"].detect do |lth|
            lth["L2750"]["N1"][2] == tag
          end)["L2750"]["REF"][2]
      end

      def persist_household(etf_loop)
        Etf::HouseholdParser.new(etf_loop).persist!
      end

      def persist_policy_members(etf_loop, policy)
        etf_loop["L2000s"].each do |l2000|
          person_loop = Etf::PersonLoop.new(l2000)
          member_id = person_loop.member_id
          pre_amt = l2700val(l2000, "PRE AMT 1")
          c_member_id = person_loop.carrier_member_id

          policy_loop = person_loop.policy_loops.first

          ben_stat = person_loop.ben_stat
          rel_code = person_loop.rel_code
          emp_stat = person_loop.emp_stat
          new_member = Enrollee.new(
            :m_id => member_id,
            :pre_amt => pre_amt,
            :c_id => c_member_id,
            :cp_id => policy_loop.id,
            :coverage_start => policy_loop.coverage_start,
            :coverage_end => policy_loop.coverage_end,
            :ben_stat => map_benefit_status_code(ben_stat),
            :rel_code => map_relationship_code(rel_code),
            :emp_stat => map_employment_status_code(emp_stat, policy_loop.action)
          )
          policy.merge_enrollee(new_member, policy_loop.action)
        end
        policy.unsafe_save!
      end

      def persist_responsible_party_get_id(etf_loop)
        all_l2000s = etf_loop["L2000s"]
        l2100Fs = all_l2000s.map { |l| l["L2100F"] }.compact
        l2100Gs = all_l2000s.map { |l| l["L2100G"] }.compact
        rp_loops = l2100Fs + l2100Gs
        rp_loop = rp_loops.first
        return(nil) if rp_loop.blank?
#        begin
          Etf::ResponsiblePartyParser.parse_persist_and_return_id(rp_loop)
#        rescue
#         raise rp_loop.to_s
#        end
      end

      def persist_broker_get_id(etf_loop)
        broker_loop = Etf::BrokerLoop.new(etf_loop["L1000C"])
        return nil if !broker_loop.valid?

        new_broker = Broker.new(
          :name => broker_loop.name,
          :npn => broker_loop.npn,
          :b_type => "broker"
        )
        broker = Broker.find_or_create_broker(new_broker)
        broker._id
      end

      def persist_employer_get_id(etf_loop, carrier_id)
        etf = Etf::EtfLoop.new(etf_loop)
        emp_seg = etf.employer_loop
        return(nil) if !etf.is_shop?
        new_employer = nil
        employer = nil
        # Specified as group
        if emp_seg[3] == "94"
          employer = Employer.find_for_carrier_and_group_id(carrier_id, emp_seg[4])
        end
        if employer.nil?
          new_employer = Employer.new(
            :name => emp_seg[2],
            :fein => emp_seg[4]
          )
          employer = Employer.find_or_create_employer_by_fein(new_employer)
        end
        begin
          employer._id
        rescue
          raise("Unknown employer ID: #{emp_seg[3]} #{emp_seg[4]}")
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
          determine_transaction_set_kind(etf_loop),
          etf_loop
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
          (determine_transaction_set_kind(etf_loop) == "maintenance"))
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
