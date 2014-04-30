module MembersHelper

	def member_policies(member = @member)
		member.policies
	end

end