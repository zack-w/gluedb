module Parsers
  module XTwelve
    class RawPlan
      attr_accessor :hios_id, :pre_amt_tot, :tot_res_amt, :emp_contribution, :aptc, :plan_kind

      include EtfXpath

      def initialize(doc)
        plan_node = xpath(doc, "//etf:Loop_2300").first
        @plan_kind = xpath(plan_node, "etf:HD_HealthCoverage_2300/etf:HD03__InsuranceLineCode").first.text
        @hios_id = xpath(
          plan_node, "etf:REF_HealthCoveragePolicyNumber_2300[etf:REF01__ReferenceIdentificationQualifier='CE']/etf:REF02__MemberGroupOrPolicyNumber"
        ).first.text
        @pre_amt_tot = xpath(
          doc,
          expr_for_2700("PRE AMT TOT")
        ).first.text
        @tot_res_amt = xpath(
          doc,
          expr_for_2700("TOT RES AMT")
        ).first.text
        aptc_node = xpath(
          doc,
          expr_for_2700("APTC AMT")
        )
        @aptc = aptc_node.any? ? aptc_node.first.text : 0.00
        emp_res_node = xpath(
          doc,
          expr_for_2700("TOT EMP RES AMT")
        )
        @emp_contribution = emp_res_node.any? ? emp_res_node.first.text : 0.00
        @carrier_to_bill = xpath(doc, expr_for_2700("CARRIER TO BILL")).any?
      end

      def expr_for_2700(lbl)
        "//etf:Loop_2750[etf:N1_ReportingCategory_2750/etf:N102__MemberReportingCategoryName = '#{lbl}']/etf:REF_ReportingCategoryReference_2750/etf:REF02__MemberReportingCategoryReferenceID"
      end

      def to_model(carrier_id, enrollment_group_id, ben_begin, rs_timestamp)
        coverage_kind = (@plan_kind.strip == 'HLT') ? "health" : "dental"
        Enrollment.new(
          :carrier_to_bill => @carrier_to_bill,
          :hios_plan_id => @hios_id,
          :pre_amt_tot => @pre_amt_tot,
          :applied_aptc => @aptc,
          :tot_res_amt => @tot_res_amt,
          :employer_contribution => @emp_contribution,
          :carrier_id => carrier_id,
          :coverage_type => coverage_kind,
          :enrollment_group_id => enrollment_group_id,
          :bgn_date => ben_begin,
          :request_submit_timestamp => rs_timestamp
        )
      end
    end
  end
end
