require 'spec_helper'

describe EmployerElectedPlansMerger do
  let(:qhp_id) { '666' }
  let(:existing_plan) { ElectedPlan.new(plan_name: 'existing', qhp_id: qhp_id) }
  let(:existing_employer) { Employer.new }

  let(:incoming_plan) { ElectedPlan.new(plan_name: 'incoming', qhp_id: qhp_id) }
  let(:incoming_employer) { Employer.new }

  it 'adds the plan when employer doesnt have it yet' do
    existing_employer.elected_plans = []
    incoming_employer.elected_plans = [ incoming_plan ]

    EmployerElectedPlansMerger.merge(existing_employer, incoming_employer)

    expect(existing_employer.elected_plans).to include incoming_plan 
  end

  context 'when employer already has elected plan' do
    it 'overwrites plan attributes' do
      existing_employer.elected_plans = [ existing_plan ]
      incoming_employer.elected_plans = [ incoming_plan ]

      EmployerElectedPlansMerger.merge(existing_employer, incoming_employer)

      expect(existing_employer.elected_plans.first.plan_name).to eq incoming_plan.plan_name
    end

    context 'when incoming attribute is blank' do
      it 'doesnt overwrite the existing attribute' do
        existing_employer.elected_plans = [existing_plan]

        incoming_plan.plan_name = ''
        incoming_employer.elected_plans = [ incoming_plan ]

        EmployerElectedPlansMerger.merge(existing_employer, incoming_employer)

        expect(existing_employer.elected_plans.first.plan_name).not_to eq incoming_plan.plan_name
      end
    end
  end

end