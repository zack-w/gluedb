require 'spec_helper'

describe ResponsibleParty do

  describe "validate associations" do
	  it { should be_embedded_in :person }
  end

end
