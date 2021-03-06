require 'spec_helper'
describe Parsers::Edi::IncomingTransaction do

  let(:enrollee) { Enrollee.new(m_id: '1', 
                                relationship_status_code: 'self', 
                                employment_status_code: 'active', 
                                benefit_status_code: 'active',
                                coverage_start: "20140501",
                                coverage_end: "20140531" ) }
  let(:policy) do
    policy = Policy.new(eg_id: '1')
    policy.enrollees << enrollee
    policy.save!
    policy
  end

  let(:policy_loop) { double(id: '4321', action: :stop) }
  let(:person_loop) { double(member_id: '1', carrier_member_id: '1234', policy_loops: [policy_loop]) }
  let(:etf) { double(people: [person_loop], is_shop?: false) }
  let(:incoming) do 
    incoming = Parsers::Edi::IncomingTransaction.new(etf)
    incoming.policy_found(policy)
    incoming
  end

  it 'imports enrollee carrier member id' do
    incoming.import

    enrollee.reload
    expect(enrollee.c_id).to eq person_loop.carrier_member_id
  end

  it 'imports enrollee carrier policy id' do
    incoming.import

    enrollee.reload
    expect(enrollee.cp_id).to eq policy_loop.id
  end

  context 'when action policy action is stop' do 
    it 'sets enrollee coverage status to inactive' do
      incoming.import

      enrollee.reload
      expect(enrollee.coverage_status).to eq 'inactive'
    end

    context 'when coverage start/end are different' do
      let(:enrollee) { Enrollee.new(m_id: '1', 
                                  relationship_status_code: 'self', 
                                  employment_status_code: 'active', 
                                  benefit_status_code: 'active',
                                  coverage_start: "20140501",
                                  coverage_end: "20140531" ) }
      it 'sets the policy to terminated' do
        incoming.import

        expect(enrollee.policy.aasm_state).to eq 'terminated'
        expect(policy.aasm_state).to eq 'terminated'
      end
    end

    context 'when coverage start/end are the same' do 
      let(:enrollee) { Enrollee.new(m_id: '1', 
                                  relationship_status_code: 'self', 
                                  employment_status_code: 'active', 
                                  benefit_status_code: 'active',
                                  coverage_start: "20140501",
                                  coverage_end: "20140501" ) }
      it 'sets the policy to canceled' do
        incoming.import

        expect(enrollee.policy.aasm_state).to eq 'canceled'
        expect(policy.aasm_state).to eq 'canceled'
      end
    end
  end
end