class Protocols::X12::TransactionSetPremiumPayment < Protocols::X12::TransactionSetHeader

	# ASC X12 820 Benefit Enrollment Transaction
	field :bpr01, as: :transaction_handling_code, type: String
	field :bpr02, as: :total_payment_amount, type: String
	field :bpr03, as: :credit_or_debit_flag_code, type: String
	field :bpr04, as: :payment_method_code, type: String
	field :bpr05, as: :payment_format_code, type: String
	field :bpr12, as: :depository_financial_institution_dfi_identifier, type: String
	field :bpr13, as: :receiving_depository_financial_institution_dfi_identifier, type: String
	field :bpr14, as: :account_number_qualifier, type: String
	field :bpr15, as: :receiver_bank_account_number, type: String
	field :bpr16, as: :check_issue_or_eft_effective_date, type: String

	field :trn01, as: :trace_type_code, type: String
	field :trn02, as: :check_or_eft_trace_number, type: String

	field :payment_at, type: Date

  index({"check_or_eft_trace_number" => 1})


	belongs_to :carrier
  has_many :premium_payments

	before_create :parse_check_issue_or_eft_effective_date

protected
	def parse_check_issue_or_eft_effective_date
		self.payment_at = self.check_issue_or_eft_effective_date.to_date
	end


end
