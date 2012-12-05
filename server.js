var themes = require('./themes.js');
var stylus = require('stylus');
var express = require('express');
var app = express();

app.use('views', __dirname + '/views');
app.use('/static', express.static(__dirname + '/static'));
app.use(stylus.middleware(__dirname+'/stylus'))

app.get('/r/:id', function(req, res){
	res.render('room.jade');
});

// skins and themes for room
var filename = __dirname + '/stylus/room.css';
app.get('/static/room/skin/:theme.css', function(req, res){
	var room = require('fs').readFileSync(filename, 'utf8');
	var theme = themes[req.params.theme] || themes.default;
	var sty = stylus(room);
	for(key in theme)
		sty.define(key, new stylus.nodes.Literal(theme[key]));
	sty.render(function(err,css){
		res.end(css);
	});
});

app.listen(8080);
