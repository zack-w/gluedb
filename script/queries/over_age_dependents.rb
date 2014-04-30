over_aged = Person.with_over_age_child_enrollments.map { |per| per.members.map(&:hbx_member_id) }.flatten.uniq

over_aged.each do |m|
  puts m
end
