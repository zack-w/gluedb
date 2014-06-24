require 'open-uri'
require 'nokogiri'

class ValidatePremiums
  def initialize(group, plan, listener)
    @group = group
    @plan = plan
    @listener = listener
  end

  def run
    expected_premiums = []

    # check member premium amounts
    enrollees = @group.enrollees
    enrollees.each do |enrollee|
      expected_amount = expected_premium_for(enrollee)
      if(enrollee.premium_amount != expected_amount)
        name = enrollee.first_name + ' ' + enrollee.last_name
        @listener.corrected_member_premium(who: name, from: enrollee.premium_amount, to: expected_amount)
        enrollee.premium_amount = expected_amount

        # return false
      end
      expected_premiums << expected_amount
    end

    #check total amount
    expected_total = total(expected_premiums)
    if(@group.premium_amount_total != expected_total)
      @listener.corrected_premium_total(from: @group.premium_amount_total, to: expected_total)
      @group.premium_amount_total = expected_total

      # return false
    end

    #check responsible total amount
    expected_responsible = adjusted_total(expected_premiums, @group.credit)
    if (@group.total_responsible_amount != expected_responsible)
      @listener.corrected_member_responsible_amount(from: @group.total_responsible_amount, to: expected_responsible)
      @group.total_responsible_amount = expected_responsible

      # return false
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