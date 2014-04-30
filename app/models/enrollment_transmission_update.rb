class EnrollmentTransmissionUpdate
  attr_accessor :path, :transmission_kind, :data

  def attribute_keys
    [:path, :transmission_kind, :data].map(&:to_s)
  end

  def initialize(opts = {})
    opts.stringify_keys!
    allowed_keys = attr_keys
    opts.each_pair do |k, v|
      if (allowed_keys.include?(k))
        self.send("#{k}=".to_sym, v)
      end
    end
  end

  def save
    tf = Parsers::Edi::TransmissionFile.new(self.path, self.transmission_kind, self.data)
    tf.persist!
  end
end
