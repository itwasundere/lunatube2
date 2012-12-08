var Message = Backbone.Model.extend({

});

var User = Backbone.Model.extend({

});

var Room = Backbone.Model.extend({
	defaults: {
		mods: [],
		mutes: [],
		hides: [],
		owner: ''
	},
	initialize: function() {
		this.set({
			player: new YoutubePlayer(),
			queue: new VideoList(),
			playlist: new VideoList(),
			users: new Backbone.Collection(),
			messages: new Backbone.Collection()
		});
	}
});

var YoutubePlayer = Backbone.Model.extend({
	defaults: {
		playing: false,
		video: null
	},
	initialize: function() {
		var self = this;
		this.duration = 0;
		setInterval(function(){
			var vid = self.get('video');
			if (!vid) return;
			if (self.time() > vid.get('duration'))
				self.trigger('end');
		},1000);
	},
	time: function() {
		if (!this.get('playing'))
			return this.duration;
		else return this.duration + now() - this.start;
	},
	seek: function(time) {
		this.start = now();
		this.duration = time;
	},
	toggle: function() {
		this.set('playing',!this.get('playing'));
		if (!this.get('playing'))
			this.duration += now() - this.start;
		else
			this.start = now();
	}
});

var Video = Backbone.Model.extend({
	defaults: {
		vidid: '',
		duration: 0,
		title: '',
		uploader: '',
		playlist: '',
		thumb: ''
	},
	fetchInfo: function() {
		var url = this.get('vidid');
		if (!url) return;
		var infourl = 'http://gdata.youtube.com/feeds/api/videos/'+url+
			'?v=2&alt=json&key=AI39si5Us3iYwmRdK0wa2Qf2P9eV-'+
			'Z8tbjogUWw1B4JQUs191PgYNJChEKEooOq6ykQzhywLEBA9WxuKphpWUoCRA7S7jeLi5w';
		var self = this;
		$.get(infourl, function(data){
			if (!data.entry) data = JSON.parse(data);
			self.set({
				title: data.entry.title.$t,
				uploader: data.entry.author[0].name.$t,
				time: parseInt(data.entry.media$group.yt$duration.seconds),
				thumb: data.entry.media$group.media$thumbnail[0].url
			});
		});
	},
	time: function() {
		var seconds = this.get('duration');
		var minutes = Math.floor(seconds/60);
		var mod_seconds = seconds%60+'';
		if (mod_seconds.length != 2) mod_seconds = '0'+mod_seconds;
		return minutes+':'+mod_seconds;
	}
});

var VideoList = Backbone.Collection.extend({
	model: Video,
	after: function(video) {
		video = this.get(video.id);
		if (!video) return null;
		var index = this.indexOf(video) + 1;
		if (index >= this.length) index = 0;
		return this.at(index);
	}
});
