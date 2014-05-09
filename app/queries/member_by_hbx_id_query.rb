class MemberByHBXIDQuery
  def initialize(dcas_no)
    @dcas_no = dcas_no
  end

  def execute
    person = Person.where("members.hbx_member_id" => @dcas_no).first
    return(nil) if person.blank?
    person.nil? ? nil : (person.members.detect { |m| m.hbx_member_id == @dcas_no}) 
  end
end