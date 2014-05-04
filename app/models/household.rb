class TaxHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia
  include AASM


  field :rel, as: :relationship, type: String
  field :aasm_state, type: String

  validates :rel, presence: true, inclusion: {in: %w( self spouse child ward life_partner )}

  index({:aasm_state => 1})

  belongs_to :family, counter_cache: true
  has_many :people, dependent: :delete
  embeds_many :special_enrollment_periods
  embeds_many :eligibilities

  # Value from latest eligibility determination
  def max_aptc
  end

  # Value from latest eligibility determination
  def csr
  end

  aasm do
    state :closed_enrollment, initial: true
    state :open_enrollment_period
    state :special_enrollment_period

    event :open_enrollment do
      transitions from: [:closed_enrollment, :special_enrollment_period], to: :open_enrollment_period
    end

    # TODO - what are rules around special enrollments that extend past open enrollment?
    event :special_enrollment do
      transitions from: [:closed_enrollment, :open_enrollment], to: :special_enrollment_period
    end

    event :close_enrollment do
      transitions from: [:open_enrollment, :special_enrollment_period], to: :closed_enrollment
    end
  end

end