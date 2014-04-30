class HbxOperations::BusinessProcess
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :name, type: String
  field :kind, type: String
  field :sla, as: :service_level_agreement_in_days, type: Integer

  embedded_in :business_process

  validates_presence_of :name, :kind
  validates_inclusion_of :name, in: ["00", "15", "22"]

  embeds_many :process_tasks, :class_name => 'HbxOperations::Tasks::ProcessTasks'


end
