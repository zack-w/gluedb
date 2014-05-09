require 'builder'
require 'timeout'

module Protocols
  module Amqp
    class PersonUpdateHandler
      include Timeout

      def handle_update(obj, delta)
        xml = ::Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!(:xml, :encoding => "UTF-8")
        message_ns = "urn:gluedb:v0.1.0:person:update"
        xml.person_changes({"xmlns" => message_ns}) do |xml|
          obj.to_xml(:builder => xml, :dasherize => false, :root => "person", :skip_instruct => "true")
          delta.to_xml(:builder => xml, :dasherize => false, :root => "changes", :skip_instruct => "true")
        end
        transform_exchange = Protocols::Amqp::Settings.transformation_exchange
        transform_key = Protocols::Amqp::Settings.transformation_key
        conn = Bunny.new
        conn.start
        ch = conn.create_channel
        ex = ch.send(*transform_exchange)
        reply_queue = ch.queue
        # TODO: send to the right place, with the transformation XSL
        ex.publish( xml.target!,
                    :durable => true,
                    :routing_key => transform_key,
                    :reply_to => reply_queue.name,
                    :headers => {
                      :transform => message_ns
                    }
                  )
        reply_properties = nil
        reply_result = nil
        timeout(5) {
          consumer = Bunny::Consumer.new(ch, reply_queue)
          consumer.on_delivery do |delivery_info, properties, payload|
            reply_properties = properties
            reply_result = payload
            consumer.cancel
            throw :terminate, "cancelled because of response"
          end
          reply_queue.subscribe_with(consumer, :block => true)
        }
        if !(reply_properties.headers["result_code"] == "OK")
          reply_queue.delete
          raise reply_properties.headers["result_code"].inspect
        end
        event_exchange = Protocols::Amqp::Settings.event_exchange("individual")
        event_key = Protocols::Amqp::Settings.event_key("individual", "update")
        e_ex = ch.send(*event_exchange)
        e_ex.publish(reply_result, :durable => true, :routing_key => event_key)
        reply_queue.delete
        conn.close 
      end
    end
  end
end
