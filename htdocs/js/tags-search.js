// Inline DOM tag filtering - $Id: tags-search.js 186 2009-03-08 16:35:47Z cosimo $

function tags_filter () {

	var field = document.getElementById('tags-search');
	if (! field) return;

	var text = field.value;
	var tags = document.getElementsByTagName('li');

	for (i in tags) {
		var tag = tags[i];
		var cls = tag.className;
		if (cls != 'tagcell') continue;
		if (! tag.hasChildNodes()) continue;
		// Don't use childNodes() because IE counts them in a different way
		var node = tag.getElementsByTagName('span')[0];
		node = node.getElementsByTagName('a')[0];
		var tag_name = get_text(node);             // anchor text
		tag_name = tag_name.toLowerCase();
		if (tag_name.indexOf(text.toLowerCase()) == -1) {
			tag.style.display='none';
		} else {
			tag.style.display='inline';
		}
	}

	return;
}

function get_text(node) {
	if (! node) return;
	var text;
	var type = node.nodeType;
	if (type === 1) {
		if (node.hasChildNodes()) {
			text = node.firstChild.nodeValue;
		}
	}
	else if (type === 3) {
		text = node.nodeValue;
	}
	return text;
}

add_event('keyup', tags_filter);
document.getElementById('tags-search').focus();

