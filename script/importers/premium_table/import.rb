require 'roo'
require 'spreadsheet'

dates_by_sheet = [
  Date.new(2014, 1, 1)..Date.new(2014, 12, 31),
  Date.new(2014, 1, 1)..Date.new(2014, 3, 31),
  Date.new(2014, 4, 1)..Date.new(2014, 6, 30)
]

spreadsheet = Roo::Spreadsheet.open('./script/importers/premium_table/file.xlsx')

(0...3).each do |sheet_index|
  current_sheet = spreadsheet.sheet(sheet_index)

  header = current_sheet.row(1)
  (2..spreadsheet.last_row).each do |i|
    plan_details = Hash[[header, current_sheet.row(i)].transpose]
    premiums_to_add = []
    
    (0..20).each do |age|
      cost = plan_details['0-20']
      premium = PremiumTable.new
      premium.rate_start_date = dates_by_sheet[sheet_index].first
      premium.rate_end_date = dates_by_sheet[sheet_index].last
      premium.age = age
      premium.amount = cost

      premiums_to_add << premium
    end

    (21..63).each do |age|
      cost = plan_details[age.to_f]
      premium = PremiumTable.new
      premium.rate_start_date = dates_by_sheet[sheet_index].first
      premium.rate_end_date = dates_by_sheet[sheet_index].last
      premium.age = age
      premium.amount = cost

      premiums_to_add << premium
    end

    (64..120).each do |age|
      cost = plan_details["64 +"]
      premium = PremiumTable.new
      premium.rate_start_date = dates_by_sheet[sheet_index].first
      premium.rate_end_date = dates_by_sheet[sheet_index].last
      premium.age = age
      premium.amount = cost

      premiums_to_add << premium
    end

    hios_id = plan_details['Standard Component ID']
    plans = Plan.where({:hios_plan_id => /#{hios_id}/})
    plans.to_a.each do |plan|
      premiums_to_add.each do |premium|
        plan.premium_tables << premium
      end
      plan.save!
    end
  end
end

