dev = 'AI39si5Us3iYwmRdK0wa2Qf2P9eV-Z8tbjogUWw1B4JQUs
191PgYNJChEKEooOq6ykQzhywLEBA9WxuKphpWUoCRA7S7jeLi5w'

module.exports = {

random: ->
	s4 = -> Math.floor(Math.random()*0x10000).toString(16);
	return s4() + s4() + s4() + s4()

cookie: (str)->
	dict = {}
	kvs = str.split(';')
	for kv in kvs
		kv = kv.split('=')
		continue if not kv[0] or not kv[1]
		k = kv[0].trim()
		v = kv[1].trim()
		dict[k] = v
	return dict

now: ->
	return Math.round ((new Date()).getTime() / 1000)

yt: {
	info: (vidid)-> 'http://gdata.youtube.com/feeds/api/videos/'+vidid+'?v=2&alt=json&'+dev
}

}