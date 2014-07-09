require 'rspec/core/formatters/base_formatter'
require 'rspec/core/formatters/html_printer'
require 'securerandom'

class ExampleGrouping
  attr_reader :examples, :groups, :name, :depth, :guid

  def each_group
    @groups.sort_by(&:name).each do |g|
      yield g
    end
  end

  def initialize(n, d)
    @guid = SecureRandom.hex 
    @depth = d
    @name = n
    @examples = {}
    @groups = []
  end

  def add(key, example)
    if key.length > 1
     k = key.first
     rest = key[1..-1]
     existing = @groups.detect { |g| g.name == k }
     unless existing
       existing = ExampleGrouping.new(k, @depth + 1)
       @groups << existing
     end
     existing.add(rest, example)
    else
      @examples[key.first] = example
    end
  end
end

class GlueFormatter < RSpec::Core::Formatters::BaseFormatter
  include ERB::Util
  def start(example_count)
    super
    puts "Running #{example_count} tests"
    @passed_examples = []
    @example_groupings = ExampleGrouping.new(nil, 0)
  end

  def example_passed(example)
    @passed_examples << example
  end

  def flatten_example(example)
    md = example.metadata
    description_stack = []
    current_eg = md[:example_group]
    while (current_eg.has_key?(:example_group))
      description_stack << current_eg[:description_args]
      current_eg = current_eg[:example_group]
    end
    description_stack << current_eg[:description_args]
    description_stack.reverse.flatten.map(&:to_s)
  end

  def add_to_examples_hash(ex)
    full_key = flatten_example(ex)
    @example_groupings.add(full_key, ex)
  end

  def start_dump
    @passed_examples.each do |ex|
      add_to_examples_hash(ex)
    end
    @pending_examples.each do |ex|
      add_to_examples_hash(ex)
    end
    @failed_examples.each do |ex|
      add_to_examples_hash(ex)
    end
    print_index_file
  end

  def print_index_file
    ifile = File.open(File.join(base_path_for_files, "index.html"), 'w')
    printer = RSpec::Core::Formatters::HtmlPrinter.new(ifile)
    printer.print_html_start
    printer.flush
    ifile.print HIDE_SHOW_JS
    ifile.print "<div id=\"nav_menu\" style=\"float: left; width: 25%;\">\n<ul>\n"
    @example_groupings.each_group do |grp|
      ifile.print "<li><a href=\"#\" onclick=\"hideExamples(); showExample('#{grp.guid}'); return false;\">#{h(grp.name)}</a></li>\n"
    end
    ifile.print "</ul>\n</div>"
    @example_groupings.each_group do |grp|
      div_for_group(ifile, grp)
    end
    ifile.print "</div></body>\n</html>\n"
    ifile.close
  end

  def base_path_for_files
    File.join(File.dirname(__FILE__), "report")
  end

  def div_for_group(f, grp)
    f.print "<div class=\"example_groupings\" id=\"example_grouping_#{grp.guid}\" style=\"float: left; width: 70%; display:none;\">\n"
    f.print "</div>\n"
  end

HIDE_SHOW_JS = <<-JSCODE
<script type="text/javascript">
// <![CDATA[
function hideExamples() {
  var elements = document.getElementsByClassName('example_groupings');
  alert(elements.length);
  for(var i = 0; i<elements.length; i++) {
     elements[i].style.display = "none";
  }
}

function showExample(eg_guid) {
  document.getElementById("example_grouping_" + eg_guid).style.display = "block";
}
// ]]>
</script>
JSCODE
end
