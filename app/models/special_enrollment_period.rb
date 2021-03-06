class SpecialEnrollmentPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

	field :start_date, type: Date
	field :end_date, type: Date
	field :reason, type: String

	validates_presence_of :start_date, :end_date
	validate :end_date_follows_start_date

  validates :reason, presence: true, 
  					allow_blank: false, 
  					allow_nil:   false,
  					inclusion: {in: %w( birth death adoption marriage legal_separation divorce retirement employment_termination reenrollment location_change open_enrollment_start )}


  embedded_in :application_group
  before_create :activate_household_sep
  before_save :activate_household_sep

	def calculate_end_date(period_in_days)
		self.end_date = start_date + period_in_days unless start_date.blank?
	end

private
	def end_date_follows_start_date
		return if end_date.nil?
		# Passes validation if end_date == start_date
		errors.add(:end_date, "end_date cannot preceed start_date") if end_date < start_date
	end

	def activate_household_sep
		sep_period = start_date..end_date
		return unless sep_period.include?(Date.today)
		return if household.special_enrollment_periods.any? { |sep| sep.end_date > self.end_date }

		self.reason == "open_enrollment_start" ? household.open_enrollment : household.special_enrollment 
	end

end
