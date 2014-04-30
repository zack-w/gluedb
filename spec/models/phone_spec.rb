require 'spec_helper'

describe Phone do
  describe "validate associations" do
	  it { should be_embedded_in :person }
  end
end
