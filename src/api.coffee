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
		window.cache[id] = new models[obj.type](obj.attrs)
