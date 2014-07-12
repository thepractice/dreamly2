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

#$("form.new_dream").on "ajax:success", (event, data, status, xhr) ->
#  $("form.new_dream")[0].reset()
#  $('#new-dream-modal').modal('hide')

	$("#new_dream").on "ajax:success", (event, data, status, xhr) ->
		$("#new-dream-modal").append xhr.responseText


	$("#new_dream").on "ajax:error", (event, data, status, error) ->
		$("#new_dream").append "<p>ERROR</p>"