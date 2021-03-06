class Household
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia


#  field :rel, as: :relationship, type: String
  field :active, type: Boolean, default: true   # Household active on the Exchange?
  field :relationships, type: Array, default: []
  field :notes, type: String

#  validates :rel, presence: true, inclusion: {in: %w( subscriber responsible_party spouse life_partner child ward )}

  belongs_to :application_group, counter_cache: true
  has_many :people
  has_and_belongs_to_many :policies, inverse_of: nil

  embeds_many :person_relationships
  accepts_nested_attributes_for :person_relationships, reject_if: proc { |attribs| attribs['subject_person', 'relationship_kind', 'object_person'].blank? }, allow_destroy: true

  embeds_many :eligibilities
  accepts_nested_attributes_for :eligibilities, reject_if: proc { |attribs| attribs['date_determined'].blank? }, allow_destroy: true

  def self.create_for_people(the_people)
    found = self.where({
      "person_ids" => { 
        "$all" => the_people.map(&:id),
        "$size" => the_people.length
       }
    }).first
    return(nil) if found
    self.create!( :people => the_people )
  end

  def current_eligibility
    eligibilities.max_by { |e| e.date_determined }
  end

  # Value from latest eligibility determination
  def max_aptc
    current_eligibility.max_aptc
  end

  # Value from latest eligibility determination
  def csr_percent
    current_eligibility.csr_percent
  end

  def subscriber
    #TODO - correct when household has policy association
    people.detect do |person|
      person.members.detect do |member|
        member.enrollees.detect(&:subscriber?) 
      end
    end
  end

end
