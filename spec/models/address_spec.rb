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

    describe 'address type' do
      let(:address) { build(:address, :with_invalid_address_type) }
      context 'when invalid' do
        its 'invalid' do 
          expect(address).to be_invalid
        end
      end

      ['home', 'work', 'billing'].each do |type|
        context('when ' + type) do
          before { address.address_type = type}
          its 'valid' do
            expect(address).to be_valid
          end 
        end
      end
    end
  end

  describe 'view helpers/presenters' do 
    let(:address) do
        address = Address.new
        address.address_1 = '4321 Awesome Drive'
        address.address_2 = '#321'
        address.city = 'Washington'
        address.state = 'DC'
        address.zip = 20002
        address
    end
    describe '#formatted_address' do
      it 'returns a string with a formated address' do
        line_one = address.address_1
        line_two = address.address_2
        line_three = "#{address.city}, #{address.state} #{address.zip}"

        expect(address.formatted_address).to eq "#{line_one}<br/>#{line_two}<br/>#{line_three}"
      end
    end

    describe '#full_address' do
      it 'returns the full address in a single line' do
        expected_result = "#{address.address_1} #{address.address_2} #{address.city}, #{address.state} #{address.zip}"
        expect(address.full_address).to eq expected_result
      end
    end
  end
end
