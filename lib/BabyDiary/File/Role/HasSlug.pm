#
# $Id$
#
# Requires model to have:
# - 'id', 'title', 'createdon' fields
# - type() method
#

package BabyDiary::File::Role::HasSlug;

use strict;
use BabyDiary::File::Slugs;
use Opera::Util;

our $slugs;

sub add_slug {
	my ($self, $model) = @_;

	# Check if article already has a slug
	my $id = $model->{id};

	# Or if it was passed in the model hashref
	my $slug = $model->{slug} || q{};

	$slugs ||= BabyDiary::File::Slugs->new();

	if (! $slug) {
		my $slug_rec = $slugs->get({
			where => {
				type=>$self->type(),
				id=>$id
			}
		});

		if ($slug_rec) {
			$slug = $slug_rec->{slug};
			return $slug;
		}

		# Passing the date will automatically prepend it to the slug
		$slug = Opera::Util::slug($model->{title}, $model->{createdon});

	}

	$self->log('notice', 'Adding slug to model ' . (ref $self));

	my $ok = $slugs->insert_or_replace(
		{
			slug  => $slug,
			id    => $id,
			type  => $self->type(),
			state => 'A'
		},
		{
			id => $id,
			type => $self->type(),
		}
	);

	$self->log('notice', 'Added slug {' . $slug . '} => ' . $ok);

	return $ok ? $slug : undef;
}

# Overriden to delete the slug
sub delete {
	my ($self, $where) = @_;

	my $deleted = $self->SUPER::delete($where);
	my $type = $self->type();

	if ($deleted && $where->{id} ) {
		$self->log('notice', ucfirst($type) . $where->{id} . ' deleted. Delete slug.');
		$slugs ||= BabyDiary::File::Slugs->new();
		my $deleted = $slugs->delete({
			type => $type,
			id   => $where->{id},
		});
	}

	return $deleted;
}

sub slug {
	my ($self, $id) = @_;
	$slugs ||= BabyDiary::File::Slugs->new();
	my $slug_rec = $slugs->get({
		where => {
			type=>$self->type(),
			id=>$id
		}
	});
	if (! $slug_rec) {
		return;
	}
	return $slug_rec->{slug};
}

1;

