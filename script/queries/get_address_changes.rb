m_numbers = Person.where({"updated_at" => {"$gt" => DateTime.new(2014,3,28,16,00,00).utc}}).map(&:members).flatten.map(&:hbx_member_id).uniq
pols = Policy.find_active_and_unterminated_for_members_in_range(m_numbers, Date.today, Date.today)

pols.each do |pol|
  member_ids = pol.enrollees.select(&:active?).map(&:m_id)
  f_out = File.open(File.join("address_updates", "#{pol._id}_address.xml"), 'w')
  f_out.puts CanonicalVocabulary::MaintenanceSerializer.new(pol, "change", "change_of_location", member_ids).serialize
  f_out.close
end
