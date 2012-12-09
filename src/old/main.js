_.templateSettings = {
	interpolate : /\[\[(.+?)\]\]/g
};

var socket = io.connect('http://localhost:8081/');
socket.on('join', function (data) {
	console.log(data);
	room.set(data.room);
	user.set(data.user);
});
socket.on('disconnect',function(data){
	console.log('disconnected');
});
socket.on('connect',function(data){
	console.log('connected');
});

socket.on('playlist', function(data){
	console.log(data);
	window.foo = data;
	room.get('playlist').reset(data);
});

var roomid = window.location.pathname;
if (!roomid.substr(0,3)=='/r/')
	console.error('not in room');
roomid = roomid.substr(3,roomid.length)
socket.emit('join',{roomid: roomid})

var room = new Room();
var user = new User();

$(document).ready(function(){
	window.playlist = new PlaylistView({
		model: room.get('playlist'),
		el: $('#playlist')
	});
	playlist.on('add',function(vidid){
		socket.emit('add', vidid);
	});
	window.player = new YoutubePlayerView({
		el: $('#player')
	});
	player.on('play pause end', function(){
		socket.emit('play', player.playing);
	});
	player.video(room.get('current'));
});
