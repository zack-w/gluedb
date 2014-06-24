class VocabUpload
  attr_accessor :kind
  attr_accessor :submitted_by
  attr_accessor :vocab

  ALLOWED_ATTRIBUTES = [:kind, :submitted_by, :vocab]

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  validates_inclusion_of :kind, :in => ["maintenance", "initial_enrollment"], :allow_blank => false, :allow_nil => false
  validates_presence_of :submitted_by
  validates_presence_of :vocab
  
  def initialize(options={})
    options.each_pair do |k,v|
      if ALLOWED_ATTRIBUTES.include?(k.to_sym)
        self.send("#{k}=", v)
      end
    end
  end

  def save(listener)
    return(false) unless self.valid?
    file_data = vocab.read
    file_name = vocab.original_filename
  
    # To activate Premium validation
    # 1) Remove below
    
    submit_cv(kind, file_name, file_data)
    return true

    # 2) Insert
    # enrollment_group = Parsers::Xml::Enrollment::EnrollmentGroupFactory.from_xml(file_data)
    # plan = Plan.find_by_hios_id(enrollment_group.hios_plan_id)
    
    # validate = ValidatePremiums.new(enrollment_group, plan, listener)
    # if(validate.run)
      # submit_cv(kind, file_name, file_data)
    #   return true
    # else
    #   return false
    # end
  end

  def submit_cv(cv_kind, name, data)
    tag = (cv_kind.to_s.downcase == "maintenance") ? "hbx.maintenance_messages" : "hbx.enrollment_messages"
    conn = Bunny.new
    conn.start
    ch = conn.create_channel
    x = ch.default_exchange

    x.publish(
      data,
      :routing_key => "hbx.vocab_validator",
      :reply_to => tag,
      :headers => {
        :file_name => name,
        :submitted_by => submitted_by
      }
    )
    conn.close
  end

  def persisted?
    false
  end
end
