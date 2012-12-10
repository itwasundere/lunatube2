if (typeof window != "undefined")
  globals = window || module.exports
else
  globals = module.exports
  crypto = require 'crypto'


dev = "AI39si5Us3iYwmRdK0wa2Qf2P9eV-Z8tbjogUWw1B4JQUs
191PgYNJChEKEooOq6ykQzhywLEBA9WxuKphpWUoCRA7S7jeLi5w"

globals.now = () -> Math.floor((new Date()).getTime()/1000)
globals.time = (seconds) ->
  minutes = Math.floor(seconds/60);
  mod_seconds = seconds%60+'';
  if (mod_seconds.length != 2) 
    mod_seconds = '0'+mod_seconds;
  minutes+':'+mod_seconds;

globals.get_cookie = (k) ->
  c = document.cookie
  for val in c.split ';'
    idx = c.indexOf '='
    key = val.substr 0, idx
    return val.substr idx+1 if `key == k`

globals.set_cookie = (k,v) ->
  document.cookie = k+'='+v

globals.get_after = (str,substr,len)->
	loc = str.indexOf substr
	return '' if loc == -1
	return str.substring(loc + substr.length, loc + substr.length + len)

globals.parse_vidid = (str)->
	return get_after str, 'v=', 11 || get_after str, 'youtu.be/', 11

globals.parse_playlist = (str)->
	return if not contains str, 'youtube.com' or not contains str, 'list='
  pos = str.indexOf '&'
  length = 100
  length = pos - str.indexOf 'list=' + 5 if pos > -1
  return get_after str, 'list=', length

globals.info = (vidid, callback)->
  url = "http://gdata.youtube.com/feeds/api/videos/#{ vidid }?v=2&alt=json&"+dev;
  $.get url, (data)->
    callback({
      title: data.entry.title.$t,
      uploader: data.entry.author[0].name.$t,
      duration: parseInt(data.entry.media$group.yt$duration.seconds),
      thumb: data.entry.media$group.media$thumbnail[0].url
    });

globals.get_roomid = (location)->
  if (!location.substr(0,3)=='/r/')
    console.error('not in room');
  location.substr(3,location.length)

globals.random = -> crypto.randomBytes(8).toString('hex')

globals.delay = (time, fn)-> setTimeout fn, time

globals.in = (needle, haystack)->
  for el in haystack
    return true if `needle == el`

gates = {}
globals.gate = (key, user, timeout)->
  timeout = 100 if not timeout
  gates[key] = {} if not gates[key]
  return true if gates[key][user]
  gates[key][user] = 1
  globals.delay timeout, -> gates[key][user]=0
  return false