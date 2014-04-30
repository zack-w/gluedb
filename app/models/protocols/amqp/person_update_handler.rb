require 'builder'

module Protocols
  module Amqp
    class PersonUpdateHandler
      def handle_update(obj, delta)
        xml = ::Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!(:xml, :encoding => "UTF-8")
        xml.person_changes({"xmlns" => "uri:gluedb:v0.1.0:person"}) do |xml|
          obj.to_xml(:builder => xml, :dasherize => false, :root => "person", :skip_instruct => "true")
          delta.to_xml(:builder => xml, :dasherize => false, :root => "changes", :skip_instruct => "true")
        end
#        ex_type, ex_name = Protocols::Amqp::Settings.gluedb_onramp_exchange
#        key = Protocols::Amqp::Settings.onramp_routing_key("individual", "update")
        transform_xsl = ""
        raise xml.target!
        event_exchange = Protocols::Amqp::Settings.event_exchange
        event_routing_key = Protocols::Amqp::Settings.event_key("individual", "update")
        conn = Bunny.new
        conn.start
        ch = conn.create_channel
        ex = ch.send(*event_exchange)
        # TODO: send to the right place, with the transformation XSL
        ex.publish( xml.target!,
                    :routing_key => key,
                    :reply_to => event_routing_key,
                    :headers => {
                      :transform => transform_xsl
                    }
                  )
        conn.close 
      end
    end
  end
end
