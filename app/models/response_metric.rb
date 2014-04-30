class ResponseMetric

  attr_reader :total, :nacked, :acked, :outstanding

  def initialize
    @total = Protocols::X12::TransactionSetHeader.where("transaction_kind" => {"$ne" => "effectuation"}).count
    @nacked = Protocols::X12::TransactionSetHeader.where("transaction_kind" => {"$ne" => "effectuation"}, "aasm_state" => "rejected").count
    @acked = Protocols::X12::TransactionSetHeader.where("transaction_kind" => {"$ne" => "effectuation"}, "aasm_state" => "acknowledged").count
    @outstanding = Protocols::X12::TransactionSetHeader.where("transaction_kind" => {"$ne" => "effectuation"}, "aasm_state" => "transmitted").count
  end

  def self.all
    ResponseMetric.new
  end

end
