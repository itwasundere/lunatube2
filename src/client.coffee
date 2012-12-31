window.socket = io.connect 'http://localhost:8081'
socket.on 'session', (session)->
	document.cookie = 'session='+session
socket.on 'state', (state)->
	console.log state
socket.on 'userlist', (info)->
	console.log info
socket.on 'playlist', (info)->
	console.log info
socket.on 'obj', (info)->
	console.log info