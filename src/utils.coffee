dev = "AI39si5Us3iYwmRdK0wa2Qf2P9eV-Z8tbjogUWw1B4JQUs
191PgYNJChEKEooOq6ykQzhywLEBA9WxuKphpWUoCRA7S7jeLi5w"

now = () -> Math.floor((new Date()).getTime()/1000)
time = (seconds) ->
  minutes = Math.floor(seconds/60);
  mod_seconds = seconds%60+'';
  if (mod_seconds.length != 2) 
    mod_seconds = '0'+mod_seconds;
  minutes+':'+mod_seconds;

get_after = (str,substr,len)->
	loc = str.indexOf substr
	return '' if loc == -1
	return str.substring(loc + substr.length, loc + substr.length + len)

parse_vidid = (str)->
	return get_after str, 'v=', 11 || get_after str, 'youtu.be/', 11

parse_playlist = (str)->
	return if not contains str, 'youtube.com' or not contains str, 'list='
  pos = str.indexOf '&'
  length = 100
  length = pos - str.indexOf 'list=' + 5 if pos > -1
  return get_after str, 'list=', length

info = (vidid, callback)->
  url = "http://gdata.youtube.com/feeds/api/videos/#{ vidid }?v=2&alt=json&"+dev;
  $.get url, (data)->
    callback({
      title: data.entry.title.$t,
      uploader: data.entry.author[0].name.$t,
      duration: parseInt(data.entry.media$group.yt$duration.seconds),
      thumb: data.entry.media$group.media$thumbnail[0].url
    });