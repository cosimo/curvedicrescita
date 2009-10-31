package BabyDiary::File::Role::HasViews;

use strict;

sub total_page_views {
	my ($self) = @_;

	my $total_page_views;
	my $list_sum = $self->list({ fields => 'sum(views) AS total_page_views' });

	if ($list_sum) {
		$total_page_views = $list_sum->[0]->{total_page_views};
	}

	return $total_page_views;
}

1;

