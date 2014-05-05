require_relative File.join("..", "..", "..", "..", "spec_helper")

describe Parsers::Edi::Etf::PersonLoop do
  include EdiFactory

  let(:the_member_id) { "the member id" }

  let(:l2000) {
    {
          "REFs" => [
            member_id_ref_segment(the_member_id)
          ] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  its(:member_id) { should eq(the_member_id) }

end
