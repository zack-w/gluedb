module Parsers
  module Edi
    class ParserLog
      include Singleton

      def initialize
        @file_path = File.join(Rails.root, "log", "edi_parser.csv")
        @writer = CSV.open(@file_path, "a", {:force_quotes => true})
      end

      def log(file, file_kind, message, payload)
        @writer << [Time.now.utc.to_s, file, file_kind, message, payload]
      end

      def self.log(file, file_kind, message, payload)
        self.instance.log(file, file_kind, message, payload)
      end
    end
  end
end

