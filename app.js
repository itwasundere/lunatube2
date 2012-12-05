var io = require('socket.io').listen(8081);
var crypto = require('crypto');
var Backbone = require('backbone');

var rooms;
var models = require('./models.js');
models.ready(function(){
	rooms = new models.roomlist();
	rooms.fetch();
});

var random = function() { return crypto.randomBytes(8).toString('hex'); };
var cookies = {};

var Session = Backbone.Model.extend({
	defaults: {
		timeouts: {},
		user: null,
		room: null,
		socket: null
	},
	bind_event: function(event, callback, options) {
		var time = options? options.time : 100;
		var socket = this.get('socket'), self = this;
		socket.on(event, function(data){
			if (self.timed_out(event, time)) return;
			callback(data);
		});
	},
	timed_out: function(event, time) {
		var timeouts = this.get('timeouts');
		if (time < 0) return false;
		if (timeouts[event])
			return true;
		else {
			timeouts[event] = true;
			setTimeout(function(){
				timeouts[event] = false;
			}, time);
			return false;
		}
	}
});

io.sockets.on('connection', function (socket) {
	var session = new Session({socket: socket});
	session.bind_event('join', function(data){
		if (!data) return;
		var cookie = data.cookie, roomid = data.room;

		// validate user
		var user = new models.user();
		if (cookies[cookie])
			user = cookies[cookie];
		else {
			cookie = random();
			cookies[random()] = user;
		}

		// validate room
		var room = rooms.get(roomid);
		if (!room) return;
		console.log(room);
		room.join(user);
		
		session.set({ room: room, user: user });
		socket.emit('join', { 
			cookie: cookie, 
			user: user.toJSON(),
			room: room.toJSON()
		});
	});
	session.bind_event('disconnect', function(){
		if (session.get('room'))
			session.get('room').leave(session.get('user'));
	}, {time: -1});
});