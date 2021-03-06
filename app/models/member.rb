class Member
  require 'date'
  include Mongoid::Document
  include Mongoid::Timestamps

  include MergingModel

  GENDER_TYPES = %W(male female unknown)

  # gdb_member_id is the primary key. if hbx_member_id isn't provided, gdb_member_id is used
  auto_increment :_id, seed: 9999
  field :hbx_member_id, type: String
  field :concern_role_id, type: String  # Curam internal ID

  field :import_source, type: String  # e.g. :b2b_gateway
  field :imported_at, type: DateTime

  # Carrier ids are N <-> N with members,
  # we'll store them at the policy level to avoid any issues
  #  field :carrier_id, type: String

  field :dob, type: DateTime
  field :ssn, type: String
  field :gender, type: String

  field :hlh, as: :tobacco_use_code, type: String, default: "Unknown"
  field :lui, as: :language_code, type: String

  validates_presence_of  :gender, message: "Choose a gender"
  validates_inclusion_of :gender, in: GENDER_TYPES, message: "Invalid gender"

  # validates_numericality_of :ssn
  validates_length_of :ssn, allow_blank: true, allow_nil: true, minimum: 9, maximum: 9,
                      message: "SSN must be 9 digits"

#  index({ hbx_member_id: 1 }, { unique: false, name: "member_exchange_id_index" })
#  index({ a_id: 1 }, { unique: false, name: "authority_member_exchange_id_index" })
#	index({ ssn: -1 }, { unique: false, sparse: true, name: "member_ssn_index" })

  embedded_in :person

  before_create :generate_hbx_member_id 

  # Strip non-numeric chars from ssn
  # SSN validation rules, see: http://www.ssa.gov/employer/randomizationfaqs.html#a0=12
  def ssn=(val)
    return if val.blank?
    write_attribute(:ssn, val.to_s.gsub(/[^0-9]/i, ''))
  end

  def gender=(val)
    return if val.blank?
    write_attribute(:gender, val.downcase)
  end

  # def dob=(val)
  #   bday = DateTime.strptime(val, "%m-%d-%Y").to_date
  #   write_attribute(:dob, bday)
  # end

  def policies
    Policy.elem_match(enrollees: { m_id: hbx_member_id })
  end

  def enrollees
    policies.map { |p| p.enrollees.find_by(m_id: hbx_member_id) }
  end

  def policies_with_over_age_children
    return [] if dob > (Date.today - 26.years)
    policies.find_all { |p| p.enrollees.find_by(m_id: hbx_member_id).rel_code == "child" }
  end

  def authority?
    self.hbx_member_id == person.authority_member_id
  end

  def merge_member(m_member)
    merge_without_blanking(
      m_member,
      :concern_role_id,
      :dob,
      :gender,
      :ssn,
      :hlh,
      :lui,
      :import_source,
      :imported_at
    )
  end

  def self.find_for_member_id(member_id)
    Queries::MemberByHbxIdQuery.new(member_id).execute
  end

protected
  def generate_hbx_member_id
    self.hbx_member_id = self.hbx_member_id || self._id.to_s
  end

  def dob_string
    self.dob.blank? ? "" : self.dob.strftime("%Y%m%d")
  end

  def safe_downcase(val)
    val.blank? ? val : val.downcase.strip
  end
end