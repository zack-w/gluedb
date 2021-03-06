module CanonicalVocabulary
  class EnrollmentSerializer
    XMLNSES = {
      "xmlns:con"=>"http://dchealthlink.com/vocabularies/1/contact",
      "xmlns:bt"=>"http://dchealthlink.com/vocabularies/1/base_types",
      "xmlns:emp"=>"http://dchealthlink.com/vocabularies/1/employer",
      "xmlns:pln"=>"http://dchealthlink.com/vocabularies/1/plan",
      "xmlns:ins"=>"http://dchealthlink.com/vocabularies/1/insured",
      "xmlns:car"=>"http://dchealthlink.com/vocabularies/1/carrier",
      "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance"
    }

    attr_reader :policy

    def initialize(the_policy, opts = {})
      @policy = the_policy
      @options = opts
      @term_before_date = @options.fetch(:term_boundry) { nil }
    end

    def serialize
      builder.to_xml(:indent => 2)
    end

    def builder(xml = Nokogiri::XML::Builder.new)
      xml['ins'].send(select_root_tag.to_sym, XMLNSES) do |xml|
        xml['ins'].exchange_policy_id(@policy.enrollment_group_id)
        serialize_subscriber(xml)
        serialize_members(xml)
        serialize_employer(xml)
        serialize_rp(xml)
        serialize_carrier(xml)
        serialize_plan(xml)
      end
      xml
    end

    def serialize_rp(xml)
      if @policy.has_responsible_person?
        xml['ins'].responsible_person do |xml|
          serialize_contact(@policy.responsible_person, xml)
          xml['ins'].entity_identifier_code("Responsible Party")
        end
      end
    end

    def serialize_employer(xml)
      emp = @policy.employer
      if !emp.nil?
        xml['emp'].employer do |xml|
          xml['emp'].name(emp.name)
          xml['emp'].exchange_employer_id(emp.hbx_id)
          xml['emp'].fein(emp.fein)
        end
      end
    end

    def serialize_subscriber(xml)
      subscriber = policy.enrollees.detect { |en| en.rel_code == "self" }
      xml['ins'].subscriber do |xml|
        serialize_person(subscriber, xml)
      end
    end

    def serialize_members(xml)
      members = policy.enrollees.reject { |en| en.rel_code == "self" }
      members.each do |m|
        serialize_member(m, xml)
      end
    end

    def serialize_contact(person, xml)
      xml['con'].person do |xml|
        if !person.name_pfx.blank?
          xml['con'].name_prefix(person.name_pfx)
        end
        xml['con'].name_first(person.name_first)
        if !person.name_middle.blank?
          xml['con'].name_middle(person.name_middle)
        end
        xml['con'].name_last(person.name_last)
        if !person.name_sfx.blank?
          xml['con'].name_suffix(person.name_sfx)
        end
        if !person.home_phone.nil?
          xml['con'].phone do |xml|
            xml['con'].phone_type("home")
            xml['con'].phone_number(person.home_phone.phone_number)
          end
        end
        if !person.home_email.nil?
          xml['con'].email do |xml|
            xml['con'].email_type("home")
            xml['con'].email_address(person.home_email.email_address)
          end
        end
        if !person.home_address.nil?
          serialize_address(person.home_address, xml)
        end
      end
    end

    def serialize_person(en, xml)
      member = en.member
      person = en.person
      serialize_contact(person, xml)
      xml['ins'].exchange_member_id(en.m_id)
      xml['ins'].individual_relationship_code(en.rel_code.capitalize)
      if !member.dob.blank?
        xml['ins'].DOB(member.dob.strftime("%Y%m%d"))
      end
      if !member.ssn.blank?
        xml['ins'].SSN(member.ssn)
      end
      xml['ins'].gender_code(member.gender)
      xml['ins'].tobacco_use("Unknown")
      xml['ins'].coverage do |xml|
        xml['ins'].plan_id_ref(policy.plan._id)
        xml['ins'].premium_amount(en.pre_amt)
        if en.coverage_start.nil?
          raise @policy.inspect
        end
        xml['ins'].benefit_begin_date(en.coverage_start.strftime("%Y%m%d"))
        if should_show_end_date(en)
          xml['ins'].benefit_end_date(en.coverage_end.strftime("%Y%m%d"))
        end
      end
    end

    def should_show_end_date(en)
      if @term_before_date.nil?
        return(!en.coverage_end.blank? && !en.active?)
      end
      return(false) if en.coverage_end.blank?
      en.coverage_end <= @term_before_date
    end

    def serialize_address(addr, xml)
      xml['con'].address do |xml|
        xml['con'].address_type("home")
        xml['con'].address do |xml|
          xml['bt'].address_1(addr.address_1)
          if !addr.address_2.blank?
            xml['bt'].address_2(addr.address_2)
          end
          xml['bt'].city(addr.city)
          xml['bt'].state(addr.state)
          xml['bt'].zipcode(addr.zip)
        end
      end
    end

    def serialize_member(member, xml)
      if !member.canceled?
        xml['ins'].member do |xml|
          serialize_person(member, xml)
        end
      end
    end

    def serialize_plan(xml)
      plan = @policy.plan
      carrier = @policy.carrier
      xml['ins'].plan do |xml|
        xml['pln'].plan do |xml|
          xml['pln'].carrier_id_ref(carrier._id)
          xml['pln'].hios_plan_id(plan.hios_plan_id)
          xml['pln'].plan_name(plan.name)
          xml['pln'].coverage_type(@policy.coverage_type.capitalize)
        end
        xml['ins'].plan_id(plan._id)
        xml['ins'].premium_amount_total(@policy.pre_amt_tot)
        if @policy.employer.nil?
          xml['ins'].aptc_amount(@policy.applied_aptc)
        else
          xml['ins'].total_employer_responsibility_amount(@policy.tot_emp_res_amt)
        end
        xml['ins'].total_responsible_amount(@policy.tot_res_amt)
      end
    end

    def serialize_carrier(xml)
      carrier = policy.carrier
      suffix = profile_suffix
      profile_name = "#{carrier.abbrev}_#{suffix}"
      xml['ins'].carrier do |xml|
        xml['car'].carrier do |xml|
          xml['car'].name(profile_name)
          xml['car'].display_name(carrier.name)
          xml['car'].exchange_carrier_id(carrier.hbx_carrier_id)
        end
        xml['ins'].carrier_id(carrier._id)
      end 
    end

    def select_root_tag
      @policy.employer.nil? ? "individual_market_enrollment_group" : "shop_market_enrollment_group"
    end

    def profile_suffix
      @policy.employer.nil? ? "IND" : "SHP"
    end
  end
end
