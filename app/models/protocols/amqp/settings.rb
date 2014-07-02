module Protocols
  module Amqp
    class Settings
      # TODO: Turn this into a value loaded from a settings file
      def self.environment
        "dev"
      end

      def self.exchange
        "dc0"
      end

      def self.event_exchange(resource)
        [:topic, "#{exchange}.#{environment}.e.topic.#{resource}"]
      end

      def self.event_key(resource, event)
        "#{resource}.#{event}"
      end

      def self.transformation_exchange
        [:direct, "#{exchange}.#{environment}.e.direct.xml"]
      end

      def self.transformation_key
        "xml.transform"
      end
    end
  end
end
