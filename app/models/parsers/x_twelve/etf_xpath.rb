module Parsers
  module XTwelve
    module EtfXpath

      def xpath(n, expr)
        n.xpath(expr, :etf => "urn:x12:schemas:005:010:834A1A1:BenefitEnrollmentAndMaintenance")
      end

      def value_if_node(n, expr)
        found_node = xpath(n, expr)
        found_node.any? ? found_node.first.text.strip : nil
      end
    end
  end
end
