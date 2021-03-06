class Policy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia
  include AASM

  extend Mongorder

  auto_increment :_id

  field :eg_id, as: :enrollment_group_id, type: String
  field :preceding_enrollment_group_id, type: String
#  field :r_id, as: :hbx_responsible_party_id, type: String

  field :allocated_aptc, type: BigDecimal, default: 0.00
  field :elected_aptc, type: BigDecimal, default: 0.00
  field :applied_aptc, type: BigDecimal, default: 0.00
  field :csr_amt, type: BigDecimal

  field :pre_amt_tot, as: :total_premium_amount, type: BigDecimal, default: 0.00
  field :tot_res_amt, as: :total_responsible_amount, type: BigDecimal, default: 0.00
  field :tot_emp_res_amt, as: :employer_contribution, type: BigDecimal, default: 0.00
  field :sep_reason, type: String, default: :open_enrollment
  field :carrier_to_bill, type: Boolean, default: false
  field :aasm_state, type: String

  validates_presence_of :eg_id

  index({:eg_id => 1})
  index({:aasm_state => 1})
  index({:eg_id => 1, :carrier_id => 1, :plan_id => 1})

  embeds_many :enrollees
  accepts_nested_attributes_for :enrollees, reject_if: :all_blank, allow_destroy: true
  index({ "enrollees.hbx_member_id" => 1 })
  index({ "enrollees.carrier_member_id" => 1})
  index({ "enrollees.carrier_policy_id" => 1})
  index({ "enrollees.rel_code" => 1})
  index({ "enrollees.coverage_start" => 1})
  index({ "enrollees.coverage_end" => 1})

  belongs_to :carrier, counter_cache: true, index: true 
  belongs_to :broker, counter_cache: true, index: true # Assumes that broker change triggers new enrollment group
  belongs_to :plan, counter_cache: true, index: true
  belongs_to :employer, counter_cache: true, index: true
  belongs_to :responsible_party

  has_many :transaction_set_enrollments, 
              class_name: "Protocols::X12::TransactionSetEnrollment", 
              order: { submitted_at: :desc }
  has_many :premium_payments, order: { paid_at: 1 }

  before_create :generate_enrollment_group_id 
  before_save :invalidate_find_cache
  before_save :check_for_cancel_or_term

  scope :all_active_states,   where(:aasm_state.in => %w[submitted resubmitted effectuated])
  scope :all_inactive_states, where(:aasm_state.in => %w[canceled carrier_canceled terminated])

  aasm do
    state :submitted, initial: true
    state :resubmitted
    state :effectuated
    state :carrier_rejected
    state :carrier_canceled
    state :carrier_terminated
    state :hbx_invalid
    state :hbx_rejected
    state :hbx_canceled
    state :hbx_terminated

    event :effectuate do
      transitions from: :submitted, to: :effectuated
      transitions from: :resubmitted, to: :effectuated
    end

    # Use when Carriers cancel for non-payment and initial enrollment is resent
    event :resubmit do
      transitions from: :carrier_canceled, to: :resubmitted
      transitions from: :canceled, to: :resubmitted
    end

    # Use when Carrier naks a transmission or reports a functional error
    event :carrier_reject do
      transitions from: :submitted, to: :carrier_rejected
    end

    event :carrier_cancel do
      transitions from: :submitted, to: :carrier_canceled
    end

    event :cancel do
      transitions from: :submitted, to: :canceled
      transitions from: :effectuated, to: :canceled
      transitions from: :carrier_rejected, to: :canceled
    end

    event :terminate do
      transitions from: :submitted, to: :terminated
      transitions from: :effectuated, to: :terminated
    end
  end

  def subscriber
    enrollees.detect { |m| m.relationship_status_code == "self" }
  end

  def has_responsible_person?
    !self.responsible_party_id.blank?
  end

  def responsible_person
    query_proxy.responsible_person
  end

  def people
    query_proxy.people
  end

  def merge_enrollee(m_enrollee, p_action)
    found_enrollee = self.enrollees.detect do |enr|
      enr.m_id == m_enrollee.m_id
    end
    if found_enrollee.nil?
      if p_action == :stop
        m_enrollee.coverage_status = 'inactive'
      end
      self.enrollees << m_enrollee
    else
      found_enrollee.merge_enrollee(m_enrollee, p_action)
    end
  end


  def edi_transaction_sets
    Protocols::X12::TransactionSetEnrollment.where({"policy_id" => self._id})
  end

  def invalidate_find_cache
    Rails.cache.delete("Policy/find/subkeys.#{enrollment_group_id}.#{carrier_id}.#{plan_id}")
    if !subscriber.nil?
      Rails.cache.delete("Policy/find/sub_plan.#{subscriber.m_id}.#{plan_id}")
    end
    true
  end

  def hios_plan_id
    self.plan.hios_plan_id
  end

  def coverage_type
    self.plan.coverage_type
  end

  def enrollee_for_member_id(m_id)
    self.enrollees.detect { |en| en.m_id == m_id }
  end

  def to_cv
    CanonicalVocabulary::EnrollmentSerializer.new(self).serialize
  end

  def self.default_search_order
    [[:eg_id, 1]]
  end

  def self.find_all_policies_for_member_id(m_id)
    self.where(
      "enrollees.m_id" => m_id
    ).order_by([:eg_id])
  end

  def self.search_hash(s_rex)
    {
      "$or" => [
        {"eg_id" => s_rex}
      ]
    }
  end

  def self.find_by_sub_and_plan(sub_id, h_id)
    Rails.cache.fetch("Policy/find/sub_plan.#{sub_id}.#{h_id}") do
      found_policies = Policy.where(
        {
          :plan_id => h_id,
          :enrollees => {
            "$elemMatch" => {
              :rel_code => "self",
              :m_id => sub_id
            }
          }
        })

      if found_policies.count > 1
        (found_policies.reject { |pol| pol.aasm_state == "canceled" }).first
      else
        found_policies.first
      end
    end
  end

  def self.find_by_subkeys(eg_id, c_id, h_id)
    Rails.cache.fetch("Policy/find/subkeys.#{eg_id}.#{c_id}.#{h_id}") do
      Policy.where(
        {
          :eg_id => eg_id,
          :carrier_id => c_id,
          :plan_id => h_id
        }).first
    end
  end

  def self.find_or_update_policy(m_enrollment)
    found_enrollment = self.find_by_subkeys(
      m_enrollment.enrollment_group_id,
      m_enrollment.carrier_id,
      m_enrollment.plan_id
    )
    if found_enrollment
      found_enrollment.responsible_party_id = m_enrollment.responsible_party_id
      found_enrollment.employer_id = m_enrollment.employer_id
      found_enrollment.broker_id = m_enrollment.broker_id
      found_enrollment.applied_aptc = m_enrollment.applied_aptc
      found_enrollment.tot_res_amt = m_enrollment.tot_res_amt
      found_enrollment.pre_amt_tot = m_enrollment.pre_amt_tot
      found_enrollment.employer_contribution = m_enrollment.employer_contribution
      found_enrollment.carrier_to_bill = (found_enrollment.carrier_to_bill || m_enrollment.carrier_to_bill)
      found_enrollment.save!
      return found_enrollment
    end
    m_enrollment.unsafe_save!
    m_enrollment
  end



  def check_for_cancel_or_term
    if !self.subscriber.nil?
      if self.subscriber.canceled?
        self.aasm_state = "canceled"
      elsif self.subscriber.terminated?
        self.aasm_state = "terminated"
      end
    end
    true
  end

  def unsafe_save!
    Policy.skip_callback(:save, :before, :revise)
    save(validate: false)
    Policy.set_callback(:save, :before, :revise)
  end

  def self.find_covered_in_range(start_d, end_d)
    Policy.where(
      :aasm_state => { "$ne" => "canceled"},
      :enrollees => {"$elemMatch" => {
          :rel_code => "self",
          :coverage_start => {"$lte" => end_d},
          "$or" => [
            {:coverage_end => {"$gt" => start_d}},
            {:coverage_end => {"$exists" => false}},
            {:coverage_end => nil}
          ]
        }
      }
    )
  end

  def self.find_active_and_unterminated_for_members_in_range(m_ids, start_d, end_d, other_params = {})
    Policy.where(self.active_as_of_expression(end_d).merge(
      {"enrollees" => {
        "$elemMatch" => {
          "m_id" => { "$in" => m_ids },
          "coverage_start" => { "$lt" => end_d },
          "$or" => [
            {:coverage_end => {"$gt" => end_d}},
            {:coverage_end => {"$exists" => false}},
            {:coverage_end => nil}
          ]
        }
      } }
    ).merge(other_params))
  end

  def self.find_active_and_unterminated_in_range(start_d, end_d, other_params = {})
    Policy.where(
      self.active_as_of_expression(end_d).merge(other_params)
    )
  end

  def self.find_terminated_in_range(start_d, end_d, other_params = {})
    Policy.where({
      :aasm_state => { "$ne" => "canceled" },
      :enrollees => { "$elemMatch" => {
          :rel_code => "self",
          :coverage_start => { "$ne" => nil },
          :coverage_end => {"$lte" => end_d, "$gte" => start_d}
      }
      }
    }.merge(other_params)
    )
  end

  def self.process_audits(active_start, active_end, term_start, term_end, other_params, out_directory)
    ProcessAudits.execute(active_start, active_end, term_start, term_end, other_params, out_directory)
  end

  def can_edit_address?
    return(true) if members.length < 2
    members.map(&:person).combination(2).all? do |addr_set|
      addr_set.first.addresses_match?(addr_set.last)
    end
  end

  def coverage_start_for(member_id)
    member = enrollees.detect { |en| en.m_id == member_id }
    member ? member.coverage_start : nil
  end

  def self.active_as_of_expression(target_date)
    { 
      "$or" => [
        { :aasm_state => { "$ne" => "canceled"},
          :eg_id => { "$not" => /DC0.{32}/ },
          :enrollees => {"$elemMatch" => {
          :rel_code => "self",
          :coverage_start => {"$lte" => target_date},
          :coverage_end => {"$gt" => target_date}
        }}},
        { :aasm_state => { "$ne" => "canceled"},
          :eg_id => { "$not" => /DC0.{32}/ },
          :enrollees => {"$elemMatch" => {
          :rel_code => "self",
          :coverage_start => {"$lte" => target_date},
          :coverage_end => {"$exists" => false}
        }}},
        { :aasm_state => { "$ne" => "canceled"},
          :eg_id => { "$not" => /DC0.{32}/ },
          :enrollees => {"$elemMatch" => {
          :rel_code => "self",
          :coverage_start => {"$lte" => target_date},
          :coverage_end => nil
        }}}
      ]
    }
  end

protected
  def generate_enrollment_group_id
    self.eg_id = self.eg_id || self._id.to_s 
  end

private
    def format_money(val)
      sprintf("%.02f", val)
    end

    def filter_delimiters(str)
      str.to_s.gsub(',','') if str.present?
    end

    def filter_non_numbers(str)
      str.to_s.gsub(/\D/,'') if str.present?
    end

    def query_proxy
      @query_proxy ||= Queries::PolicyAssociations.new(self)
    end

end
