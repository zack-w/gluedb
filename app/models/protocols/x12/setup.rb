module Protocols::X12

	IDENTIFYING_ATTRIBUTES = %w[name_first name_last, ssn dob employee_id_number]


	Struct.new(
			"Operation",
			:name,
			:maintenance_type,				# change, addition, cancel/term, reinstatement, audit/compare
			:maintenace_reason,
			:member_level_date_qualifier,
			:health_coverage_maintenance_type,
			:health_coverage_date_qualifier,
			:reporting_category_reference
		)

	Struct::Operation.new(
		"effective_date_change",
		"change",	# 001
		"29",
		"356",
		"001",
		"348",
		nil
		)


	Struct::Operation.new(
		:address_change,
		:change,
		:change_of_location,
		:maintenance_effective,
		:audit_or_compare,
		:benefit_begin,
		nil
		)



	# X12.setup do |config|

	# end

end