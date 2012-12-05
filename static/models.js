function now() { return Math.floor((new Date()).getTime()/1000) }

var models = {

Message: Backbone.Model.extend({

}),

User: Backbone.Model.extend({

}),

Room: Backbone.Model.extend({
	defaults: {
		player: new YoutubePlayer(),
		queue: new VideoList(),
		playlist: new VideoList(),
		users: new Backbone.Collection(),
		messages: new Backbone.Collection(),
		mods: [],
		mutes: [],
		hides: [],
		owner: ''
	}
}),

YoutubePlayer: Backbone.Model.extend({
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
}),

Video: Backbone.Collection.extend({
	defaults: {
		vidid: '',
		duration: 0,
		title: '',
		uploader: ''
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
		var seconds = this.get('time');
		var minutes = Math.floor(seconds/60);
		var mod_seconds = seconds%60+'';
		if (mod_seconds.length != 2) mod_seconds = '0'+mod_seconds;
		return minutes+':'+mod_seconds;
	}
}),

VideoList: Backbone.Collection.extend({
	model: Video,
	after: function(video) {
		video = this.get(video.id);
		if (!video) return null;
		var index = this.indexOf(video) + 1;
		if (index >= this.length) index = 0;
		return this.at(index);
	}
}),

};