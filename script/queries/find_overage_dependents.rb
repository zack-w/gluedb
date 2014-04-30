require 'csv'

children =  Policy.where("enrollees.rel_code" => "child").map { |pol| pol.enrollees.select { |en| en.rel_code == "child" }.map(&:m_id) }.flatten.uniq

people = Person.where('members' => { "$elemMatch" => {
  "hbx_member_id" => { "$in" => children },
  "dob" => {"$lte" => (Date.today - 26.years)}}} )

csv = CSV.open("overage_dependents.csv", 'w')
csv << ["first name", "middle name", "last name", "dob"]
people.each do |p|
  csv << [p.name_first, p.name_middle, p.name_last, p.members.first.dob.strftime("%Y%m%d")]
end

csv.close
