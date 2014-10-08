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

	# Produces 'current' class for nav links.
	def nav_link(link_text, icon_text, link_path)
		class_name = current_page?(link_path) ? 'current' : ''

		content_tag(:li, :class => class_name) do
			link_to "#{icon(icon_text)} <span>#{link_text}</span>".html_safe, link_path
		end
	end

	# Returns the impression param in text
	def impression_status
		if params[:impression] == '2'
			'big'
		elsif params[:impression] == '3'
			'huge'
		else
			''
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

	# Allows for custom sign-in form anywhere in app using Devise
	def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_class
	  devise_mapping.to
	end


	# Hack: to get edit-dream modal div on application.html page, the edit dream form must accept
	# dream_resource as parameter instead of undefined @dream.
	def dream_resource
		@dream || Dream.first
	end

	# Comment counter
	def comment_count(dream)
		@comment_counter = 0
		dream.comments.each do |comment|
			unless comment.private && ( (current_user != comment.user) && (current_user != comment.dream.user) )
				@comment_counter = @comment_counter + 1
			end
		end
		@comment_counter
	end

end
