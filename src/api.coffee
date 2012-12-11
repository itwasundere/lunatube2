socket = io.connect 'http://localhost:8081/'

###
ask server for join request
server replies with cached data
ask for data as you go along using the save / load functions
###

roomid = get_roomid window.location.pathname
socket.emit 'join', {roomid: roomid, cookie: get_cookie 'session'}
socket.on 'joined', (res)->
	document.cookie = 'session='+res.cookie
	for id,obj of res.cache
		continue if id[0] is '_'
		window.sparkcache[id] = new models[obj.type](obj.attr)
	window.room = resolve res.roomid
socket.on 'update', (data)->
	console.log data
	res = callbacks[data.hash]
	res(data.attr) if res
	delete callbacks[data.hash]
socket.on 'saved', (data)->
	console.log data
	res = callbacks[data.hash]
	res(data.id)

callbacks = {}

window.store = (inst, res)->
	hash = guid()
	callbacks[hash] = res
	socket.emit 'store', { id: inst._id, type: inst._type, hash: hash, attr: inst._attrs }
window.fetch = (inst, res)->
	hash = guid()
	callbacks[hash] = res
	socket.emit 'fetch', { id: inst._id, type: inst._type, hash: hash }
