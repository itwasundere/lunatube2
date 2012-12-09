var stylus = require('stylus');
var express = require('express');
var app = express();
var yaml = require('js-yaml');
var fs = require('fs');

app.use('views', __dirname + '/views');
app.use('/static', express.static(__dirname + '/static'));
app.use(stylus.middleware(__dirname+'/stylus'))

app.get('/', function(req, res){
	res.render('test.jade');
});

app.get('/r/:id', function(req, res){
	res.render('room.jade');
});

var themes_name = __dirname + '/res/themes.yaml';
var themes = yaml.load(fs.readFileSync(themes_name, 'utf8'));
app.get('/static/room/skin/:theme.css', function(req, res){
	var stylesheet = __dirname + '/stylus/room.css';
	var theme = themes[req.params.theme] || themes.default;
	var room = stylus(fs.readFileSync(stylesheet, 'utf8'));
	for(key in theme)
		room.define('_'+key, new stylus.nodes.Literal('#'+theme[key]));
	room.render(function(err,css){
		res.end(css);
	});
});

app.listen(8080);