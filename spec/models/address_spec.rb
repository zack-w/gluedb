require 'spec_helper'

describe Address do
  describe "validate associations" do
    it { should be_embedded_in :person }
    it { should be_embedded_in :employer }
  end

  [:address_type, :address_1, :address_2, :city, :state, :zip].each do |attribute|
    it { should respond_to attribute }
  end

  describe 'validations' do
    describe 'presence' do 
      [:address_1, :city, :state, :zip].each do |missing|
        its('invalid without ' + missing.to_s) do
          trait = 'without_' + missing.to_s
          address = build(:address, trait.to_sym)
          expect(address).to be_invalid
        end
      end
    end
  end
end
