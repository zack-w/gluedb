require 'spec_helper'

describe Policy do
  it { should have_index_for(eg_id: 1) }

  describe "with proper associations" do
	  it { should belong_to :employer }
	  it { should belong_to :carrier }
	  it { should belong_to :broker }
	  it { should belong_to :plan }
  end

  [
    :eg_id,
    :preceding_enrollment_group_id,
    :allocated_aptc,
    :elected_aptc,
    :applied_aptc,
    :csr_amt,
    :pre_amt_tot,
    :tot_res_amt,
    :tot_emp_res_amt,
    :sep_reason,
    :carrier_to_bill,
    :aasm_state,
    :enrollees,
    :carrier,
    :broker,
    :plan,
    :employer,
    :responsible_party,
    :transaction_set_enrollments,
    :premium_payments
  ].each do |attribute|
    it { should respond_to attribute }
  end

  describe '#subscriber' do
    let(:policy) { Policy.new(eg_id: '1') }
    let(:enrollee) { Enrollee.new(m_id: '1', relationship_status_code: relationship, employment_status_code: 'active', benefit_status_code: 'active') }
    
    before do
      policy.enrollees << enrollee
      policy.save!
    end
    
    context 'given no enrollees with relationship of self' do
      let(:relationship) { 'child' }
      it 'returns nil' do
        expect(policy.subscriber).to eq nil
      end
    end

    context 'given an enrollee with relationship of self' do
      let(:relationship) { 'self' }
      it 'returns nil' do
        expect(policy.subscriber).to eq enrollee
      end
    end

  end

end

describe Policy, "given:
  - a subscriber with id 454321
  - a spouse with id 23234545
  - a single child with id 948521
  - a csr_amt of 0.72
  - an elected aptc of 250.00
  - an allocated aptc 200.00
  - a premium total amount of 1001.93
  - a request_submit_timestamp of 20040229 120000
" do
  let(:subscriber_id) { "454321"}
  let(:spouse_id) { "23234545" }
  let(:dependent_id) { "948521" }
  let(:alloc_aptc) { 250.00 }
  let(:elected_aptc) { 200.00 }
  let(:csr_amt) { 0.72 }
  let(:prem_amt) { 285.46 }
  let(:prem_amt1) { 517.17 }
  let(:pre_amt_tot) { 1001.93 }
  let(:timestamp) { Time.mktime(2004, 2, 29, 12, 0, 0) }


		subject {
			pol = Policy.new(
  		eg_id: "-252525373738",
  		preceding_enrollment_id: "858525256565",
  		allocated_aptc: alloc_aptc,
  		elected_aptc: elected_aptc,
  		applied_aptc: elected_aptc,
  		csr_amt: csr_amt,
  		status: "active",
  		pre_amt_tot: pre_amt_tot,
  		tot_res_amt: pre_amt_tot,
  		rs_time: timestamp,
  		carrier_to_bill: true,
  		enrollees:[{
  			hbx_member_id: subscriber_id,
  			disabled_status: false,
  			benefit_status_code: "active",
  			employment_status_code: "active",
  			relationship_status_code: "self",
  			carrier_member_id: "carrierid123",
  			carrier_policy_id: "policyid987",
  			premium_amount: prem_amt1,
  			coverage_start: "20140501",
  			coverage_end: "20140531"
  		},
	  	{
  			hbx_member_id: spouse_id,
  			disabled_status: false,
  			benefit_status_code: "active",
  			employment_status_code: "active",
  			relationship_status_code: "spouse",
  			carrier_member_id: "carrierid456",
  			carrier_policy_id: "policyid654",
  			premium_amount: prem_amt1,
  			coverage_start: "20140501",
  			coverage_end: "20140531"
  		},
  	  {
  			hbx_member_id: dependent_id,
  			disabled_status: false,
  			benefit_status_code: "active",
  			employment_status_code: "active",
  			relationship_status_code: "child",
  			carrier_member_id: "carrierid111",
  			carrier_policy_id: "policyid999",
  			premium_amount: prem_amt,
  			coverage_start: "20140501",
  			coverage_end: "20140531"
  		}]
		)
	pol.save!
  Policy.find(pol.id)
}

its(:elected_aptc) { should eql(elected_aptc) }
its(:applied_aptc) { should eq(elected_aptc) }
its(:allocated_aptc) { should eq(alloc_aptc) }
its(:csr_amt) { should eq(csr_amt) }
its(:status) { should eq("active") }
it { should have(3).enrollees }
it { should be_carrier_to_bill }
its(:pre_amt_tot) { should eq(pre_amt_tot) }
its(:tot_res_amt) { should eq(pre_amt_tot) }
its(:rs_time) { should eq(timestamp) }
its(:eg_id) { should eq("-252525373738") }

it "should return correct enrollee for subscriber" do
  subject.subscriber.hbx_member_id.should == subscriber_id
end

end
