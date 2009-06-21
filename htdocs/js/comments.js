// comments.js $Id$
function vote(comment, delta) {
	if (! comment) return;
	var cid = 'comment-' + parseInt(comment) + '-rep';
	cid = document.getElementById(cid);
	if (! cid) return;
	var current_rep = parseInt(cid.innerHTML);
	current_rep = current_rep + delta;
	cid.innerHTML = current_rep;
	return false;
}

function vote_up(comment) {
	return vote(comment, 1);
}

function vote_down(comment) {
	return vote(comment, -1);
}

