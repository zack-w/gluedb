class PremiumTable
  include Mongoid::Document

	field :rate_start_date, type: Date
	field :rate_end_date, type: Date
	field :age, type: Integer
	field :amount, type: BigDecimal, default: 0.0

	embedded_in :plan

  index({ age: 1 })

	# Provide premium rate given the rate schedule, date coverage will start, and applicant age when coverage starts
	def calculate_rate(rate_period_date, benefit_begin_date, date_of_birth)

	end


end
