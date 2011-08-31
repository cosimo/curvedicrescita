package BabyDiary::Application::UserPage;

use strict;
use base q(BabyDiary::Application);
use BabyDiary::File::Babies;

sub charts {
    my ($self) = @_;
    return $self->section('charts');
}

sub main {
    my ($self) = @_;

    my $template = qq(user/main.html);
	my $tmpl = $self->render_view($template);

    # Enable main section of the submenu
    $tmpl->param( submenu_main => 1 );

    # Load list of babies
    if (my $babies = $self->user_babies()) {
        $tmpl->param( babies => $babies );
    }

    return $tmpl->output();
}

sub section {
    my ($self, $section) = @_;
	my $tmpl = $self->render_view(qq(user/$section.html));
    $tmpl->param(
        menu_charts => 1,
        "submenu_$section" => 1
    );
	return $tmpl->output();
}

sub user_babies {
    my ($self) = @_;

    # No logged in user, no babies
    my $user = $self->session->param('user');
    if (! $user) {
        $self->log('debug', 'User not logged in. No babies to be found');
        return;
    }

    my $babies = BabyDiary::File::Babies->new();
    my $list = $babies->list({
        # parent1 = ? OR parent2 = ?
        where => [
            { parent1 => $user },
            { parent2 => $user },
        ],
    });

    if ($list && ref $list eq 'ARRAY') {
        $self->log('notice', 'Found ' . scalar(@$list) . ' babies');
    }

    return $list;
}

sub new_baby {
    my ($self) = @_;

    # No logged in user, no babies
    my $user = $self->session->param('user');
    if (! $user) {
        $self->log('debug', 'User not logged in. Can\'t add babies.');
        return;
    }
	
    my $tmpl = $self->render_view('user/baby/new.html');
    $tmpl->param(submenu_main => 1);
    return $tmpl->output();
}

1;

