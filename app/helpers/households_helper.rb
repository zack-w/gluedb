	module HouseholdsHelper
		def controls_for_households(household)
			# TODO: add roles/filters
			# if current_user.manages?(person)
			if user_signed_in?
				partial = controls_partial_for_households(household)
				contents = render(partial: partial, locals: {household: household})
				content_tag(:ul, contents, class: "nav nav-list")
			end
		end

		def controls_partial_for_people(household)
			'housholds/controls/admin'
			# if current_user.admin?
			# 	'people/controls/admin'
			# elsif current_user.author?
			# 	'people/controls/author'
			# elsif current_user.editor?
			# 	'people/controls/editor'
			# end
		end
end