module Parsers
  module Edi
    class RemittanceTransmission
      attr_reader :result
      def initialize(path, r_data)
        @result = Oj.load(r_data)
        @file_name = File.basename(path)
      end

      def persist!
        return nil if transmission_already_exists?
        edi_transmission = persist_edi_transmission(@result)
        carrier = edi_transmission.receiver
        @result["L820s"].each do |l820|
          transaction = persist_edi_transaction(l820, edi_transmission, carrier)
          persist_premium_payments(l820, carrier, transaction)
        end
      end

      def persist_edi_transaction(l820, edi_transmission, carrier)
        st = l820["ST"]
        bpr = l820["BPR"]
        trn = l820["TRN"]
        fs = FileString.new(st[2] + "_" + @file_name, l820["RAW_CONTENT"])
        Protocols::X12::TransactionSetPremiumPayment.create!(
          :st01 => st[1],
          :st02 => st[2],
          :st03 => st[3],
          :bpr01 => bpr[1],
          :bpr02 => bpr[2],
          :bpr03 => bpr[3],
          :bpr04 => bpr[4],
          :bpr05 => bpr[5],
          :bpr12 => bpr[12],
          :bpr13 => bpr[13],
          :bpr14 => bpr[14],
          :bpr15 => bpr[15],
          :bpr16 => bpr[16],
          :trn01 => trn[1],
          :trn02 => trn[2],
          :transmission => edi_transmission,
          :carrier_id => carrier._id,
          :transaction_kind => "remittance",
          :body => fs
        )
      end

      def persist_premium_payments(l820, carrier, transaction)
        l820["L2000s"].each do |l2000|
          persist_payment_entry(l2000, carrier, transaction)
        end
      end

      def persist_payment_entry(l2000, carrier, transaction)
        l2100 = l2000["L2100"]
        refs = l2100["REFs"]
        eg_id = refs.detect do |ref|
          ref[1] == "POL"
        end[2]
        hios_id = refs.detect do |ref|
          ref[1] == "TV"
        end[2]
        plan = Plan.find_by_hios_id(hios_id)
        policy = Policy.find_by_subkeys(eg_id, carrier._id, plan._id)
        unless policy
          policy = Policy.find_by_sub_and_plan(eg_id, plan._id)
        end
        return(nil) if policy.nil?
        l2300s = l2000["L2300s"]
        l2300s.each do |l2300|
          p_payment = PremiumPayment.new({
            :policy_id => policy._id,
            :carrier_id => carrier._id,
            :transaction_set_premium_payment_id => transaction._id,
            :paid_at => transaction.bpr16,
            :employer => policy.employer,
            :hbx_payment_type => l2300["RMR"][2],
            :coverage_period => l2300["DTM"][6],
            :payment_amount_in_cents => 0
          })
          p_payment.payment_amount_in_dollars = l2300["RMR"][4]
          p_payment.save!
        end
      end

      def persist_edi_transmission(top_doc)
        isa = top_doc["ISA"]
        gs = top_doc["GS"]
        Protocols::X12::Transmission.create!({
          :isa06 => isa[6].strip,
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

      def transmission_already_exists?
        Protocols::X12::Transmission.where({
          :file_name => @file_name
        }).any?
      end

    end
  end
end
