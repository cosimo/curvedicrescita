# $Id$

package BabyDiary::Application::Diary;

use strict;
use BabyDiary::File::Users;

sub start {
    my ($self) = @_;
    #my $query = $self->query();

	my $tmpl = $self->render_view();
	return $tmpl->output();
}

1;

#
# End of class

=pod

=head1 NAME

BabyDiary::Application::Diary - Controller tasks related to Diary section

=head1 SYNOPSIS

Not to be used directly. Is used by main BabyDiary::Application class.

=head1 DESCRIPTION

Contains runmode methods related to Diary section, like user creation,
record view, modify and delete and users search.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
