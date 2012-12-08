var $ = require('jquery');


utils = {

keys: function(arr){
	var r = [];
	for (a in arr)
		r.push(a);
	return r;
},

yt: {
	info: function(video, callback) {
		var vidid = video.get('vidid');
		var url = 'http://gdata.youtube.com/feeds/api/videos/'+vidid+
			'?v=2&alt=json&key=AI39si5Us3iYwmRdK0wa2Qf2P9eV-Z8tbjogUWw1B4JQUs191PgYNJChEKEooOq6ykQzhywLEBA9WxuKphpWUoCRA7S7jeLi5w';
		$.get(url, function(data){
			video.set({
				title: data.entry.title.$t,
				uploader: data.entry.author[0].name.$t,
				duration: parseInt(data.entry.media$group.yt$duration.seconds),
				thumb: data.entry.media$group.media$thumbnail[0].url
			});
			video.trigger('ready');
		});
	}
},

time: function(seconds){
	var minutes = Math.floor(seconds/60);
	var mod_seconds = seconds%60+'';
	if (mod_seconds.length != 2) mod_seconds = '0'+mod_seconds;
	return minutes+':'+mod_seconds;
},

now: function(){
	return (new Date()).getTime()/1000;
},

remove: function(arr, el) {
	var idx = arr.indexOf(el);
	arr.splice(idx, 1);
}

}
module.exports = utils;