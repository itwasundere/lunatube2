yaml = require('js-yaml');
fs = require('fs');
utils = require './lib/utils'

io = require('socket.io').listen(8081);
mongo = require('./lib/mongo');
spark = require('./lib/spark');
utils = require('./lib/utils');

schemas_name = __dirname+'/res/schema.yaml';
schemas = yaml.load(fs.readFileSync(schemas_name, 'utf8'));
models = spark.spark(schemas);
mongo.init schemas
spark.store = mongo.store;
spark.fetch = mongo.fetch;
spark.query = mongo.query;

session_scheme = spark.gen_class 'session',{attrs:{socket:null,user:null,room:null}}
session = class extends session_scheme

logins = {}
rooms = new models.roomlist
rooms.all()

io.sockets.on 'connection',(socket)->
	ip = socket.handshake.address
	return if utils.gate 'join', ip
	socket.on 'join', (data)->
		return if not data or not room = rooms.get(data.roomid)
		cookie = data.cookie
		if not user = logins[cookie]
			user = new models.user
			cookie = utils.random()
			logins[cookie] = user
		sess = new session { user: user, room: room, socket: socket }
		socket.emit 'joined', { cookie: cookie }
