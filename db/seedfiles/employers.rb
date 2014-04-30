puts "Loading Employers"

Employer.collection.drop

glob_pat = File.join(File.dirname(__FILE__), "employer_groups", "*.xml")

Dir.glob(glob_pat).each do |f|
  f_in = File.open(f, 'r')
  Protocols::Dcas::EmployerGroupFile.new(f_in.read).persist!
  f_in.close
end

c_hash = Hash[(Carrier.all.map { |c| [c.abbrev, c]}) ]

gid_file = File.join(File.dirname(__FILE__), "employer_group_ids.csv")

CSV.foreach(gid_file, headers: true) do |row|
  record = row.to_hash
  hbx_id = record['HBX_ID']
  emp = Employer.where(:hbx_id => hbx_id).first
  if emp
    c_hash.each_pair do |k,v|
    if !record["#{k}_01"].blank?
      emp.update_elected_plans(c_hash[k], record["#{k}_01"])
      emp.touch
    end
    end
    emp.save!
  else
    puts "Couldn't find: #{record['FEIN']} - #{record['HBX_ID']} - #{record['NAME']}"
  end
end
