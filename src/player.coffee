window.Player = class extends models.view
	constructor: (@_construction)->
		super _construction
		self = this
		window.onYouTubeIframeAPIReady = -> 
			self.player = new YT.Player 'player', {
				height: '480', width: '853',
				events: { 'onStateChange': ->self.onstate() }
			};
		$('head').append('<script src="//www.youtube.com/iframe_api">');
	render: ->
		el = this.get('el')
		el.html('foo')
	onstate: ->
		state = this.player.getPlayerState();
		this.emit 'state', { 
			playing: state is 1
			time: p.player.getCurrentTime()
		}
