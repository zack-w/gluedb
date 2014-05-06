class Phone
  include Mongoid::Document

  include MergingModel

  field :phone_type, type: String
  field :phone_number, type: String
  field :extension, type: String

  validates :phone_type, presence: true, inclusion: {in: %w( primary secondary home work mobile pager main other )}

  embedded_in :person, :inverse_of => :phones
  embedded_in :employer, :inverse_of => :phones

  def match(another_phone)
    return(false) if another_phone.nil?
    attrs_to_match = [:phone_type, :phone_number]
    attrs_to_match.all? { |attr| attribute_matches?(attr, another_phone) }
  end

  def attribute_matches?(attribute, other)
    self[attribute] == other[attribute]
  end

  def phone_number=(value)
    super filter_non_numbers(value)
  end
  
  def extension=(value)
    super filter_non_numbers(value)
  end
  
private
  def filter_non_numbers(str)
    str.gsub(/\D/,'') if str.present?
  end

  def merge_update(m_phone)
    merge_with_overwrite(
      m_phone,
      :phone_number,
      :extension
    )
  end
  
end
