file = require 'fs'
yaml = require 'js-yaml'
spark = require './spark'
yparse = yaml.load
read = file.readFileSync
write = file.writeFileSync

cache_file = process.cwd()+'/data/data.json'
schema_file = process.cwd()+'/res/schema.yaml'

cache = spark.cache
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

models = {}
schemas = yparse read schema_file, 'utf8'
for classname, schema of schemas
	models[classname] = spark.genclass classname, schema.attrs, schema.links
	models[classname+'list'] = spark.gencol classname, models[classname]

module.exports = {
	models: models
	cache: spark.cache
	lookup: spark.lookup
	dump: dump
	load: load
}