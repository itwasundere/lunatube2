var Backbone = require('Backbone');
var schemas = require('./schema.js');
var mongoose = require('mongoose');
var bbmodels = {};
var mgmodels = {};

var store = {
	library: {},
	save: function(model, options) {
		var id = model.id, self = this;
		var inst = this.library[id]
			? this.library[id]
			: new mgmodels[model.constructor.classname];
		for (key in schemas[model.constructor.classname])
			inst[key] = model.get(key);
		inst.save(function(){
			model.id = inst._id;
			self.library[inst._id] = inst;
			options.success(model);
		});
	},
	destroy: function(model, options) {
		var id = model.id;
		var mod = mgmodels[model.constructor.classname];
		var self = this;
		mod.findOne({_id: model.id}, function(err, doc){
			doc.remove(function(){
				if (self.library[model.id])
					delete self.library[model.id];
				options.success(model);
			});
		});
	},
	read: function(model, options) {
		var self = this;
		if (model.id) {
			mgmodels[model.constructor.classname].findOne({_id: model.id}, function(err,doc){
				var attrs = {};
				for (key in schemas[model.constructor.classname])
					attrs[key] = doc[key];
				attrs.id = doc._id;
				self.library[doc._id] = doc;
				options.success(attrs);
			});
		} else {
			mgmodels[model.constructor.classname].find(options.params, function(err,docs){
				var objs = [];
				for (idx in docs) {
					var doc = docs[idx];
					var attrs = {};
					for (key in schemas[model.constructor.classname])
						attrs[key] = doc[key];
					attrs.id = doc._id;
					self.library[doc._id] = doc;
					objs.push(attrs);
				}
				options.success(objs);
			});
		}
	}
}

Backbone.sync = function(method, model, options){
	switch(method) {
		case 'create':
		case 'update':
			store.save(model,options); break;
		case 'delete':
			store.destroy(model,options); break;
		case 'read':
			store.read(model,options); break;
	}
};

var main = function() {
	for (idx in schemas) {
		var classname = idx;
		var schema = new mongoose.Schema(schemas[classname]);
		var mg_model = db.model(classname, schema);
		mgmodels[classname] = mg_model;
		
		var defaults = {};
		for (key in schemas[classname])
			defaults[key] = schemas[classname][key]();
		var model = Backbone.Model.extend({defaults: defaults});
		model.classname = classname;
		bbmodels[classname] = model;
	}
	if (bbmodels.ready_fn) bbmodels.ready_fn();
	return bbmodels;
}

var db = mongoose.createConnection('localhost','test');
db.on('error', console.error.bind(console, 'mongodb:'));
db.once('open', main);

bbmodels.library = store.library;
bbmodels.mgmodels = mgmodels;
bbmodels.ready = function(callback){
	if (bbmodels.user)
		callback();
	else bbmodels.ready_fn = callback;
}
bbmodels.Backbone = Backbone;
module.exports = bbmodels;