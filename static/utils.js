function now() { return Math.floor((new Date()).getTime()/1000) }

function get_after(str, substr, len) {
	var loc = str.indexOf(substr);
	if (loc == -1) return '';
	return str.substring(loc + substr.length, loc + substr.length + len);
}

function parse_vidid(str) {
	return get_after(str, 'v=', 11) || get_after(str, 'youtu.be/', 11);
}

function parse_playlist(str) {
	if (!contains(str, 'youtube.com') || !contains(str, 'list=')) return;
	var amppos = str.indexOf('&');
	var length = 100;
	if (amppos > -1)
		length = amppos - (str.indexOf('list=')+5);
	return get_after(str, 'list=', length);
}