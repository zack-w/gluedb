module EmployerElectedPlansMerger
  def self.merge(existing, incoming)
    existing_hash = existing.elected_plans.inject({}) do |acc, val|
      acc[val.qhp_id] = val
      acc
    end
    plans_to_add = []
    incoming.elected_plans.each do |plan|
      exisiting_plan = existing_hash[plan.qhp_id]
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
        plans_to_add << plan
      end
    end
    existing.elected_plans.concat(plans_to_add)
  end
end
