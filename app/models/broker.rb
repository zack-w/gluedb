class Broker
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia

  field :b_type, type: String
  field :name_full, type: String
  field :name_first, type: String
  field :name_last, type: String
  field :npn, type: String

  has_many :policies, order: {name_last: 1, name_first: 1}
  has_many :people
  has_many :employers
  has_and_belongs_to_many :carriers

  embeds_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: :all_blank, allow_destroy: true

  embeds_many :phones
  accepts_nested_attributes_for :phones, reject_if: :all_blank, allow_destroy: true

  embeds_many :emails
  accepts_nested_attributes_for :emails, reject_if: :all_blank, allow_destroy: true

  validates_inclusion_of :b_type, in: ["broker", "tpa"]

  index({:name => 1})

  before_save :generate_name

  def self.find_or_create_broker(m_broker)
    found_broker = Broker.find_by_npn(m_broker.npn)
    return found_broker unless found_broker.nil?
    m_broker.save!
    m_broker
  end

  def self.find_by_npn(number)
    Broker.where({npn: number}).first
  end

private

  def generate_name
    return if self.name_full.blank?
    self.name_first = self.name_full.split.first.capitalize
    self.name_last  = self.name_full.split.last.capitalize
  end

end
