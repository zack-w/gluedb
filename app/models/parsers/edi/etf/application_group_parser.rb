module Parsers
  module Edi
    module Etf
      class ApplicationGroupParser
        attr_reader :member_ids

        def initialize(people_loops)
          @people_loops = people_loops
        end

        def persist!
          primary_loop = @people_loops.detect { |pl| pl.subscriber? }
          people = Person.find_for_members(@people_loops.map(&:member_id))
          loop_lookup = @people_loops.inject({}) do |acc, pl|
            acc[pl.member_id] = pl
            acc
          end
          people_lookup = @people_loops.inject({}) do |acc, per|
             found_record = people.detect do |pm|
               pm.members.any? { |m| m.hbx_member_id == per.member_id }
             end
             acc[per.member_id] = found_record
             acc
          end
          existing_application_groups = find_existing_application_groups(people.map(&:_id))
          if existing_application_groups.count > 1
            # Hooray! Merge tiems!
            merge_multiple_existing(existing_application_groups, primary_loop.member_id, loop_lookup, people_lookup)
          elsif existing_application_groups.count == 1
            # Add all the people to the existing group
            merge_with_existing(existing_application_groups.first, primary_loop.member_id, loop_lookup, people_lookup)
          else
            # Do a brand new application group
            new_application_groups(primary_loop.member_id, loop_lookup, people_lookup)
          end
        end

        def merge_multiple_existing(application_groups, primary_member_key, loop_lookup, people_lookup)
          prime, *rest = application_groups
          existing = extract_triples(prime)
          new_relationships = create_relationship_triples(primary_member_key, loop_lookup, people_lookup)
          other_relationships = rest.inject([]) do |acc, eag|
            acc + extract_triples(eag)
          end
          added_relationships = (new_relationships | other_relationships) - existing
          added_relationships.each do |rt|
              prime.person_relationships << PersonRelationship.new({
                :subject_person => rt[0],
                :relationship_kind => rt[1],
                :object_person => rt[2]
              })
          end
          prime.save!
          rest.each(&:destroy!)
        end

        def create_relationship_triples(primary_member_key, loop_lookup, people_lookup)
          loop_lookup.keys.inject([]) do |acc, k|
              acc << [
                people_lookup[primary_member_key]._id.to_s,
                loop_lookup[k].group_relationship,
                people_lookup[k]._id.to_s
              ]
              acc
          end
        end

        def extract_triples(existing_group)
          existing_group.person_relationships.inject([]) do |acc, rel|
              acc << [
                rel.subject_person.to_s,
                rel.relationship_kind.to_s,
                rel.object_person.to_s
              ]
            acc
          end
        end

        def merge_with_existing(existing_group, primary_member_key, loop_lookup, people_lookup)
          existing_triples = extract_triples(existing_group)
          missing_triples = create_relationship_triples(primary_member_key, loop_lookup, people_lookup) - existing_triples
          missing_triples.each do |rt|
              existing_group.person_relationships << PersonRelationship.new({
                :subject_person => rt[0],
                :relationship_kind => rt[1],
                :object_person => rt[2]
              })
          end
          existing_group.save!
        end

        def new_application_groups(primary_member_key, loop_lookup, people_lookup)
          new_group = ApplicationGroup.new
          create_relationship_triples(primary_member_key, loop_lookup, people_lookup).each do |rt|
              new_group.person_relationships << PersonRelationship.new({
                :subject_person => rt[0],
                :relationship_kind => rt[1],
                :object_person => rt[2]
              })
          end
          new_group.save!
        end

        def find_existing_application_groups(person_ids)
          ApplicationGroup.where(
            "$or" => [
              {
                "person_relationships.subject_person" => { "$in" => person_ids }
              },
              {
                "person_relationships.object_person" => { "$in" => person_ids }
              }
            ]
          )
        end
      end
    end
  end
end
