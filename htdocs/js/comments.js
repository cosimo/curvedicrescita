// comments.js - $Id$
function vote(id, delta, type) {
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

function vote_up(comment, type) {
	return vote(comment, 1, type);
}

function vote_down(comment, type) {
	return vote(comment, -1, type);
}

