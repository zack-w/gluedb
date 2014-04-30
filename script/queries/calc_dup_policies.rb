pols = Policy.find_active_and_unterminated_in_range(Date.new(2013, 10, 1), Date.new(2014, 2, 28))

p_res = Hash.new { [] }
pols.each do |pol|
  if pol.transaction_set_enrollments.any? { |tse| tse.aasm_state == "acknowledged" }
    pol.enrollees.map do |en|
      if !en.canceled?
        p_res[en.person._id] = p_res[en.person._id] + [en.m_id]
      end
    end
  end
end

res = []
p_res.each_pair do |k, v|
  vals = v.uniq.count
  if vals > 1
    res << k
  end
end

res.uniq.each do |r|
  puts r
end
