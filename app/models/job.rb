class Job
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :employer_id, type: String
  field :m_id, as: :hbx_member_id, type: String
  field :emp_stat, as: :employment_status_code, type: String
  field :e_start, as: :eligibility_start_date, type: Date
  field :e_end, as: :eligibility_end_date, type: Date

  embedded_in :person

  belongs_to :employer

  validates_inclusion_of :employment_status_code, in: ["active", "full-time", "part-time", "retired", "terminated"]


  def merge_data(other_job)
    if !other_job.emp_stat.blank?
      self.emp_stat = other_job.emp_stat
    end
    if !other_job.e_start.blank?
      self.e_start = other_job.e_start
    end
    if !other_job.e_end.blank?
      self.e_end = other_job.e_end
    end
  end

  def delete
    deleted_at = Time.now
  end

  def deleted_at
    deleted_at
  end

end
