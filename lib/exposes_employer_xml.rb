require './lib/exposes_plan_xml'
require './lib/exposes_contact_xml'

class ExposesEmployerXml
  def initialize(parser)
    @parser = parser
  end

  def name
    @parser.at_css('name').text
  end

  def fein
    @parser.at_css('fein').text
  end

  def employer_exchange_id
    @parser.at_css('employer_exchange_id').text
  end

  def sic_code
    @parser.at_css('sic_code').text
  end

  def fte_count
    @parser.at_css('fte_count').text
  end

  def pte_count
    @parser.at_css('pte_count').text
  end

  def broker_npn_id
    @parser.at_css('broker npn_id').text
  end

  def open_enrollment_start
    @parser.at_css('open_enrollment_start').text
  end

  def open_enrollment_end
    @parser.at_css('open_enrollment_end').text
  end

  def plan_year_start
    @parser.at_css('plan_year_start').text
  end

  def plan_year_end
    @parser.at_css('plan_year_end').text
  end

  def plans
    result = []
    @parser.css('plans plan').each do |plan_xml|
      result << ExposesPlanXml.new(plan_xml)
    end
    result
  end

  def exchange_id
    @parser.at_css('exchange_id').text
  end

  def exchange_status
    @parser.at_css('exchange_status').text
  end

  def exchange_version
    @parser.at_css('exchange_version').text
  end

  def notes
    @parser.at_css('notes').text
  end

  def contact
    ExposesContactXml.new(@parser.at_css('vcard'))
  end
end