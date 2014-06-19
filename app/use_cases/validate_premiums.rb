require 'open-uri'
require 'nokogiri'

class ValidatePremiums
  def initialize(group, plan)
    @group = group
    @plan = plan
  end

  def run
    expected_premiums = []

    # check member premium amounts
    enrollees = @group.enrollees
    enrollees.each do |enrollee|
      expected_amount = expected_premium_for(enrollee)
      if(enrollee.premium_amount != expected_amount)
        return false
      end
      expected_premiums << expected_amount
    end

    #check total amount
    if(@group.premium_amount_total != total(expected_premiums))
      return false
    end

    #check responsible total amount
    if (@group.total_responsible_amount != adjusted_total(expected_premiums, @group.credit))
      return false
    end

    true
  end

  def total(premiums)
    sum = premiums.inject(:+)
  end

  def adjusted_total(premiums, credit)
    total(premiums) - credit
  end

  def expected_premium_for(enrollee)
    @plan.rate(enrollee.rate_period_date, enrollee.benefit_begin_date, enrollee.birth_date).amount.to_f
  end
end