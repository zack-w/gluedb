class PersonRelationship
  include Mongoid::Document
  include Mongoid::Timestamps

  MALE_RELATIONSHIPS_LIST   = %W[spouse father grandfather grandson uncle nephew cousin adopted\ child
                              foster\ child son-in-law brother-in-law father-in-law brother ward 
                              stepparent stepson child sponsored\ dependent dependent\ of\ a\ minor\ dependent 
                              ex-spouse guardian court\ appointed\ guardian collateral\ dependent life\ partner]

  FEMALE_RELATIONSHIPS_LIST = %W[spouse mother grandmother granddaughter aunt niece cousin adopted\ child 
                              foster\ child daughter-in-law sister-in-law mother-in-law sister ward 
                              stepparent stepdaughter child sponsored\ dependent dependent\ of\ a\ minor\ dependent
                              ex-spouse guardian court\ appointed\ guardian collateral\ dependent life\ partner]

  ALL_RELATIONSHIPS_LIST    = MALE_RELATIONSHIPS_LIST & FEMALE_RELATIONSHIPS_LIST

  field :subject_person, type: Moped::BSON::ObjectId
  field :relationship_kind, type: String
  field :primary_person, type: Moped::BSON::ObjectId

	validates_presence_of :subject_person, :relationship_kind, :primary_person
	validates_inclusion_of :relationship_kind, in: ALL_RELATIONSHIPS_LIST

  embedded_in :household


end
