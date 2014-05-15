require 'spec_helper'

describe PremiumTable do
  describe "with proper associations" do
	  it { should be_embedded_in :plan }
  end

	[
		:market_tyoe,
		:rate_start_date,
		:rate_end_date,
		:age
		:amount
    ].each do |attribute|
    it { should respond_to attribute }
  end

  describe '#calculate_rate' do
	end

end