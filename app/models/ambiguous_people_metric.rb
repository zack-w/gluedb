class AmbiguousPeopleMetric

  attr_reader :categories

  AmbiguousStatistic = Struct.new(:name, :total, :unresolved)

  def initialize
    @categories = []
    construct_people_statistics
    construct_address_statistics
    construct_phone_statistics
    construct_email_statistics
  end

  def construct_people_statistics
    mm_total = Person.where(
      {"members.1" => {"$exists" => true}}
    ).count
    mm_u = Person.where(
      {
        "members.1" => {"$exists" => true},
        "$or" => [
          {"authority_member_id" => {"$exists" => false}},
          {"authority_member_id" => nil}
        ]
      }
    ).count
    @categories << AmbiguousStatistic.new("Members", mm_total, mm_u)
  end

  def construct_address_statistics
    ma_total = Person.where(
      {"addresses.1" => {"$exists" => true}}
    ).count
    @categories << AmbiguousStatistic.new("Addresses", ma_total, ma_total)
  end

  def construct_phone_statistics
    ma_total = Person.where(
      {"phones.1" => {"$exists" => true}}
    ).count
    @categories << AmbiguousStatistic.new("Phones", ma_total, ma_total)
  end

  def construct_email_statistics
    ma_total = Person.where(
      {"emails.1" => {"$exists" => true}}
    ).count
    @categories << AmbiguousStatistic.new("Emails", ma_total, ma_total)
  end

  def self.all
    self.new
  end
end
