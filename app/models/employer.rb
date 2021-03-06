class Employer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia
  include MergingModel

  extend Mongorder

  include AASM

  field :name, type: String
  field :hbx_id, as: :hbx_organization_id, type: String
  field :fein, type: String
  field :sic_code, type: String
  field :open_enrollment_start, type: Date
  field :open_enrollment_end, type: Date
  field :plan_year_start, type: Date
  field :plan_year_end, type: Date
  field :aasm_state, type: String
  field :fte_count, type: Integer
  field :pte_count, type: Integer
  field :msp_count, as: :medicare_secondary_payer_count, type: Integer
  field :notes, type: String

  field :name_pfx, type: String, default: ""
  field :name_first, type: String
  field :name_middle, type: String, default: ""
  field :name_last, type: String
  field :name_sfx, type: String, default: ""
  field :name_full, type: String

	index({ hbx_id: 1 })
	index({ fein: 1 })

  has_many :employees, class_name: 'Person', order: {name_last: 1, name_first: 1}
  has_many :premium_payments, order: { paid_at: 1 }
  belongs_to :broker, counter_cache: true, index: true
  has_and_belongs_to_many :carriers, order: { name: 1 }
  has_and_belongs_to_many :plans, order: { name: 1, hios_plan_id: 1 }

  has_many :policies

  embeds_many :elected_plans
  index({"elected_plans.carrier_employer_group_id" => 1})
  index({"elected_plans.hbx_plan_id" => 1})
  index({"elected_plans.qhp_id" => 1})
  accepts_nested_attributes_for :elected_plans, reject_if: :all_blank, allow_destroy: true

  embeds_many :addresses, :inverse_of => :employer
  accepts_nested_attributes_for :addresses, reject_if: :all_blank, allow_destroy: true

  embeds_many :phones, :inverse_of => :employer
  accepts_nested_attributes_for :phones, reject_if: :all_blank, allow_destroy: true

  embeds_many :emails, :inverse_of => :employer
  accepts_nested_attributes_for :emails, reject_if: :all_blank, allow_destroy: true

  validates_length_of :fein, allow_blank: true, allow_nil: true, minimum: 9, maximum: 9

  before_save :initialize_name_full
  before_save :invalidate_find_caches

  def payment_transactions
    PremiumPayment.payment_transactions_for(self)
  end

  def associate_all_carriers_and_plans_and_brokers
    self.policies.each { |pol| self.carriers << pol.carrier; self.brokers << pol.broker; self.plans << pol.plan }
    save!
  end

  aasm do
    state :registered, initial: true
    state :enrollment_open
    state :enrollment_closed
    state :terminated

    event :start_enrollment do
      transitions from: [:registered, :enrollment_closed], to: :enrollment_open
    end

    event :end_enrollment do
      transitions from: :enrollment_open, to: :enrollment_closed
    end
  end

  def fein=(val)
    return if val.blank?
    write_attribute(:fein, val.to_s.gsub(/[^0-9]/i, ''))
  end


  def invalidate_find_caches
    Rails.cache.delete("Employer/find/fein.#{fein}")
    elected_plans.each do |ep|
      Rails.cache.delete("Employer/find/employer_group_ids.#{ep.carrier_id}.#{ep.carrier_employer_group_id}")
    end
    true
  end

  def todays_bill
    e_id = self._id
    value = Policy.collection.aggregate(
      { "$match" => {
        "employer_id" => e_id,
        "enrollment_members" => 
        {
          "$elemMatch" => {"$or" => [{
            "coverage_end" => nil
          },
          {"coverage_end" => { "$gt" => Time.now }}
          ]}

        }
      }},
      {"$group" => {
        "_id" => "$employer_id",
        "total" => { "$addToSet" => "$pre_amt_tot" }
      }}
    ).first["total"].inject(0.00) { |acc, item| 
      acc + BigDecimal.new(item)
    }
    "%.2f" % value
  end

  def self.default_search_order
    [[:name, 1]]
  end

  def self.search_hash(s_rex)
    search_rex = Regexp.compile(Regexp.escape(s_rex), true)
    {
      "$or" => [
        {"name" => search_rex}
      ]
    }
  end

  def self.find_for_fein(e_fein)
    Rails.cache.fetch("Employer/find/fein.#{e_fein}") do
      Employer.where(:fein => e_fein).first
    end
  end

  def self.find_for_carrier_and_group_id(carrier_id, group_id)
    Rails.cache.fetch("Employer/find/employer_group_ids.#{carrier_id}.#{group_id}") do
      Employer.where({ :elected_plans => {
        "$elemMatch" => { 
          "carrier_id" => carrier_id,
          "carrier_employer_group_id" => group_id
        }
      }
      }).first
    end
  end

  def self.create_from_group_file(m_employer)
    found_employer = Employer.find_for_fein(m_employer.fein)
    if found_employer.nil?
      m_employer.save!
    else
      found_employer.merge_without_blanking(m_employer, 
        :name,
        :hbx_id,
        :fein,
        :sic_code,
        :open_enrollment_start,
        :open_enrollment_end,
        :plan_year_start,
        :plan_year_end,
        :aasm_state,
        :fte_count,
        :pte_count,
        :msp_count,
        :notes
        )

      m_employer.addresses.each { |a| found_employer.merge_address(a) }
      m_employer.emails.each { |e| found_employer.merge_email(e) }
      m_employer.phones.each { |p| found_employer.merge_phone(p) }

      EmployerElectedPlansMerger.merge(found_employer, m_employer)

      found_employer.carriers = (found_employer.carriers + m_employer.carriers).uniq
      found_employer.broker = m_employer.broker

      found_employer.save!
    end
  end

  def merge_address(m_address)
    unless (self.addresses.any? { |p| p.match(m_address) })
      self.addresses << m_address
    end
  end

  def merge_email(m_email)
    unless (self.emails.any? { |p| p.match(m_email) })
      self.emails << m_email
    end
  end

  def merge_phone(m_phone)
    unless (self.phones.any? { |p| p.match(m_phone) })
      self.phones << m_phone
    end
  end

  def update_elected_plans(carrier, g_id)
    matching_plans = self.elected_plans.select { |p| p.carrier_id == carrier._id }
    matching_plans.each do |mp|
      mp.carrier_employer_group_id = g_id
    end
  end

  def full_name
    [name_pfx, name_first, name_middle, name_last, name_sfx].reject(&:blank?).join(' ').downcase.gsub(/\b\w/) {|first| first.upcase }
  end

  def initialize_name_full
    self.name_full = full_name
  end

  class << self

    def find_or_create_employer(m_employer)
      found_employer = Employer.where(
        :hbx_id => m_employer.hbx_id
      ).first
      return found_employer unless found_employer.nil?
      m_employer.save!
      m_employer
    end

    def find_or_create_employer_by_fein(m_employer)
      found_employer = Employer.find_for_fein(m_employer.fein)
      return found_employer unless found_employer.nil?
      m_employer.save!
      m_employer
    end
  end
end
