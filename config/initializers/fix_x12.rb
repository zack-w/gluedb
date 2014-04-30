require 'x12'

module X12
  class Parser
    def initialize(file_name)
      save_definition = @x12_definition

      # Deal with Microsoft devices
      # get the current working directory
      base_name = File.basename(file_name, '.xml')
      if MS_DEVICES.find{|i| i == base_name}
        file_name = File.join(File.dirname, "#{base_name}_.xml")
      end
      file_location = File.join(Rails.root, "app", "models", "parsers", "edi", "documents", file_name)
      if !File.exists?(file_location)
        file_location = file_name
      end

      # Read and parse the definition
      str = File.open(file_location, 'r').read
      #@dir_name = File.dirname(File.expand_path(file_name)) # to look up other files if needed
      @x12_definition = X12::XMLDefinitions.new(str)

      # Populate fields in all segments found in all the loops
      @x12_definition[X12::Loop].each_pair{|k, v|
        #puts "Populating definitions for loop #{k}"
        process_loop(v)
      } if @x12_definition[X12::Loop]

      # Merge the newly parsed definition into a saved one, if any.
      if save_definition
        @x12_definition.keys.each{|t|
          save_definition[t] ||= {}
          @x12_definition[t].keys.each{|u|
            save_definition[t][u] = @x12_definition[t][u]
          }
          @x12_definition = save_definition
        }
      end

      #puts PP.pp(self, '')
    end # initialize
  end

  module EnumBehaviour
    def to_ary
      to_a
    end

    def map
      to_ary.map do |item|
        yield item
      end
    end

    def first
      to_ary.first
    end

    def last
      to_ary.last
    end

    def select
      to_ary.select do |item|
        yield item
      end
    end

    def reject
      to_ary.reject do |item|
        yield item
      end
    end

    def detect
      to_ary.detect do |item|
        yield item
      end
    end
  end

  class Loop
    # include EnumBehaviour

    def blank?
      self.to_s.blank?
    end
  end

  class Segment
    # include EnumBehaviour

    def blank?
      self.to_s.blank?
    end
  end

  class Empty
    def blank?
      false
    end
  end
end
