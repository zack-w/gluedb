class TaxHousehold
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia

  # A tax household

  field :rel, as: :relationship, type: String
  field :aptc_total, type: BigDecimal, default: 0.00
  field :csr_amt, type: BigDecimal, default: 0.00

  validates_presence_of :rel
	validates_inclusion_of :rel, in: ["self", "spouse", "dependent"]

  has_many :people, dependent: :delete
  embeds_many :special_enrollment_periods
  embeds_many :eligibilities



end