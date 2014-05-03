require 'spec_helper'

describe TaxHousehold do
  describe "validate associations" do
	  it { should have_many :people }
  end
end
