module Parsers
  module XTwelve
    class RawMemberAddress
      attr_reader :street1, :street2, :city, :state, :zip

      extend EtfXpath

      def self.parse(node)
        return nil unless xpath(node, "etf:N3_MemberResidenceStreetAddress_2100A").any?
        self.new(node)
      end

      def initialize(node)
        @street1 = self.class.value_if_node(node, "etf:N3_MemberResidenceStreetAddress_2100A/etf:N301__MemberAddressLine")
        @street2 = self.class.value_if_node(node, "etf:N3_MemberResidenceStreetAddress_2100A/etf:N302__MemberAddressLine")
        @city = self.class.value_if_node(node, "etf:N4_MemberCityStateZIPCode_2100A/etf:N401__MemberCityName")
        @state = self.class.value_if_node(node, "etf:N4_MemberCityStateZIPCode_2100A/etf:N402__MemberStateCode")
        @zip = self.class.value_if_node(node, "etf:N4_MemberCityStateZIPCode_2100A/etf:N403__MemberPostalZoneOrZipCode")
      end
    end

    RawCoverage = Struct.new(:hios_id, :premium, :coverage_kind)

    class RawMember
      attr_reader :name_first, :name_middle, :name_last, :name_prefix, :name_suffix
      attr_reader :dcas_id
      attr_reader :dob, :ssn, :gender
      attr_reader :relationship_status_code, :benefit_status_code, :employment_status_code
      attr_reader :phone, :email, :address
      attr_reader :coverage

      include EtfXpath

      def initialize(node)
        @dcas_id = parse_dcas_id(node)
        @relationship_status_code = parse_relationship_status_code(node)
        @benefit_status_code = parse_benefit_status_code(node)
        @employment_status_code = parse_employment_status_code(node)
        @coverage = parse_coverage(node)
        parse_contact_info(node)
        parse_demographics(node)
      end

      def parse_dcas_id(node)
        xpath(node, "etf:REF_MemberSupplementalIdentifier_2000[etf:REF01__ReferenceIdentificationQualifier = '17']/etf:REF02__MemberSupplementalIdentifier").first.text
      end

      def parse_relationship_status_code(node)
        value_if_node(node, "etf:INS_MemberLevelDetail_2000/etf:INS02__IndividualRelationshipCode")
      end

      def parse_benefit_status_code(node)
        value_if_node(node, "etf:INS_MemberLevelDetail_2000/etf:INS05__BenefitStatusCode")
      end

      def parse_employment_status_code(node)
        value_if_node(node, "etf:INS_MemberLevelDetail_2000/etf:INS08__EmploymentStatusCode")
      end

      def parse_demographics(node)
        name_node = xpath(node, "etf:Loop_2100A/etf:NM1_MemberName_2100A")
        @name_first = value_if_node(name_node, "etf:NM104__MemberFirstName")
        @name_last = value_if_node(name_node, "etf:NM103__MemberLastName")
        @name_middle = value_if_node(name_node, "etf:NM105__MemberMiddleName")
        @name_prefix = value_if_node(name_node, "etf:NM106__MemberNamePrefix")
        @name_suffix = value_if_node(name_node, "etf:NM107__MemberNameSuffix")
        @ssn = value_if_node(name_node, "etf:NM109__MemberIdentifier")

        other_node = xpath(node, "etf:Loop_2100A/etf:DMG_MemberDemographics_2100A")
        @dob = value_if_node(other_node, "etf:DMG02__MemberBirthDate")
        @gender = value_if_node(other_node, "etf:DMG03__GenderCode")

        @address = RawMemberAddress.parse(xpath(node,"etf:Loop_2100A"))
      end

      def parse_contact_info(node)
        contact_node = xpath(node,"etf:Loop_2100A/etf:PER_MemberCommunicationsNumbers_2100A")
        return(nil) unless contact_node.any?
        assign_contact_info(
          contact_node,
          "etf:PER03__CommunicationNumberQualifier",
          "etf:PER04__CommunicationNumber"
        )
        assign_contact_info(
          contact_node,
          "etf:PER05__CommunicationNumberQualifier",
          "etf:PER06__CommunicationNumber"
        )
      end

      def assign_contact_info(parent_node, finder_expr, value_expr)
        found_node = xpath(parent_node, finder_expr)
        if found_node.any?
          contact_val = xpath(parent_node, value_expr).first.text.strip
          if found_node.first.text.strip == 'TE'
            @phone = contact_val
          else
            @email = contact_val
          end
        end
      end

      def parse_coverage(node)
        coverage_hios = value_if_node(node, "etf:Loop_2300/etf:REF_HealthCoveragePolicyNumber_2300[etf:REF01__ReferenceIdentificationQualifier = 'CE']/etf:REF02__MemberGroupOrPolicyNumber")
        coverage_premium = value_if_node(node, "etf:Loop_2700/etf:Loop_2750[etf:N1_ReportingCategory_2750/etf:N102__MemberReportingCategoryName = 'PRE AMT 1']/etf:REF_ReportingCategoryReference_2750/etf:REF02__MemberReportingCategoryReferenceID")
        coverage_kind = value_if_node(node, "etf:Loop_2300/etf:HD_HealthCoverage_2300/etf:HD03__InsuranceLineCode")
        RawCoverage.new(
          coverage_hios,
          coverage_premium,
          coverage_kind
        )
      end

      # FIXME: Actually pull out the employment code, disabled status
      def to_model(carrier_id)
        coverage_kind = (@coverage.coverage_kind.strip == 'HLT') ? "health" : "dental"
        new_enrollee = Enrollee.new(
          :hbx_member_id => @dcas_id,
          :benefit_status_code => map_benefit_status_code,
          :relationship_status_code => map_relationship_code,
          :employment_status_code => "active"
        )
      end

      def to_enrollment_member
        EnrollmentMember.new(
          :m_id => @dcas_id,
          :pre_amt => @coverage.premium
        )
      end

      def map_employment_status_code
        employment_status_codes = {
          "AC" => "active",
          "FT" => "full-time",
          "RT" => "retired",
          "PT" => "terminated"
        }
        result = employment_status_codes[@employment_status_code.strip]
        result.nil? ? "unknown" : result
      end

      def map_relationship_code
        relationship_codes = {
          "18" => "self",
          "01" => "spouse",
          "19" => "child",
          "15" => "ward"
        }
        result = relationship_codes[@relationship_status_code.strip]
        result.nil? ? "child" : result
      end

      def map_benefit_status_code
        benefit_codes = {
          "C" => "cobra",
          "T" => "tefra",
          "S" => "surviving insured",
          "A" => "active"
        }
        result = benefit_codes[@benefit_status_code.strip]
        result.nil? ? "active" : result
      end

      def map_gender_code
        gender_codes = {
          "M" => "male",
          "F" => "female"
        }
        result = gender_codes[@gender.strip]
        result.nil? ? "unknown" : result
      end

      def try_to_persist
        new_person = nil
        new_member = check_for_member(@dcas_id)
        if new_member.nil?
          new_person = check_for_person(@ssn, @name_first, @name_last, @dob)
          if new_person.nil?
            new_person = Person.new
          end
          new_member = Member.new
          new_person.members << new_member
        else
          new_person = new_member.person
        end
        new_person.name_pfx = @name_prefix
        new_person.name_first = @name_first
        new_person.name_middle = @name_middle
        new_person.name_last = @name_last
        new_person.name_sfx = @name_suffix
        new_member.gender = map_gender_code
        new_member.hbx_member_id = @dcas_id
        new_member.dob = @dob
        new_member.ssn = @ssn
        unless @address.blank?
          new_address = Address.new(
            :address_type => "home",
            :address_1 => @address.street1,
            :address_2 => @address.street2,
            :city => @address.city,
            :state => @address.state,
            :zip => @address.zip
          )
          unless new_person.addresses.any? { |a| a.match(new_address) }
            new_person.addresses << new_address
          end
        end
        unless @email.blank?
          new_email = Email.new(
            :email_type => "home",
            :email_address => @email
          )
          unless new_person.emails.any? { |a| a.match(new_email) }
            new_person.emails << new_email
          end
        end
        unless @phone.blank?
          new_phone = Phone.new(
            :phone_type => "home",
            :phone_number => @phone
          )
          unless new_person.phones.any? { |a| a.match(new_phone) }
            new_person.phones << new_phone
          end
        end
        new_person.save!
      end

      def check_for_person(m_ssn, m_first, m_last, m_dob)
        return(nil) if m_ssn.blank?
        Person.where("members.ssn" => m_ssn).first
      end

      def check_for_member(dcas_no)
        person = Person.where("members.hbx_member_id" => dcas_no).first
        return(nil) if person.blank?
        person.nil? ? nil : (person.members.detect { |m| m.hbx_member_id == dcas_no}) 
      end
    end
  end
end
