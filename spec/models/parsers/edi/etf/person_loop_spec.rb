require_relative File.join("..", "..", "..", "..", "spec_helper")

describe Parsers::Edi::Etf::PersonLoop, "
given:
 - a member id
 - a relationship code
 - a benefit status
 - an employment status
 - a non-subscriber relationship code
" do
  include EdiFactory

  let(:the_member_id) { "the member id" }
  let(:the_relationship_code) { "the relationship code" }
  let(:the_benefit_status_code) { "the benefit status code" }
  let(:the_employment_status_code) { "the employment status code" }

  let(:l2000) {
    {
          "INS" => [0, nil, the_relationship_code, nil, nil, the_benefit_status_code, nil, nil, the_employment_status_code],
          "REFs" => [
            member_id_ref_segment(the_member_id)
          ] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  its(:member_id) { should eq(the_member_id) }
  its(:carrier_member_id) { should be_nil }
  its(:rel_code) { should eq(the_relationship_code) }
  its(:ben_stat) { should eq(the_benefit_status_code) }
  its(:emp_stat) { should eq(the_employment_status_code) }

  it { should_not be_subscriber }

end


describe Parsers::Edi::Etf::PersonLoop, "
given:
 - a carrier_member_id
 - a subscriber relationship code
 - no employment status, but an INS segment
" do
  include EdiFactory

  let(:carrier_member_id) { "the carrier member id" }

  let(:l2000) {
    {
          "INS" => [0, nil, "18", nil, nil],
          "REFs" => [
            carrier_member_id_ref_segment(carrier_member_id)
          ] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  its(:carrier_member_id) { should eq(carrier_member_id) }
  its(:emp_stat) { should be_nil }

  it { should be_subscriber }

end
