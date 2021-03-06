require 'spec_helper'

feature 'uploading individual CV' do
  background do
    user = create :user
    visit root_path
    sign_in_with(user.email, user.password)

    # Note: The file fixture is dependent on this record.
    plan = Plan.new(coverage_type: 'health', hios_plan_id: '11111111111111-11')
    premium = PremiumTable.new(
      rate_start_date: Date.new(2014, 1, 1), 
      rate_end_date: Date.new(2014, 12, 31),
      age: 53,
      amount: 398.24)
    plan.premium_tables << premium
    plan.save!
  end

  scenario 'a successful upload' do
    visit new_vocab_upload_path

    choose 'Initial Enrollment'

    file_path = Rails.root + "spec/support/fixtures/individual_enrollment/correct.xml"
    attach_file('vocab_upload_vocab', file_path)
    
    click_button "Upload"

    expect(page).to have_content 'Upload successful.'
  end

  scenario 'no file is selected' do
    visit new_vocab_upload_path

    choose 'Initial Enrollment'

    click_button "Upload"

    expect(page).to have_content 'Upload failed.'
  end

  scenario 'kind is not selected' do
    visit new_vocab_upload_path

    file_path = Rails.root + "spec/support/fixtures/individual_enrollment/correct.xml"
    attach_file('vocab_upload_vocab', file_path)

    click_button "Upload"

    expect(page).to have_content 'Upload failed.'
  end

  scenario 'enrollee\'s premium is incorrect' do
    visit new_vocab_upload_path

    choose 'Initial Enrollment'

    file_path = Rails.root + "spec/support/fixtures/individual_enrollment/incorrect_premium.xml"
    attach_file('vocab_upload_vocab', file_path)
    
    click_button "Upload"

    expect(page).to have_content 'premium_amount is incorrect'
    expect(page).to have_content 'Upload failed.'

  end

  scenario 'premium amount total is incorrect' do
    visit new_vocab_upload_path

    choose 'Initial Enrollment'

    file_path = Rails.root + "spec/support/fixtures/individual_enrollment/incorrect_total.xml"
    attach_file('vocab_upload_vocab', file_path)
    
    click_button "Upload"

    expect(page).to have_content 'premium_amount_total is incorrect'
    expect(page).to have_content 'Upload failed.'
  end

  scenario 'responsible amount is incorrect' do
    visit new_vocab_upload_path

    choose 'Initial Enrollment'

    file_path = Rails.root + "spec/support/fixtures/individual_enrollment/incorrect_responsible.xml"
    attach_file('vocab_upload_vocab', file_path)
    
    click_button "Upload"

    expect(page).to have_content 'total_responsible_amount is incorrect'
    expect(page).to have_content 'Upload failed.'
  end

  scenario 'sixth not free' do
    visit new_vocab_upload_path

    choose 'Initial Enrollment'

    file_path = Rails.root + "spec/support/fixtures/individual_enrollment/sixth_not_free.xml"
    attach_file('vocab_upload_vocab', file_path)
    
    click_button "Upload"

    expect(page).to have_content 'premium_amount is incorrect'
    expect(page).to have_content 'Upload failed.'
  end
end