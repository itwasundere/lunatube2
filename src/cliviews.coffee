window.views = {
	message: (info)-> 
		window.msg = this
		this.user = lookup info.user, 'user'
		this.temp = _.template($('script#message').html())
		self = this
		this.user.bind 'changed', -> self.render()
		this.render = ->
			inner = self.temp({
				username: self.user.get 'username'
				content: info.text
			})
			self.el.html $ inner
		this.el = $ this.temp {
			username: self.user.get 'username'
			content: info.text
		}
		return this
}