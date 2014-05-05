class Household
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia
  include AASM


  field :rel, as: :relationship, type: String
  field :aasm_state, type: String

  validates :rel, presence: true, inclusion: {in: %w( subscriber responsible_party spouse life_partner child ward )}

  index({:aasm_state => 1})

  belongs_to :family, counter_cache: true
  has_many :people, dependent: :delete
  embeds_many :special_enrollment_periods, cascade_callbacks: true
  embeds_many :eligibilities

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