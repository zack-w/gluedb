object @employer => :employer

attribute :name
attribute :fein
# child :contacts do
# end
attribute :hbx_uri
attribute :hbx_id
attribute :sic_code
attribute :fte_count

# child :employees do
# end

child :elected_plans => :plans do
  attribute :name
  attribute :hbx_plan_id
  attribute :qhp_id
  # attribute :carrier_name
  # attribute :carrier_urn
  attribute :carrier_policy_number => :policy_number
  attribute :carrier_employer_group_id => :group_id
  attribute :coverage_type
  attribute :original_effective_date
  attribute :metal_level => :metal_level_code
end

attribute :pte_count

# child :broker
attribute :open_enrollment_start
attribute :open_enrollment_end
attribute :plan_year_start 
attribute :plan_year_end
attribute :notes
