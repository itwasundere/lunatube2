sparkle = require './sparkle'
models = sparkle.models
utils = require './utils'
now = utils.now
$ = require 'jquery'

models.video.extend {
	'cons': ->
		return if not this.get 'vidid'
		url = utils.yt.info this.get 'vidid'
		video = this
		console.log url
		$.get url, (data)->
			video.set 'title', data.entry.title.$t
			video.set 'uploader', data.entry.author[0].name.$t
			video.set 'duration', (data.entry.media$group.yt$duration.seconds)
			video.set 'thumb', data.entry.media$group.media$thumbnail[0].url
}

models.room.extend {
	'cons': ->
		this.set 'state', 'paused'
		this.elapsed = 0
	'play': ->
		this.elapsed = 0
		this.start = now()
		this.set 'state', 'playing'
	'pause': ->
		this.elapsed = now() - this.start
		this.set 'state', 'paused'
	'seek': (time)->
		this.start = now()
		this.elapsed = time
	'state': ->
		return { 
			time: this.time()
			current: this.get 'current'
			state: this.get 'state'
		}
	'time': ->
		if this.get('state') is 'playing'
			return now() - this.start + this.elapsed
		if this.get('state') is 'paused'
			return this.elapsed
}

sparkle.load()

module.exports = {
	models: models
	dump: sparkle.dump
	lookup: sparkle.lookup
}