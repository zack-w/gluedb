require 'spec_helper'

describe Plan do
  describe '#rate' do
    let(:premium_start) { Date.new(1980,1,1) }
    let(:premium_end) { Date.new(1985,1,1) }
    let(:rate_amount) { 6.66 }
    let(:age) { 0 }

    it 'returns the premium rate given rate period date, benifit begin date, and date of birth' do
      premium_table = PremiumTable.new(rate_start_date: premium_start, rate_end_date: premium_end, age: age, amount: rate_amount)
      plan = Plan.new(coverage_type: 'health', market_type: 'individual')
      plan.premium_tables << premium_table
      plan.premium_tables << PremiumTable.new

      result = plan.rate(Date.new(1983,1,1), Date.new(1980,1,1), Date.new(1980,1,1))
      expect(result.amount).to eq rate_amount
    end
  end
end
