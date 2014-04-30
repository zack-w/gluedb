class Exchange
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia


  field :name, type: String
  field :fein, type: Integer
  field :cms_id, type: String

  has_many :rating_areas
end
