# $Id$

package BabyDiary::File::Favorites;

use strict;
use base qw(BabyDiary::File::SQLite);
use Opera::Util;

use constant TABLE  => 'favorites';
use constant FIELDS => [ qw(rtype rid points createdon createdby note) ];

sub check {
	my ($self, $user, $rtype, $rid) = @_;

    # Logged out users can't have favorites
    if (! defined $user || ! $user) {
        return;
    }

	my $fav_status = $self->get({
		where => {
			rtype => $rtype,
			rid => $rid,
			createdby => $user,
		},
		limit => 1
	});

	if (! $fav_status) {
        $self->log('notice', $rtype . '/' . $rid . ' is not faved by ' . $user);
		return;
	}

    $self->log('notice', $rtype . '/' . $rid . ' is faved (' . $fav_status->{points} . 'x) by ' . $user);

	return $fav_status->{points};
}

sub how_many {
	my ($self, $rtype, $rid) = @_;

	my $fav_count = $self->list({
		fields => [ 'count(*)' ],
		where => {
			rtype => $rtype,
			rid => $rid,
		},
	});

	if (! $fav_count) {
		return;
	}

	return $fav_count->[0]->{'count(*)'};
}

sub toggle {
    my ($self, $user, $rtype, $rid, $on) = @_;

	# Find out if the content is already favorited
	my $ok;
	my $fav_status = $self->get({
		where => {
			createdby => $user,
			rtype => $rtype,
			rid => $rid,
		},
		limit => 1,
	});

	# If should be on...
    if ($on) {
		if ($fav_status) {
			$self->log('notice', "Favorite already on for rtype $rtype, rid $rid, user $user");
			$ok = 1;
		}
		else {
			$self->log('notice', "Going to insert as favorite for rtype $rtype, rid $rid, user $user");
			$ok = $self->insert({
				rtype => $rtype,
				rid => $rid,
				createdby => $user,
				createdon => Opera::Util::current_timestamp(),
				points => 1,
			});
		}
	}

	# Should be off...
	else {
		if ($fav_status && $fav_status->{rid} == $rid) {
			$self->log('notice', "Going to delete from favorites for rtype $rtype, rid $rid, user $user");
			$ok = $self->delete({
				rtype => $rtype,
				rid => $rid,
				createdby => $user,
			});
		}
		else {
			$self->log('notice', "Favorite already off for rtype $rtype, rid $rid, user $user");
			$ok = 1;
		}
	}

	$self->log('notice', 'Final favorite result: ' . $ok);

	return $ok;
}

1;

#
# End of class

