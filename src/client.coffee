_.templateSettings = {
	interpolate : /\[\[(.+?)\]\]/g
};
window.main = ->
	
	$('input#chat').keyup (event)->
		if event.keyCode == 13
			msg = $(this).val()
			api.message msg
			window.lastmsg = msg
			$(this).val ''
		if event.keyCode == 38 or event.keyCode == 40
			prev = $(this).val()
			$(this).val window.lastmsg
			window.lastmsg = prev