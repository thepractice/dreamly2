module DeviseHelper

	# Override Devise error messages and make them display using bootstrap flash
	def devise_error_messages!
		return '' if resource.errors.empty?

		messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
		html = <<-HTML
	  <div class="alert alert-danger alert-block">
      #{messages}
    </div>
		HTML

		html.html_safe
	end
end