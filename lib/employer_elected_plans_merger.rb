module EmployerElectedPlansMerger
  def self.merge(existing, incoming)
    incoming.elected_plans.each do |plan|
      exisiting_plan = existing.elected_plans.detect { |p| p.qhp_id == plan.qhp_id}
      if !exisiting_plan.nil?
        exisiting_plan.merge_without_blanking(plan, 
          :carrier_employer_group_id,
          :carrier_policy_number,
          :coverage_type,
          :qhp_id,
          :hbx_plan_id,
          :plan_name,
          :metal_level,
          :original_effective_date,
          :renewal_effective_date)
      else
        existing.elected_plans << plan
      end
    end
  end
end