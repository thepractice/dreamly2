jQuery ->

	# Infinite scroll

	# It doesn't listen for scroll unless there is pagination class
	if $('.pagination').length
		$(window).scroll ->
			# Finds achor tag in pagination with rel attribute = 'next'
			$next = $('.pagination a[rel="next"]')
			# Sets url variable to the href value of that anchor tag
			url = $($next).attr('href')
			if url && $(window).scrollTop() > $(document).height() - $(window).height() - 100
				# Since this replaces whole pagination with this text, it prevents loading of too many records.
				# This line is immediately followed by this getScript() which triggers another operation on .pagination
				$('.pagination').text('Loading...')
				# Triggers the js.erb file
				$.getScript(url)
			$(window).scroll


	# Datepicker

	$('#dream_dreamed_on').datepicker

	$('[data-behaviour~=datepicker]').datepicker


	# Ajax dream form

$ ()->
	$("form#new_dream").on "ajax:success", (event, data, status, xhr) ->
	#	$('#modal-window').modal('hide')
		window.location.pathname = "/dreams/#{data.id}"

	$("form#new_dream").on "ajax:error", (event, xhr, status, error) ->
		errors = jQuery.parseJSON(xhr.responseText)
		errorcount = errors.length
		$('#dream_error_explanation').empty()
		if errorcount > 1
			$('#dream_error_explanation').append('The form contains ' + errorcount + ' errors.')
		else
			$('#dream_error_explanation').append('The form contains 1 error')
		$('#error_explanation').append('<ul>')
		for e in errors
			$('#dream_error_explanation').append('<li>' + e + '</li>')
		$('#dream_error_explanation').append('</ul>')
		$('#dream_error_explanation_wrapper').show()

	$('#modal-window').on 'hidden.bs.modal', (e) ->
		$("#dream_error_explanation_wrapper").hide()

# Ajax Signin form

	$("form#new_user").on "ajax:success", (event, data, status, xhr) ->
		alert('signin success')
		current_user_id = xhr.responseJSON.current_user_id
		window.location.pathname = "/users/#{current_user_id}"

	$("form#new_user").on "ajax:error", (event, xhr, status, error) ->
		errors = jQuery.parseJSON(xhr.responseText)
		$('#login_error_explanation').empty()
		$('#login_error_explanation').append(errors.error)
		$('#login_error_explanation_wrapper').show()

	$('#modal-window-login').on 'hidden.bs.modal', (e) ->
		$("#login_error_explanation_wrapper").hide()

	# For hiding an element with data-hide="alert"

	$("[data-hide]").on "click", (event) ->
		$("." + $(this).attr("data-hide")).hide()

# Ajax Sign up form

	$("#signup_button").on "click", (event) ->
		$("#modal-window-login").modal('hide')

	$("form#signup_form").on "ajax:success", (event, data, status, xhr) ->
		if data.success
			current_user_id = xhr.responseJSON.current_user_id
			window.location.pathname = "/users/#{current_user_id}"
		else
			console.log('dumb')
			console.log(xhr.responseText)
			console.log(xhr.responseJSON)
			errors = xhr.responseJSON.errors
			errorcount = errors.length
			$('#signup_error_explanation').empty()
			if errorcount > 1
				$('#signup_error_explanation').append('The form contains ' + errorcount + ' errors.')
			else
				$('#signup_error_explanation').append('The form contains 1 error')
			$('#error_explanation').append('<ul>')
			for e in errors
				$('#signup_error_explanation').append('<li>' + e + '</li>')
			$('#signup_error_explanation').append('</ul>')
			$('#signup_error_explanation_wrapper').show()

	$('#modal-window-signup').on 'hidden.bs.modal', (e) ->
		$("#signup_error_explanation_wrapper").hide()