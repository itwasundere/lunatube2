var socket = io.connect('http://localhost:8081/');
socket.on('join', function (data) {
	console.log(data);
});
socket.on('disconnect',function(data){
	console.log('disconnected');
});
socket.on('connect',function(data){
	console.log('connected');
});