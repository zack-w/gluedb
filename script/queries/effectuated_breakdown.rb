policy_ids = Protocols::X12::TransactionSetHeader.collection.aggregate(
  {"$match" => {"transaction_kind" => "effectuation", "_type"=>"Protocols::X12::TransactionSetEnrollment"}},
  {"$group" => {"_id" => "$policy_id"}}
).map { |r| r["_id"] }.uniq

puts policy_ids.length.inspect

dental_plan_ids = Plan.where({"coverage_type" => "dental"}).map(&:id).map { |tid| Moped::BSON::ObjectId.from_string(tid) }

policies = Policy.where(
  {"_id" => {"$in" => policy_ids}, "plan_id" => { "$nin" => dental_plan_ids},  "eg_id" => {"$not" => /DC0.{32}/}}.merge(Policy.active_as_of_expression(Time.now))
)

m_ids = []

policies.each do |pol|
  pol.enrollees.each do |en|
    m_ids << en.m_id
  end
end

m_ids.uniq!


puts "Effectuated Policies: #{policies.count}"
puts "Effectuated Lives: #{m_ids.uniq.length}"
