# $Id$

# Model class to access article slugs on database
package BabyDiary::File::Slugs;

use strict;
use base qw(BabyDiary::File::SQLite);

use constant TABLE  => 'slugs';
use constant FIELDS => [ qw(slug type id state) ];

sub find_id
{
    my ($self, $slug, $type) = @_;

	# Get slug record (if exists)
    my $rec = $self->get({ where => {slug => $slug, type=>$type} });

	if (! $rec) {
		$self->log('notice', 'No article found for slug {' . $slug . '}');
		return;
	}

	my $id = $rec->{id};
	$self->log('notice', "Found $type $id for slug {$slug}");

	return $id;
}

1;

#
# End of class

