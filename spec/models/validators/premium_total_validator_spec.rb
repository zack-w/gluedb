require 'spec_helper'

describe Validators::PremiumTotalValidator do
  let(:validator) { Validators::PremiumTotalValidator.new(group, listener) }
  let(:group) { double }
  let(:listener) { double }

  context 'when total premium is incorrect' do
    before do 
      group.stub(:enrollee_premium_sum ) { 1.00 }
      group.stub(:premium_amount_total) { 666.66 }
    end
    it 'notifies listener' do
      expect(listener).to receive(:group_has_incorrect_premium_total).with({provided: 666.66, expected: 1.00})
      expect(validator.validate).to eq false
    end
  end

  context 'when total premium is correct' do
    before do 
      group.stub(:enrollee_premium_sum ) { 1.00 }
      group.stub(:premium_amount_total) { 1.00 }
    end
    it 'does not notify listener' do
      expect(listener).not_to receive(:group_has_incorrect_premium_total)
      expect(validator.validate).to eq true
    end
  end
end