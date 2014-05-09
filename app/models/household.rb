class Household
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia
  include AASM


#  field :rel, as: :relationship, type: String
  field :aasm_state, type: String
  field :active, type: Boolean, default: true   # Household active on the Exchange?
  field :notes, type: String

#  validates :rel, presence: true, inclusion: {in: %w( subscriber responsible_party spouse life_partner child ward )}

  index({:aasm_state => 1})

  belongs_to :family, counter_cache: true
  has_and_belongs_to_many :people, inverse_of: nil, foreign_key: "person_ids"
  embeds_many :special_enrollment_periods, cascade_callbacks: true
  accepts_nested_attributes_for :special_enrollment_periods, reject_if: proc { |attribs| attribs['start_date'].blank? }, allow_destroy: true

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

  # List of SEPs active for this Household on this or specified date
  def active_seps(day = Date.today)
    special_enrollment_periods.find_all { |sep| (sep.start_date..sep.end_date).include?(day) }
  end

  # single SEP with latest end date from list of active SEPs
  def current_sep
    active_seps.max { |sep| sep.end_date }
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

  aasm do
    state :closed_enrollment, initial: true
    state :open_enrollment_period
    state :special_enrollment_period

    event :open_enrollment do
      transitions from: [:closed_enrollment, :special_enrollment_period, :open_enrollment_period], to: :open_enrollment_period
    end

    # TODO - what are rules around special enrollments that extend past open enrollment?
    event :special_enrollment do
      transitions from: [:closed_enrollment, :open_enrollment_period, :special_enrollment_period], to: :special_enrollment_period
    end

    event :close_enrollment do
      transitions from: [:open_enrollment_period, :special_enrollment_period, :closed_enrollment], to: :closed_enrollment
    end
  end

end
