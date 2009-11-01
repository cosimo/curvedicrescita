// comments.js - $Id$
function vote(id, delta, type, logged) {

	if (! logged) {
		alert('Per favore, accedi per votare');
		return;
	}

	if (! id) return;
	if (! type) type = 'comment';

	var cid = type + '-' + parseInt(id) + '-rep';
	cid = document.getElementById(cid);
	if (! cid) return;

	var current_rep = parseInt(cid.innerHTML);
	current_rep = current_rep + delta;
	cid.innerHTML = current_rep;

	return false;
}

function vote_up(id, type, logged) {
	return vote(id, 1, type, logged);
}

function vote_down(id, type, logged) {
	return vote(id, -1, type, logged);
}

function vote_favorite(id, type, logged) {
	if (! logged) {
		alert('Per favore, accedi per marcare come favorito');
		return;
	}

	if (! id) return;
	if (! type) type = 'comment';

	var fid = type + '-' + parseInt(id) + '-fav';
	fid = document.getElementById(fid);
	if (! fid) return;

	var is_fave = fid.innerHTML.match(/favorite\-on/) ? 1 : 0;
	var new_state = is_fave ? 'off' : 'on';

	alert('fave new state:'+new_state);
	
	return;
}

