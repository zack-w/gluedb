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

    doc = Nokogiri::XML(file_data)

    enrollment_group = Parsers::Xml::Enrollment::EnrollmentGroupFactory.from_xml(doc)
    plan = Plan.find_by_hios_id(enrollment_group.hios_plan_id)
    
    validations = [ 
      Validators::PremiumValidator.new(enrollment_group, plan, listener),
      Validators::PremiumTotalValidator.new(enrollment_group, listener),
      Validators::PremiumResponsibleValidator.new(enrollment_group, listener)
    ]

    if validations.any? { |v| v.validate == false }
      return false
    end
    
    submit_cv(kind, file_name, file_data)
    true
  end

  def submit_cv(cv_kind, name, data)
    return if Rails.env.test?
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
