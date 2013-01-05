window.api = {}

// todo
on userlist, look up elements
implement playlist and queue

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
	if cache[info.id]
		cache[info.id].load info
	else
		obj = new models[info.type]
		obj.load info
		cache[info.id] = obj
socket.on 'message', (state)->
	msg = new views.message {
		user: state.user
		text: state.message
	}
	$('#messages').append msg.el

get_room_id = ->
	path = window.location.pathname
	idx = path.indexOf('/r/')
	return if idx < 0
	return path.substring idx + 3, path.length

rid = get_room_id()

socket.emit 'subscribe', {roomid: rid}

api.message = (msg)->
	socket.emit 'message', {
		roomid: rid
		message: msg
	}
api.query = (id)->
	socket.emit 'query', {
		id: id
	}