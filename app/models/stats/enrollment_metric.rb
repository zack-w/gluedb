class Stats::EnrollmentMetric

  attr_reader :total, :nacked, :acked, :outstanding

  def initialize
    @total = EdiTransactionSet.where("transaction_kind" => {"$ne" => "effectuation"}).count
    @nacked = EdiTransactionSet.where("transaction_kind" => {"$ne" => "effectuation"}, "aasm_state" => "rejected").count
    @acked = EdiTransactionSet.where("transaction_kind" => {"$ne" => "effectuation"}, "aasm_state" => "acknowledged").count
    @outstanding = EdiTransactionSet.where("transaction_kind" => {"$ne" => "effectuation"}, "aasm_state" => "transmitted").count
  end

  def self.all
    ResponseMetric.new
  end

end
