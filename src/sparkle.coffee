file = require 'fs'
yaml = require 'js-yaml'
yparse = yaml.load
read = file.readFileSync
write = file.writeFileSync
random = require('./utils').random

cache_file = process.cwd()+'/data/data.json'
schema_file = process.cwd()+'/res/schema.yaml'

cache = {}
lookup = (id)->
	return cache[id] if cache[id]
	return null
load = ->
	dumpfile = JSON.parse read cache_file, 'utf8'
	for id, obj of dumpfile
		continue if not obj.type or not models[obj.type]
		cache[id] = new models[obj.type]
		cache[id].load obj
	count = 0
	count++ for i of cache
	console.log count + ' objects loaded to cache'
dump = ->
	dumpfile = {}
	for id, obj of cache
		continue if obj.throwaway
		dumpfile[id] = obj.json()
	write cache_file, JSON.stringify dumpfile
	count = 0
	count++ for i of cache
	console.log count + ' objects loaded to file'

genclass = (classname, attrs, links)->
	proto = (construction)->
		this.attrs = {}
		this.attrs[i] = '' for i in attrs
		this.links = links or {}
		for k,v of construction
			continue if typeof this.attrs[k] is 'undefined'
			this.attrs[k] = v
		for k,v of construction
			continue if typeof this.links[k] is 'undefined'
			this.links[k] = v.id
		this.schema = {attrs: attrs, links: links}
		this.type = classname
		this.events = {}
		this.get = (key)->
			return this.attrs[key] if this.attrs[key]
			return lookup this.links[key] if this.links[key]
			return null
		this.set = (key, value)->
			console.log key
			console.log value
			if typeof this.attrs[key] != 'undefined'
				this.attrs[key] = value
				this.trigger 'changed'
			else if typeof this.links[key] != 'undefined'
				value.save()
				this.links[key] = value.id
				this.trigger 'changed'
		this.bind = (k, fn)->
			if not this.events[k]
				this.events[k] = []
			this.events[k].push fn
		this.trigger = (k)->
			return if not this.events[k]
			fn() for fn in this.events[k]
		this.json = ->
			return {
				type:this.type
				id:this.id
				attrs:this.attrs
				links:this.links
			}
		this.load = (json)->
			this.id = json.id
			this.attrs = json.attrs
			this.links = json.links
		this.save = ->
			if (!this.id)
				guid = random()
				guid = random() while cache[guid]
				this.id = guid
			cache[this.id] = this
		this.cons() if this.cons
		return this
	proto.extend = (fns)->
		for name, fn of fns
			this.prototype[name] = fn
	return proto

gencol = (classname, model)->
	proto = (construction)->
		if construction and construction.length
			this.models = construction
		else this.models = []
		this.type = classname + 'list'
		this.events = {}
		this.insert = (obj, pos)->
			pos = this.models.length if typeof pos is 'undefined'
			obj.save()
			this.models.splice pos, 0, obj.id
			this.trigger 'changed'
		this.save = ->
			if (!this.id)
				guid = random()
				guid = random() while cache[guid]
				this.id = guid
			cache[this.id] = this
		this.remove = (id)->
			id = id.id if id.id
			idx = this.models.indexOf id
			return if id < 0
			this.models.splice idx, 1
			this.trigger 'changed'
		this.json = ->
			return {
				type:this.type
				id:this.id
				models:this.models
			}
		this.load = (json)->
			this.id = json.id
			this.models =json.models
		this.bind = (k, fn)->
			if not this.events[k]
				this.events[k] = []
			this.events[k].push fn
		this.trigger = (k)->
			return if not this.events[k]
			fn() for fn in this.events[k]
		return this
	return proto

models = {}
schemas = yparse read schema_file, 'utf8'
for classname, schema of schemas
	models[classname] = genclass classname, schema.attrs, schema.links
	models[classname+'list'] = gencol classname, models[classname]

module.exports = {
	models: models
	cache: cache
	lookup: lookup
	dump: dump
	load: load
}