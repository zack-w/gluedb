module Parsers
  module Edi
    module Etf
      RPAddress = Struct.new(:street1, :street2, :city, :state, :zip)

      class ResponsiblePartyParser
        def initialize(rl)
          @rp_loop = rl
          parse_name
          parse_address
          parse_contact_info
        end

        def persist_and_return_id!
          new_person = Person.new(
            :name_first => @name_first,
            :name_middle => @name_middle,
            :name_last => @name_last,
            :name_pfx => @name_pfx,
            :name_sfx => @name_sfx
          )
          new_rp = ResponsibleParty.new(
            :entity_code => @entity_qualifier
          )
          new_person.responsible_parties << new_rp
          if !@phone.blank?
            new_person.phones << Phone.new(
              :phone_type => "home",
              :phone_number => @phone
            )
          end
          if !@email.blank?
            new_person.emails << Email.new(
              :email_type => "home",
              :email_address => @email
            )
          end
          if !@address.blank?
            new_address = Address.new(
              :address_type => "home",
              :address_1 => @address.street1,
              :city => @address.zip,
              :state => @address.state,
              :zip => @address.zip
            )
            if !@address.street2.blank?
              new_address.address_2 = @address.street2
            end
            new_person.addresses << new_address
          end

          new_person.save!
          new_rp._id
        end

        def parse_contact_info
          contact_seg= @rp_loop["PER"]
          if !contact_seg.blank?
            if contact_seg[3]
              interpret_contact_info(contact_seg[3], contact_seg[4])
            end
            if contact_seg[5]
              interpret_contact_info(contact_seg[5], contact_seg[6])
            end
            if contact_seg[7]
              interpret_contact_info(contact_seg[7], contact_seg[8])
            end
          end
        end

        def interpret_contact_info(con_kind, con_val)
          if con_kind == "TE"
            @phone = con_val
          elsif con_kind == "EM"
            @email = con_val
          end
        end

        def parse_address
          if !@rp_loop["N3"].blank?
            street1 = @rp_loop["N3"][1]
            street2 = @rp_loop["N3"][2]
            city = @rp_loop["N4"][1]
            state = @rp_loop["N4"][2]
            zip = @rp_loop["N4"][3]
            @address = RPAddress.new(
              street1,
              street2,
              city,
              state,
              zip
            )
          end
        end

        def parse_name
          name_loop = @rp_loop["NM1"]
          @entity_qualifier = name_loop[1]
          @name_first = name_loop[4]
          @name_last = name_loop[3]
          if !name_loop[5].blank?
            @name_middle = name_loop[5]
          end
          if !name_loop[6].blank?
            @name_pfx= name_loop[6]
          end
          if !name_loop[7].blank?
            @name_middle = name_loop[7]
          end
        end

        def self.parse_persist_and_return_id(rp_loop)
          rp_parser = self.new(rp_loop)
          rp_parser.persist_and_return_id!
        end
      end
    end
  end
end
