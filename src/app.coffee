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

gen_cache = ->
	cache = {}
	cache._ready = 0
	cache.explored = ->
		console.log 'k'
		console.log this._res
		this._exp = true
		this._res() if this._res
	cache.bind = (fn)->
		fn() if this._exp
		this._res = fn
	cache.lock = ->
		this._ready++
	cache.free = ->
		this._ready--
	cache.freed = -> return this._ready == 0
	return cache

explore = (id, type, cache)->
	cache = gen_cache() if not cache
	return if not id or not type
	return if cache[id]
	cache.lock()
	inst = spark.resolve id, type
	inst.bind 'ready', ->
		return if not inst._id
		cache[inst._id] = { attr: inst._attrs, type: inst._type }
		for k,v in inst._links
			explore(inst._attr[k], v, cache) 
		cache.free()
		if cache.freed()
			cache.explored()
	return cache

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
		cache = explore room._id, 'room'
		cache.bind ->
			socket.emit 'joined', { 
				cookie: cookie, 
				cache: cache,
				roomid: room._id
			}
	socket.on 'fetch', (info)->
		inst = spark.resolve info.id, info.type
		inst.bind 'ready', ->
			socket.emit 'update', {
				attr: inst._attrs,
				hash: info.hash
			}
	socket.on 'store', (info)->
		inst = spark.resolve info.id, info.type
		inst.bind 'ready', ->
			for k,v of info.attr
				inst.set k,v
			inst.save()
			socket.emit 'saved', {
				id: inst._id
				hash: info.hash
			}