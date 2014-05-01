policy_ids = Protocols::X12::TransactionSetHeader.collection.aggregate(
  {"$match" => {"transaction_kind" => "effectuation", "_type"=>"Protocols::X12::TransactionSetEnrollment"}},
  {"$group" => {"_id" => "$policy_id"}}
).map { |r| r["_id"] }.uniq

people = Policy.collection.aggregate(
  {"$match" => {"_id" => {"$in" => policy_ids}, "aasm_state" => {"$nin" => ["cancelled", "terminated"]}}},
  {"$unwind" => "$enrollees"},
  {"$group" => {"_id" => "1", "enrollees" => {"$addToSet" => "$enrollees.m_id"}}},
  {"$unwind" => "$enrollees"},
  {"$group" => {"_id" => "1", "enrollees" => {"$sum" => 1}}}
#  {"$sort" => {"enrollees" => -1}},
).first

policies = Policy.where(
  {"_id" => {"$in" => policy_ids}, "aasm_state" => {"$nin" => ["cancelled", "terminated"]}}
).count

puts "Effectuated Policies: #{policies}"
puts "Effectuated Lives: #{people['enrollees']}"
