file = require 'fs'
read = file.readFileSync
write = file.writeFileSync
utils = require './utils'
db = require './models'
models = db.models

io = require('socket.io').listen 8081
io.set 'log level', 0

room = db.lookup '3ce6ad4d8a7f57c7'

session_file = process.cwd()+'/data/sessions.json'
sessions = JSON.parse read session_file, 'utf8'
dump_sessions = ->
	write session_file, JSON.stringify sessions

incoming_events = {
	login: (info)->
		user = info.username
		pass = info.password
	append: (info)->
		room = db.lookup info.roomid
		target = info.target
		vidid = info.vidid
		pos = info.pos
		return if not room
		return if target != 'playlist' and target != 'queue'
		return if typeof vidid != 'string' or vidid.length != 11
		list = room.get(target)
		if typeof pos != 'undefined'
			return if typeof pos != 'number'
			return if pos < 0 or pos > list.length
		video = new models.video {vidid: vidid}
		room.get(target).insert video, pos
	remove: (info)->
		room = db.lookup info.roomid
		return if not room or not info.vid
		room.get('playlist').remove info.vid
		room.get('queue').remove info.vid
	prompt: (info)->
		room = db.lookup info.roomid
		return if not room
		this.emit 'state', room.state()
	playback: (info)->
		room = db.lookup info.roomid
		return if not room
		current = room.get 'current'
		return if not current
		if info.state and info.state != room.get 'state'
			return if state != 'playing' and state != 'paused'
			room.play() if state == 'playing'
			room.pause() if state == 'paused'
		if info.time and typeof info.time is 'number'
			return if info.time > current.get time
			room.seek() info.time
	subscribe: (info)->
		sock = this
		room = db.lookup info.roomid
		return if not room
		room.bind 'changed', -> sock.emit 'state', room.state()
		room.get('playlist').bind 'changed', ->
			sock.emit 'playlist', room.get('playlist').json()
		room.get('userlist').bind 'changed', ->
			sock.emit 'userlist', room.get('userlist').json()
		room.get('modlist').bind 'changed', ->
			sock.emit 'modlist', room.get('modlist').json()
		room.get('mutelist').bind 'changed', ->
			sock.emit 'mutelist', room.get('mutelist').json()
		room.get('userlist').insert this.user
	prompt: (info)->
		this.emit 'obj', db.lookup info.id
	disonnect: ->
		room.get('userlist').remove this.user
}

io.sockets.on 'connection', (socket)->
	cookies = utils.cookie socket.handshake.headers.cookie or ''
	if cookies.session and typeof sessions[cookies.session] != 'undefined'
		session = cookies.session
		user = sessions[session]
	else 
		session = utils.random()
		user = new models.user
		user.throwaway = true
		sessions[session] = user
	socket.user = user
	for event, fn of incoming_events
		socket.on event, fn
	socket.emit 'session', session

module.exports = {
	dump: dump_sessions
}