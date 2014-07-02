class PremiumTable
  include Mongoid::Document

	field :rate_start_date, type: Date
	field :rate_end_date, type: Date
	field :age, type: Integer
	field :amount, type: BigDecimal, default: 0.0

	embedded_in :plan

  index({ age: 1 })
  index({ rate_start_date: 1 })
  index({ rate_end_date: 1 })
end
