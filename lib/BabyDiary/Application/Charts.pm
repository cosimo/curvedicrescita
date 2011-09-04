package BabyDiary::Application::Charts;

use strict;
use base q(BabyDiary::Application);
use BabyDiary::File::Babies;
use Carp ();

# Just load user/charts.html template
sub input_basicdata {
    my ($self) = @_;

	my $tmpl = $self->render_view('user/charts.html');
    $tmpl->param(
        menu_charts => 1,
        submenu_charts => 1
    );

	return $tmpl->output();
}

sub input_measures {
    my ($self) = @_;

    # Collect parameters from "input_basicdata" phase
    my $args = $self->query->Vars;

    $args->{name} ||= 'Anonimo';
    
    $args->{chart_type} = $self->validate_chart_type($args->{chart_type});
    $args->{type_as_word} = $self->chart_type_as_word($args->{chart_type});
    $args->{unit} = $self->measure_unit($args->{chart_type});

    my $tmpl = $self->render_view('user/charts/measures.html');
    $tmpl->param(
        menu_charts => 1,
        submenu_charts => 1,
        %{ $args || {} },
    );

    return $tmpl->output();
}

sub chart_type_as_word {
    my ($self, $type) = @_;

    # Associate chart type to a word to generate the chart title
    my %chart_types = (
        wfa => 'peso',
        hfa => 'altezza',
        chfa => 'circonferenza cranica',
    );

    if (! exists $chart_types{$type}) {
        Carp::croak("Non existent chart type '$type'");
    }

    return $chart_types{$type};
}

sub measure_unit {
    my ($self, $chart_type) = @_;

    if ($chart_type eq 'wfa') {
        return 'Kg';
    }
    elsif ($chart_type eq 'hfa') {
        return 'cm';
    }
    elsif ($chart_type eq 'chfa') {
        return 'cm';
    }
    else {
        return 'Kg';
    }
}

sub validate_chart_type {
    my ($self, $type) = @_;

    if (! $type || ($type ne 'wfa' && $type ne 'hfa' && $type ne 'chfa')) {
        $type = 'wfa';
    }

    return $type;
}

1;

