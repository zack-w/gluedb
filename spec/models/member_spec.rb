require 'spec_helper'

describe Member do

  before(:each) do
    @p1 = Person.create!(
          name_pfx: "Mrs",
          name_first: "Jane", 
          name_middle: "Jacob",
          name_last: "Jingle-Himer"
          )

    @p2 = Person.create!(
          name_first: "Sam", 
          name_last: "Spade"
          )
  end

  describe "validate associations" do
    it { should be_embedded_in :person }
  end


  describe "it should instantiate object" do
    let(:hbx_member_id) { "dc123243" }
    let(:date_1) { Time.new(1980,10,23,0,0,0) }
    let(:good_ssn) { "789999999" }
    let(:gender) { "female" }
    let(:tobacco) {"unknown"}
    let(:language) { "en"}
    let(:leading_zero_ssn) { "002450900" }

    it "sets and gets all basic model fields" do
      mbr = Member.new(
        hbx_member_id: hbx_member_id,
        dob: date_1,
        ssn: good_ssn,
        gender: gender,
        hlh: tobacco,
        lui: language
        )
      p = @p1
      p.members << mbr

      expect(p.members.first.hbx_member_id).not_to eq(nil)
      expect(p.members.first.hbx_member_id).to eq(hbx_member_id)
    end

    it "automatically assigns hbx_member_id if value isn't provided" do
      p = Person.find(@p2.id)
      p.members.build(
        dob: date_1,
        ssn: leading_zero_ssn,
        gender: gender,
        hlh: tobacco,
        lui: language
        )
      p.save!

      expect(p.members.first.hbx_member_id).not_to eq(nil)
      expect(p.members.first.hbx_member_id).to eq(p.members.first.id.to_s)
      expect(p.members.first.ssn).to eq(leading_zero_ssn)
    end
  end

end

describe Member, "given:
  - name_last of \"LaName\"
  - name_first of \"Exampile\"
  - dob of 19640229
  - totally a dude
" do
  let(:dob) { "19640229" }
  let(:name_last) { "LaName" }
  let(:name_first) { "Exampile" }
  let(:gender) { "male" }

  subject {
    Member.new(
      name_first: name_first,
      name_last: name_last,
      dob: dob,
      gender: gender
    )
  }

  it { should be_valid }

  it "should be valid with a blank ssn" do
    subject.ssn = ""
    subject.should be_valid
  end

  it "should be valid with a nil ssn" do
    subject.ssn = nil
    subject.should be_valid
  end

  it "should be valid with a nil hbx_member_id" do
    subject.hbx_member_id = nil
    subject.should be_valid
  end

end
