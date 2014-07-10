class DashboardsController < ApplicationController
	# layout 'dashboard'

  def index
  	@total_lives = Person.count
  	@total_employers = Employer.count
  	@total_enrollments = Policy.count
  	@total_edi_transactions = Protocols::X12::TransactionSetEnrollment.count

  	@last_month = Time.now.months_ago(1).strftime("%B")
  	@this_month = Time.now.strftime("%B")

    #Test
    @transactions = {}
		@transactions[:lw] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.weeks_ago(1).all_week).count
		@transactions[:lm] = Protocols::X12::TransactionSetHeader.where(submitted_at: Time.now.months_ago(1).all_month).count
		@transactions[:wtd] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.all_week).count
		@transactions[:mtd] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.all_month).count
		@transactions[:qtd] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.all_quarter).count
    @transactions[:ytd] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.all_year).count
    @transactions[:tot] = Protocols::X12::TransactionSetEnrollment.count

    @transactions[:dec] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.months_ago(4).all_month).count
    @transactions[:jan] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.months_ago(3).all_month).count
    @transactions[:feb] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.months_ago(2).all_month).count
    @transactions[:mar] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.months_ago(1).all_month).count
    @transactions[:apr] = Protocols::X12::TransactionSetEnrollment.where(submitted_at: Time.now.months_ago(0).all_month).count


    @response_metric = ResponseMetric.all
    @ambiguous_people_metric = AmbiguousPeopleMetric.all
  end
end
