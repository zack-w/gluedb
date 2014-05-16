require 'spec_helper'

shared_examples "a responsible party query" do
  let(:first_name) { "A first name" }
  let(:last_name) { "A last name" }

  let(:expected_query) {
    {
      "responsible_parties.0" => { "$exists" => true },
      :name_first => Regexp.new(Regexp.escape(first_name), true),
      :name_last => Regexp.new(Regexp.escape(last_name), true)
    }.merge(additional_query_info)
  }

  subject {
    person.stub(:name_first) { first_name }
    person.stub(:name_last) { last_name }
    Queries::ExistingResponsibleParty.new(person)
  }

  it "should properly query for an existing responsible party" do
    expect(Person).to receive(:where).with(expected_query).and_return([])
    subject.execute
  end

end

describe Queries::ExistingResponsibleParty, "
given a person with:
- a first name
- last name
- no middle name
" do

  let(:person) {
    double(
      "person",
      :name_middle => "",
      :phones => [],
      :addresses => [],
      :emails => []
    )
  }

  let(:additional_query_info) {
    { "$or" => [] }
  }

  it_should_behave_like "a responsible party query"
end

describe Queries::ExistingResponsibleParty, "
given a person with:
- a first name
- last name
- a middle name
- multiple phones
" do
  let(:middle_name) { "A middle name" }
  let(:phone_type_one) { "home" }
  let(:phone_type_two) { "work" }
  let(:phone_number_one) { "12345" }
  let(:phone_number_two) { "12345" }

  let(:person) {
    phone_one = double("phone1",
                      :phone_type => phone_type_one,
                      :phone_number => phone_number_one
                )
    phone_two = double("phone2",
                      :phone_type => phone_type_two,
                      :phone_number => phone_number_two
                )
    double(
      "person",
      :name_middle => middle_name,
      :phones => [phone_one, phone_two],
      :addresses => [],
      :emails => []
    )
  }

  let(:additional_query_info) {
    { 
      :name_middle => Regexp.compile(Regexp.escape(middle_name), true), 
      "$or" => [
        {"phones" => { "$elemMatch" => {
          "phone_type" => phone_type_one,
          "phone_number" => phone_number_one
        }}},
        {"phones" => { "$elemMatch" => {
          "phone_type" => phone_type_two,
          "phone_number" => phone_number_two
        }}} 
      ] 
    }
  }

  it_should_behave_like "a responsible party query"
end
