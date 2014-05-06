class Address
  include Mongoid::Document
  include Mongoid::Timestamps

  include MergingModel

  field :address_type, type: String
  field :address_1, type: String
  field :address_2, type: String, default: ""
  field :city, type: String
  field :state, type: String
  field :zip, type: String

  validates_inclusion_of :address_type, in: ["home", "work", "billing"]
  validates_presence_of :address_1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip

  embedded_in :person, :inverse_of => :addresses
  embedded_in :employer, :inverse_of => :addresses

  before_save :clean_fields

  def clean_fields
    attrs_to_clean = [:address_type, :address_1, :address_2, :city, :state, :zip]
    attrs_to_clean.each do |a|
      self[a].strip! unless self[a].blank?
    end
  end

  def safe_downcase(val)
    val.nil? ? nil : val.downcase
  end

  def match(another_address)
    return(false) if another_address.nil?
    (safe_downcase(self.address_type) == safe_downcase(another_address.address_type)) &&
    (safe_downcase(address_1) == safe_downcase(another_address.address_1)) &&
    (safe_downcase(address_2) == safe_downcase(another_address.address_2)) &&
    (safe_downcase(city) == safe_downcase(another_address.city)) &&
    (safe_downcase(state) == safe_downcase(another_address.state)) &&
    (safe_downcase(zip) == safe_downcase(another_address.zip))
  end

  def formatted_address
    city.present? ? city_delim = city + "," : city_delim = city
    line3 = [city_delim, state, zip].reject(&:nil? || empty?).join(' ')
    [address_1, address_2, line3].reject(&:nil? || empty?).join('<br/>').html_safe
  end
  
  def full_address
    city.present? ? city_delim = city + "," : city_delim = city
    [address_1, address_2, city_delim, state, zip].reject(&:nil? || empty?).join(' ')
  end

  def merge_update(m_address)
    merge_with_overwrite(m_address,
      :address_1,
      :address_2,
      :city,
      :state,
      :zip
    )
  end

  def home?
    "home" == self.address_type.downcase
  end

end
