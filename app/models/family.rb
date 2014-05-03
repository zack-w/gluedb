class Family
  include Mongoid::Document

  has_many :tax_households
end
