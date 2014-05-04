class SpecialEnrollmentPeriod
  include Mongoid::Document

	field :start_date, type: Date
	field :end_date, type: Date
	field :reason, type: String

	validates_presence_of :start_date, :end_date
	validate :end_date_before_start

  validates :reason, presence: true, 
  					allow_blank: false, 
  					allow_nil:   false,
  					inclusion: {in: %w( birth death adoption marriage legal_separation divorce retirement employment_termination reenrollment location_change )}


  embedded_in :household

	def end_date_before_start
		return if end_date.nil?
		errors.add(:end_date, "end_date cannot preceed start_date") if end_date < start_date
	end

	def calculate_end_date(period_in_days)
		self.end_date = start_date + period_in_days unless start_date.blank?
	end
end
