class HbxProcesses::ChangeCarrier
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Paranoia

	include AASM

  field :aasm_state, type: String

  aasm do
		state :termination_transmitted
		state :termination_acked
		state :termination_nacked


    state :transmitted, initial: true
    state :retransmitted
    state :acknowledged
    state :rejected

    event :nack do
      transitions from: :transmitted, to: :rejected
    end

    event :retransmit do
      transitions from: :rejected, to: :retransmitted
    end

    event :ack do
      transitions from: :transmitted, to: :acknowledged
    end
  end


end