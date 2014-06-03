require 'open-uri'
require 'nokogiri'

class EmployerFactory
  def create_many_from_xml(xml)
    employers = []
    doc = Nokogiri::XML(xml)
    doc.css('employers employer').each do |emp|
      employers << create_employer(ExposesEmployerXml.new(emp))
    end

    employers
  end

  private 

  def create_employer(employer_data)
    employer = Employer.new(
      :name => employer_data.name,
      :fein => employer_data.fein,
      :hbx_id => employer_data.employer_exchange_id, # same as exchange_id
      :sic_code => employer_data.sic_code,
      :fte_count => employer_data.fte_count,
      :pte_count => employer_data.pte_count,
      :open_enrollment_start => employer_data.open_enrollment_start,
      :open_enrollment_end => employer_data.open_enrollment_end,
      :plan_year_start => employer_data.plan_year_start, #todo dates importing correctly?
      :plan_year_end => employer_data.plan_year_end, #todo dates importing correctly?
      :contact_name_pfx => employer_data.contact.prefix,
      :contact_name_first => employer_data.contact.first_name,
      :contact_name_middle_initial => employer_data.contact.middle_initial,
      :contact_name_last => employer_data.contact.last_name,
      :contact_name_sfx => employer_data.contact.suffix,
      #exchange_status?
      #exchange_version?
      :notes => employer_data.notes
    )

    if !employer_data.contact.street1.blank?
      employer.addresses << create_address(employer_data.contact)
    end
    
    if !employer_data.contact.phone_number.blank?
      employer.phones << create_phone(employer_data.contact)
    end

    employer_data.plans.each do |plan_data|
      employer.elected_plans << create_elected_plan(plan_data)
    end

    employer.broker = Broker.find_by_npn(employer_data.broker_npn_id)

    employer.carrier_ids = uniq_carrier_ids(employer.elected_plans)

    employer
  end

  def uniq_carrier_ids(elected_plans)
    array = elected_plans.uniq do |p|
      p.carrier_id
    end

    array.map { |p| p.carrier_id }
  end

  def create_address(contact_data)
    Address.new(
      :address_type => 'work',
      :address_1 => contact_data.street1,
      :address_2 => contact_data.street2,
      :city => contact_data.city,
      :state => contact_data.state,
      :zip => contact_data.zip
      )
  end

  def create_phone(contact_data)
    Phone.new(
    :phone_type => 'work',
    :phone_number => contact_data.phone_number.gsub(/[^0-9]/,""),
    :phone_extension => ''
    )
  end

  def create_elected_plan(plan_data)
    plan = Plan.find_by_hios_id(plan_data.qhp_id)
    raise self.hios_id.inspect if plan.nil?

    ElectedPlan.new(
      :carrier => plan.carrier, #or plan_data.carrier_id
      :qhp_id => plan_data.qhp_id,
      :coverage_type => plan_data.coverage_type,
      :metal_level => plan.metal_level,
      :hbx_plan_id => plan.hbx_plan_id,
      :original_effective_date => plan_data.original_effective_date,
      :plan_name => plan_data.name,
      :carrier_policy_number => plan_data.policy_number,
      :carrier_employer_group_id => plan_data.group_id
      )
  end
end