jQuery(document).on "ready page:change", ->

	new Share('.share-box')

	$('#dream-body-textarea').editable inlineMode:false

	# to focus the wysiwig text fields within modal
	$('#modal-window').on('shown.bs.modal', () ->
		$(document).off('focusin.modal')
	)
	$('#modal-window-edit-dream').on('shown.bs.modal', () ->
		$(document).off('focusin.modal')
	)

	$('body').scrollspy
		target: '.scrollspy'
		offset: 55

	$('faq-scrollspy').affix
	$('.faq-scrollspy li a').click (event) ->
		event.preventDefault()
		$($(this).attr('href'))[0].scrollIntoView()
		scrollBy 0, -50

	# Load more JS

	$('#load-more').unbind('click').on 'click', ->
		$('#load-more-text').text('loading...')
		$next = $('.pagination a[rel="next"]').last()
		url = $($next).attr('href')
		$('#filterrific_results').append('<div>')
		$('#filterrific_results div').last().load url+' #filterrific_results'
		#gets page number of old next link
		page_number1 = url.slice(-1)
		last_link = $('.pagination a').eq(-2)
		url = $(last_link).attr('href')
		page_number2 = url.slice(-1)
		console.log page_number2
		console.log page_number1
		if page_number2 == page_number1
			$('#load-more').hide()

	$next = $('.pagination a[rel="next"]').last()
	if $next == []
		$('#load-more2').hide()

	$(document).ajaxComplete ->
		$('#load-more-text').text('load more')
		$next = $('.pagination a[rel="next"]').last()
		url = $($next).attr('href')
		page_number1 = url.slice(-1)
		last_link = $('.pagination a').eq(-2)
		url2 = $(last_link).attr('href')
		page_number2 = url2.slice(-1)
		if page_number2 < page_number1
			$('#load-more2').hide()		

	$('#load-more2').unbind('click').on 'click', ->
		$('#load-more-text').text('loading...')
		$next = $('.pagination a[rel="next"]').last()
		url = $($next).attr('href')
		$('#filterrific_results').append('<div>')
		$('#filterrific_results div').last().load url+' #filterrific_results'
		$.getScript(url)

# Ajax dream form

	# New version of turbolinks made it so modal forms only submit after refresh.
	# The below manually submits modal forms.
	#$('.submit-btn').on 'click', ->
	#	$('form.simple_form').submit()

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

# Comment form

	$("form.comment-form").on "ajax:success", (event, data, status, xhr) ->
		window.location.pathname = "/dreams/#{data.id}"

	$("form.comment-form").on "ajax:error", (event, xhr, status, error) ->
		errors = jQuery.parseJSON(xhr.responseText)
		$('.comment_error_explanation').empty()
		for e in errors
			$('.comment_error_explanation').append(e)
		$('.comment_error_explanation_wrapper').show()

# Ajax edit dream form

	$("form#edit-dream-form").on "ajax:success", (event, data, status, xhr) ->
	#	$('#modal-window-edit-dream').modal('hide')
		window.location.pathname = "/dreams/#{data.id}"

	$("form#edit-dream-form").on "ajax:error", (event, xhr, status, error) ->
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

	$('#modal-window-edit-dream').on 'hidden.bs.modal', (e) ->
		$("#dream_error_explanation_wrapper").hide()

# Ajax Signin form

	$("form#new_user").on "ajax:success", (event, data, status, xhr) ->

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
			if current_user_id == 0
				window.location.pathname = "/"
			else
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

# Enable tooltips. Must come before Impression Slider.
	$("#full-screen-icon").tooltip()
	$(".emoticon-image").tooltip()

	$('#hash-listing').on 'click', '.more-tags-class-more', ->
		$("#extra-hashes").css("display", "inline")
		$("#extra-hashes").show()
		$("#more-tags-button").hide()
		$("#less-tags-button").show()


	$('#hash-listing').on 'click', '.more-tags-class-less', ->
		$("#extra-hashes").hide()
		$("#more-tags-button").show()
		$("#less-tags-button").hide()

	$('#more-screennames-button').on 'click', ->
		$("#extra-screennames").css("display", "inline")
		$("#extra-screennames").show()
		$("#more-screennames-button").hide()
		$("#less-screennames-button").show()

	$('#less-screennames-button').on 'click', ->
		$("#extra-screennames").hide()
		$("#more-screennames-button").show()
		$("#less-screennames-button").hide()

	$(".select-js").select2 minimumResultsForSearch: 10

	# Messaing div default bottom scroll
	if typeof $('.messages')[0] != 'undefined'
		$('.messages').scrollTop($('.messages')[0].scrollHeight)

	$("#impression").slider()
	$("#impression").on "slide", (slideEvt) ->
		label = "Normal"
		if slideEvt.value == 2
			label = "Substantial"
		if slideEvt.value == 3
			label = "Epic"
		$("#impression-slider-value").text label


	$("#impression2").slider()
	$("#impression2").on "slide", (slideEvt) ->
		label = "Normal"
		if slideEvt.value == 2
			label = "Substantial"
		if slideEvt.value == 3
			label = "Epic"
		$("#impression-slider-value2").text label

	$("#impression3").slider()
	$("#impression3").on "slide", (slideEvt) ->
		label = "Normal"
		if slideEvt.value == 2
			label = "Substantial"
		if slideEvt.value == 3
			label = "Epic"
		$("#impression-slider-value3").text label