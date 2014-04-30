require 'spec_helper'

describe Household do
  describe "validate associations" do
	  it { should have_many :people }
  end
end
