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
	my $slug;

	$slugs ||= BabyDiary::File::Slugs->new();
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

	# Prepend date to article slug
	my $model_date = $model->{createdon};
	$model_date =~ s{^(\d+)-(\d+)-(\d+).*$}{$1/$2/$3};
	$slug = $model_date . '/' . Opera::Util::slug($model->{title});

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

