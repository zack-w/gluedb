class Eligibility
  include Mongoid::Document

	field :date_determined, type: Date
  field :max_aptc, type: BigDecimal, default: 0.00
  field :csr_amt, type: BigDecimal, default: 0.00

  embedded_in :tax_household

  validates_presence_of :date_determined, :max_aptc, :csr_amt

end
