class Household
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia


  field :rel, as: :relationship, type: String
  field :aptc_total, as: :aptc_total_in_cents, type: Integer
  field :csr_total, as: :csr_total_in_cents, type: Integer

  validates_presence_of :rel
	validates_inclusion_of :rel, in: ["self", "spouse", "dependent"]

  has_many :people, dependent: :delete

end