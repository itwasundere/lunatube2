var PlaylistView = Backbone.View.extend({
	initialize: function(){
		var self = this;
		this.model.bind('add remove reset', this.render, this);
		this.$el.find('#add').click(function(){
			var url = window.prompt('Add a new video','Youtube URL');
			var vidid = parse_vidid(url);
			if (!vidid || vidid.length != 11)
				alert('Invalid youtube url');
			else self.trigger('add',vidid);
		});
		this.$el.find('#clear_btn').click(function(){
			self.trigger('clear');
		});
		this.$el.find('#import').click(function(){
			var url = window.prompt('Import from palylist','Youtube Playlist URL');
			var playlist = parse_playlist(url);
			if (!playlist)
				alert('Invalid youtube playlist url');
			else self.trigger('import',playlist);
		});
		this.subviews = {};
	},
	render: function() {
		var el = this.$el.empty();
		var self = this;
		this.model.each(function(video){
			if (self.subviews[video.id]) return;
			self.subviews[video.id] = new VideoView({model:video});
			self.subviews[video.id].render();
			el.append(self.subviews[video.id].el);
		});
	}
});

var VideoView = Backbone.View.extend({
	initialize: function() {
		this.template = _.template($('script#video').html());
	},
	render: function() {
		var video = this.model;
		var html = this.template(_.extend(video.toJSON(),{timetext:video.time()}));
		this.$el.html(html);
		this.$el.attr('id','video');
	}
});