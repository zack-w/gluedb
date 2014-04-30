require 'spec_helper'

describe PremiumPayment do
  describe "validate associations" do
	  it { should belong_to :employer }
	  it { should belong_to :carrier }
	  it { should belong_to :policy }
	  it { should belong_to :transaction_set_premium_payment }
  end

  describe "validate indexes" do
  	it { should have_index_for(paid_at: 1) }
  end

  p = Policy.create!(eg_id: "yut321")
  c = Carrier.create!(name: "acme health")

	PremiumPayment.create!(
			payment_amount_in_cents: 427.13 * 100,
			paid_at: "20140310",
			hbx_payment_type: "INTPREM",
			coverage_period: "20140401-20140430",
			hbx_member_id: "525987",
			hbx_policy_id: "3099617286944718848",
			hios_plan_id: "78079DC0230008-01",
			hbx_carrier_id: "999999999",
			employer_id: "010569723",
			policy: p,
			carrier: c
		)

	pp = PremiumPayment.first

  describe "properly instantiates object." do
		it "sets and gets all basic model fields" do
			pp.payment_amount_in_cents.should == 42713
			pp.paid_at.should == "20140310".to_date
			pp.hbx_payment_type.should == "INTPREM"
			pp.hbx_member_id.should == "525987"
			pp.hbx_policy_id.should == "3099617286944718848"
			pp.hios_plan_id.should == "78079DC0230008-01"
			pp.hbx_carrier_id.should == "999999999"
			pp.employer_id.should == "010569723"
		end

		it "generates start and end date from range" do
			pp.coverage_start_date.should == "20140401".to_date
			pp.coverage_end_date.should == "20140430".to_date
		end
	end

	describe "instance methods" do
		it "payment_in_dollars should return premium amount in currency format" do
			pp.payment_amount_in_dollars.should == 427.13
		end
	end

end
