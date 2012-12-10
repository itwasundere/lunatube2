globals = module.exports

globals.schemas = {}
globals.models = {}
globals.instances = {}

globals.store = (inst, res)->
	doc = globals.instances[inst._id] or new globals.models[inst._type]
	for k,v of inst._attrs
		doc[k] = v
	if inst._models
		doc.models = inst._models
	doc.save -> res doc._id
	globals.instances[doc._id] = doc
globals.fetch = (inst, res)->
	return if not id = inst._id
	globals.models[inst._type].findOne {_id: id}, (err,doc)->
		attrs = {}
		for k,v of inst._attrs
			attrs[k] = doc[k]
		for k,v of inst._links
			attrs['_'+k] = doc[k]
		if doc.models
			attrs = doc.models
		globals.instances[doc._id] = doc
		res attrs
globals.query = (type, query, res)->
	globals.models[type].find query, (err,docs)->
		ids = []
		for doc in docs
			ids.push(doc._id)
			globals.instances[doc._id] = doc
		res(ids)

mongoose = require 'mongoose'
yaml = require 'js-yaml'
fs = require 'fs';

db = mongoose.createConnection('localhost','test')

resolve_type = (type)->
	switch type
		when 'String' then String
		when 'Number' then Number

globals.init = (schemas_file)->
	for classname,schema of schemas_file
		skeleton = {}
		schema = {} if not schema
		for key,type of schema.attrs
			skeleton[key] = resolve_type type
		for key,type of schema.links
			skeleton[key] = String
		schema = new mongoose.Schema(skeleton)
		globals.schemas[classname] = schema
		globals.models[classname] = db.model(classname, schema)
		listschema = new mongoose.Schema({models: Array})
		globals.models[classname+'list'] = db.model(classname+'list', listschema)
