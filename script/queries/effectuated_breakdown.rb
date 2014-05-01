policy_ids = Protocols::X12::TransactionSetHeader.collection.aggregate(
  {"$match" => {"transaction_kind" => "effectuation", "_type"=>"Protocols::X12::TransactionSetEnrollment"}},
  {"$group" => {"_id" => "$policy_id"}}
).map { |r| r["_id"] }.uniq

people = Policy.collection.aggregate(
  {"$match" => {"_id" => {"$in" => policy_ids}, "eg_id" => {"$not" => /DC0.{32}/}}.merge(Policy.active_as_of_expression(Time.now))},
  {"$group" => {"_id" => "1", "enrollee_list" => {"$addToSet" => "$enrollees.m_id"}}},
).first['enrollee_list'].uniq

policies = Policy.where(
  {"_id" => {"$in" => policy_ids}, "eg_id" => {"$not" => /DC0.{32}/}}.merge(Policy.active_as_of_expression(Time.now))
)

dental_plan_ids = Plan.where({"coverage_type" => "dental"}).map(&:id)

dental_policies = Policy.where(
  {"_id" => {"$in" => policy_ids}, "plan_id" => { "$in" => dental_plan_ids}, "eg_id" => {"$not" => /DC0.{32}/}}.merge(Policy.active_as_of_expression(Time.now))
)

puts dental_policies.last.enrollees.first.person.id

m_ids = []

policies.each do |pol|
  m_ids << pol.enrollees.map(&:m_id)
end

m_ids.uniq!


puts "Effectuated Policies: #{policies.count}"
puts "Effectuated Lives: #{people.length}"
puts "Effectuated Lives (counted the hard way): #{m_ids.length}"
puts "Dental Policies: #{dental_policies.count}"
