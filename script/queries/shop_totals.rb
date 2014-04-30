actives = Policy.active_as_of_expression(Date.new(2014, 4, 24))
active_shops = actives.merge({:employer_id => { "$ne" => nil }})
active_pols = Policy.where(active_shops)
pol_total = Policy.where(active_shops).count

jan_pols = Policy.find_covered_in_range(Date.new(2014, 1, 1), Date.new(2014,1,31))
feb_pols = Policy.find_covered_in_range(Date.new(2014, 2, 1), Date.new(2014,2,28))
march_pols = Policy.find_covered_in_range(Date.new(2014, 3, 1), Date.new(2014,3,31))
apr_pols = Policy.find_covered_in_range(Date.new(2014, 4, 1), Date.new(2014,4,30))


puts "Policies: #{pol_total}"

mem_ids = []

active_pols.each do |pol|
  pol.enrollees.each do |en|
    mem_ids << en.m_id
  end
end
mem_ids.uniq!

puts "Members: #{mem_ids.length}"

pol_moneys = BigDecimal.new("0.00")

[jan_pols, feb_pols, march_pols, apr_pols].each do |pols|
  pols.each do |pol|
    pol_moneys = pol_moneys + BigDecimal.new(pol.pre_amt_tot)
  end
end

puts "Value: $#{pol_moneys}"
