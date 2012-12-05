module.exports = {
	user: {
		username: String,
		password: String,
		avatar: String
	},
	room: {
		current: String,
		owner: String,
		userlist: Array,
		modlist: Array,
		mutelist: Array,
		playlist: String
	},
	video: {
		duration: Number,
		vidid: String,
		title: String,
		uploader: String,
		duration: Number,
		thumb: String,
		playlist: String
	}
}