require 'spec_helper'
describe Parsers::Edi::FindPolicy do
  context 'policy doesn\'t exist' do 
    it 'notifies listener of policy not found by fein' do
      listener = double
      find_policy = Parsers::Edi::FindPolicy.new(listener)

      subkeys = {
        eg_id: '6666', 
        carrier_id: '6666', 
        plan_id: '6666'
      }

      expect(listener).to receive(:policy_not_found)
    
      expect(find_policy.by_subkeys(subkeys)).to be_nil
    end
  end

  context 'policy exists' do
    it 'notifies listener of policy found by fein' do
      subkeys = {
        eg_id: '1234', 
        carrier_id: '1234', 
        plan_id: '1234'
      }
      policy = Policy.create(eg_id: subkeys[:eg_id], carrier_id: subkeys[:carrier_id], plan_id: subkeys[:plan_id])

      listener = double
      find_policy = Parsers::Edi::FindPolicy.new(listener)

      expect(listener).to receive(:policy_found)
      expect(find_policy.by_subkeys(subkeys)).to eq policy
    end
  end
end