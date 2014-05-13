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

  describe '#has_responsible_person?' do
    let(:policy) { Policy.new(eg_id: '1') }
    context 'no responsible party ID is set' do
      before { policy.responsible_party_id = nil }

      it 'return false' do
        expect(policy.has_responsible_person?).to be_false
      end
    end

    context 'responsible party ID is set' do
      before { policy.responsible_party_id = 2 }

      it 'return true' do
        expect(policy.has_responsible_person?).to be_true
      end
    end
  end

  describe '#responsible_person' do
    let(:id) { 1 }
    let(:policy) { Policy.new(eg_id: '1') }
    let(:person) { Person.new(name_first: 'Joe', name_last: 'Dirt') }
    let(:responsible_party) { ResponsibleParty.new(_id: id, entity_identifier: "parent") }
    before do
      person.responsible_parties << responsible_party
      person.save!
      policy.responsible_party_id = responsible_party._id
    end
    it 'returns the person that has a responsible party that matches the policy responsible party id' do
      expect(policy.responsible_person).to eq person
    end
  end

  describe '#people' do
    let(:policy) { Policy.new(eg_id: '1') }
    let(:lookup_id) { '666' }
    let(:person) { Person.new(name_first: 'Joe', name_last: 'Dirt') }

    before do
      enrollee = Enrollee.new(relationship_status_code: 'self', employment_status_code: 'active', benefit_status_code: 'active')
      enrollee.m_id = lookup_id
      policy.enrollees << enrollee

      person.members << Member.new(gender: 'male', hbx_member_id: lookup_id) 
      person.save!
    end

    it 'returns people whose members ids match the policy enrollees ids' do
      expect(policy.people).to eq [person] 
    end
  end

  describe '#edi_transaction_sets' do
    let(:transation_set_enrollment) { Protocols::X12::TransactionSetEnrollment.new(ts_purpose_code: '00', ts_action_code: '2', ts_reference_number: '1', ts_date: '1', ts_time: '1', ts_id: '1', ts_control_number: '1', ts_implementation_convention_reference: '1', transaction_kind: 'initial_enrollment') }
    let(:policy) { Policy.new(eg_id: '1') }
    context 'transaction set enrollment policy id matches policys id' do
      before do 
        policy.save!
        transation_set_enrollment.policy_id = policy._id
        transation_set_enrollment.save
      end
      it 'returns the transation set' do
        expect(policy.edi_transaction_sets.to_a).to eq [transation_set_enrollment]
      end
    end

    context 'transaction set enrollment policy id does not matche policys id' do
      before do 
        policy.save!
        transation_set_enrollment.policy_id = '444'
        transation_set_enrollment.save
      end
      it 'returns the transation set' do
        expect(policy.edi_transaction_sets.to_a).to eq []
      end
    end
  end

  describe '#merge_enrollee' do
    let(:policy) { Policy.new(eg_id: '1') }
    let(:enrollee) { Enrollee.new(m_id: '1', relationship_status_code: 'self', employment_status_code: 'active', benefit_status_code: 'active') }

    context 'no enrollee with member id exists' do
      before { policy.merge_enrollee(enrollee, :stop) }

      context 'action is stop' do 
        it 'coverage_status changes to inactive' do
          expect(enrollee.coverage_status).to eq 'inactive'
        end
      end

      it 'adds enrollee to the policy' do
        expect(policy.enrollees).to include(enrollee)
      end
    end

    context 'enrollee with member id exists' do
      before { policy.enrollees << enrollee }
      it 'calls enrollees merge_enrollee' do
        enrollee.stub(:merge_enrollee)
        policy.merge_enrollee(enrollee, :stop)
        expect(enrollee).to have_received(:merge_enrollee)
      end
    end
  end

  describe '#hios_plan_id' do
    let(:policy) { Policy.new }
    let(:plan) { Plan.new(hbx_plan_id: '666') }
    
    before { policy.plan = plan }
    
    it 'returns the policys plan hios id' do
      expect(policy.hios_plan_id).to eq plan.hios_plan_id
    end
  end

  describe '#coverage_type' do
    let(:policy) { Policy.new }
    let(:plan) { Plan.new(coverage_type: 'health') }
    
    before { policy.plan = plan }
    
    it 'returns the policys plan coverage type' do
      expect(policy.coverage_type).to eq plan.coverage_type
    end
  end

  describe '#enrollee_for_member_id' do
    let(:policy) { Policy.new }
    context 'given there are no policy enrollees with the member id' do
      it 'returns nil' do
        expect(policy.enrollee_for_member_id('888')).to eq nil
      end
    end

    context 'given a policy enrollee with the member id' do
      let(:member_id) { '666'}
      let(:enrollee) { Enrollee.new(m_id: member_id) }
      
      before { policy.enrollees << enrollee }

      it 'returns the enrollee' do
        expect(policy.enrollee_for_member_id(member_id)).to eq enrollee
      end
    end
  end

  describe '.find_all_policies_for_member_id' do
    let(:member_id) { '666' }
    let(:policy) { Policy.new(eg_id: '1') }
    before do
      policy.save!
    end
    context 'given no policy has enrollees with the member id' do
      it 'returns an empty array' do
        expect(Policy.find_all_policies_for_member_id(member_id)).to eq []
      end
    end

    context 'given policies has enrollees with the member id' do
      before do
        policy.enrollees << Enrollee.new(m_id: member_id, relationship_status_code: 'self', employment_status_code: 'active', benefit_status_code: 'active')
        policy.save!
      end
      it 'returns the policies' do
        expect(Policy.find_all_policies_for_member_id(member_id).to_a).to eq [policy]
      end
    end
  end

  describe '.find_by_sub_and_plan' do
    it 'finds policies matching subscriber member id and plan id' do
      member_id = '666'
      plan = Plan.new(coverage_type: 'health')
      policy = Policy.new(eg_id: '1')
      subscriber = Enrollee.new(m_id: member_id, rel_code: 'self', employment_status_code: 'active', benefit_status_code: 'active')

      policy.enrollees << subscriber
      
      plan.policies << policy # policy.plan = plan

      policy.save!

      plan.save!

      expect(Policy.find_by_sub_and_plan(member_id, plan._id)).to eq policy
    end
  end

  describe '.find_by_subkeys' do
    let(:eg_id) { '1' }
    let(:carrier_id) { '2' }
    let(:plan_id) { '3' }
    let(:policy) { Policy.new(eg_id: eg_id, carrier_id: carrier_id, plan_id: plan_id) }
    before { policy.save! }
    it 'finds policy by eg_id, carrier_id, and plan_id' do
      expect(Policy.find_by_subkeys(eg_id, carrier_id, plan_id)).to eq policy
    end
  end

  describe '.find_or_update_policy' do
    let(:eg_id) { '1' }
    let(:carrier_id) { '2' }
    let(:plan_id) { '3' }
    let(:policy) { Policy.new(enrollment_group_id: eg_id, carrier_id: carrier_id, plan_id: plan_id)}
    let(:responsible_party_id) { '1' }
    let(:employer_id) { '2' }
    let(:broker_id) { '3' }
    let(:applied_aptc) { 1.0 }
    let(:tot_res_amt) { 1.0 }
    let(:pre_amt_tot) { 1.0 }
    let(:employer_contribution) { 1.0 }
    let(:carrier_to_bill) { true }

    before do
      policy.responsible_party_id = responsible_party_id
      policy.employer_id = employer_id
      policy.broker_id = broker_id
      policy.applied_aptc = applied_aptc
      policy.tot_res_amt = tot_res_amt
      policy.pre_amt_tot = pre_amt_tot
      policy.employer_contribution = employer_contribution
      policy.carrier_to_bill = carrier_to_bill
    end
    context 'given policy exists' do
      let(:existing_policy) { Policy.new(eg_id: eg_id, carrier_id: carrier_id, plan_id: plan_id) }
      before { existing_policy.save! }
      it 'finds and updates the policy' do
        found_policy = Policy.find_or_update_policy(policy)

        expect(found_policy).to eq existing_policy
        
        expect(found_policy.responsible_party_id).to eq responsible_party_id
        expect(found_policy.employer_id).to eq employer_id
        expect(found_policy.broker_id).to eq broker_id
        expect(found_policy.applied_aptc).to eq applied_aptc
        expect(found_policy.tot_res_amt).to eq tot_res_amt
        expect(found_policy.pre_amt_tot).to eq pre_amt_tot
        expect(found_policy.employer_contribution).to eq employer_contribution
        expect(found_policy.carrier_to_bill).to eq carrier_to_bill
      end
    end

    context 'given no policy exists' do
      it 'saves the policy' do
        found_policy = Policy.find_or_update_policy(policy)
        expect(found_policy.persisted?).to eq true
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
