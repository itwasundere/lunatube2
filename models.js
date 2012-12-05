var database = require('./database.js');
var schema = require('./schema.js');
var utils = require('./utils.js');
var models = {};

var fns = {

video: {
	initialize: function() {
		if (!this.get('vidid')) return;
		utils.yt.info(this);
	}
},

player: database.Backbone.Model.extend({
	defaults: {
		playing: false,
		video: null
	},
	initialize: function() {
		this.playhead = 0;
	},
	prep: function(video) {
		this.set('video', video);
		this.set('playing', false);
		this.arm(0);
		this.playhead = 0;
	},
	arm: function(time) {
		var self = this;
		if (this.alarm) clearTimeout(this.alarm);
		if (time > 0)
			this.alarm = setTimeout(function(){
				self.trigger('end');
			}, time*1000);
	},
	toggle: function() {
		if (!this.get('video')) return;
		this.set('playing', !this.get('playing'));
		if (this.get('playing')) {
			var total = this.get('video').get('duration');
			this.arm(total - this.playhead);
			this.start = utils.now();
		}
		else {
			this.playhead += utils.now() - this.start;
			this.arm(0);
		}
	},
	time: function() {
		if (!this.get('video')) return 0;
		if (this.get('playing'))
			return utils.now() - this.start + this.playhead;
		else
			return this.playhead;
	},
	seek: function(time) {
		if (!this.get('video')) return;
		this.start = utils.now();
		this.playhead = time;
		if (this.get('playing')) {
			var total = this.get('video').get('duration');
			this.arm(total - this.playhead);
		}
	}
}),

room: {
	initialize: function() {
		var self = this;
		this.set('player', new fns.player());
		this.set('queue', new models.videolist());
		this.playlist = new models.videolist()
		this.playlist.fetch({
			params: { playlist: this.get('playlist') }, 
			success: function() {
				self.get('player').on('end', function(){
					self.advance(); });
				self.advance();
			}
		});
	},
	advance: function() {
		var qvid = this.get('queue').where({watched: undefined})[0];
		if (qvid) {
			qvid.set({watched: true})
			this.get('player').prep(qvid);
		} else {
			if (this.playlist.length == 0) return;
			var playlist = this.playlist;
			var playhead = playlist.where({playhead: true})[0];
			if (!playhead) {
				playhead = new models.video({playhead: true});
				playlist.add(playhead, {at: 0});
			}
			var index = playlist.indexOf(playhead);
			playlist.remove(playhead);
			index = index % playlist.length;
			this.get('player').prep(playlist.at(index));
			playlist.add(playhead, {at: index + 1});
		}
		this.get('player').toggle();
	},
	mod: function(user) {
		var modlist = this.get('modlist');
		if (modlist.indexOf(user.id) < 0)
			modlist.push(user.id)
		else utils.remove(modlist, user.id);
	},
	mute: function(user) {
		var mutelist = this.get('mutelist');
		if (mutelist.indexOf(user.id) < 0)
			mutelist.push(user.id)
		else utils.remove(mutelist, user.id);
	},
	queue: function(video) {
		queue.add(video);
	},
	playlist: function(video) {
		playlist.add(video);
		video.set({playlist: this.get('playlist')});
		video.save();
	},
	join: function(model) {
		this.get('userlist').push(model.id);
	},
	leave: function(model) {
		var idx = this.get('userlist').indexOf(model.id);
		this.get('userlist').splice(idx, 1);
	}
}

}

var bind_fns = function(){
	// todo -- consider defaults
	var callback = models.ready_fn;
	for (key in schema) {
		models[key] = database[key].extend(fns[key]);
		var collection = database.Backbone.Collection.extend({
			model: models[key] });
		collection.classname = models[key].classname;
		models[key+'list'] = collection;
	}
	if (callback) callback();
};

models.ready = function(callback){
	if (models.user) callback();
	else models.ready_fn = callback;
}

database.ready(bind_fns);
models.ready_fn = function(){};
module.exports = models;