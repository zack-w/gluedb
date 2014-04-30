module Protocols
  module Amqp
    class Settings
      # TODO: Turn this into a value loaded from a settings file
      def self.environment
        "dev"
      end

      def self.exchange
        "DC0"
      end

      def self.event_exchange
        [:topic, "#{exchange}.E.topic.#{environment}"]
      end

      def self.event_key(resource, action)
        "#{exchange}.E.topic.#{environment}.#{resource}.#{action}"
      end
    end
  end
end
