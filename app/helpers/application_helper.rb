module ApplicationHelper

	# Returns the full title on a per-page basis.
	def full_title(page_title)
		base_title = "Just Had a Dream"
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end

	# Adjusts flash messages
	def bootstrap_class_for flash_type
		case flash_type
			when :success
				"alert-success"
			when :error
				"alert-danger"
			when :notice
				"alert-success"
			when :alert
				"alert-danger"
			else
				flash_type.to_s
		end
	end


end
