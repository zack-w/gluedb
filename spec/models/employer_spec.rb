require 'spec_helper'

describe Employer do
  [
    :name,
    :fein,
    :hbx_id,
    :sic_code,
    :fte_count,
    :pte_count,
    :open_enrollment_start,
    :open_enrollment_end,
    :plan_year_start,
    :plan_year_end,
    :contact_name_pfx,
    :contact_name_first,
    :contact_name_middle,
    :contact_name_last,
    :contact_name_sfx,
    :notes
  ].each do |attribute|
    it { should respond_to attribute }
  end
end
