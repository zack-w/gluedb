require 'spec_helper'

describe Validators::PremiumResponsibleValidator do
  let(:enrollment_group) { double }
  let(:listener) { double }
  let(:validator) { Validators::PremiumResponsibleValidator.new(enrollment_group, listener) }

  context 'when responsible amount is incorrect' do
    before do 
      enrollment_group.stub(:premium_amount_total) { 2.00 }
      enrollment_group.stub(:credit) { 1.00 } 
      enrollment_group.stub(:total_responsible_amount) { 6666.00 } 
    end

    it 'notifies the listener' do
      expect(listener).to receive(:group_has_incorrect_responsible_amount).with({provided: 6666.00, expected: 1.0})
      expect(validator.validate).to eq false
    end
  end

  context 'when responsible amount is correct' do
    before do 
      enrollment_group.stub(:premium_amount_total) { 2.00 }
      enrollment_group.stub(:credit) { 1.00 } 
      enrollment_group.stub(:total_responsible_amount) { 1.00 } 
    end
    
    it 'does not notify the listener' do
      expect(listener).not_to receive(:invalid_responsible_amount)
      validator.validate
      expect(validator.validate).to eq true
    end
  end
end