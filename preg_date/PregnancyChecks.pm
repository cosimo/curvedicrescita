#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use DateTime;
use Date::Pregnancy ();

our @CHECKS;

sub birthdate {
	my ($day, $month, $year) = @_;

	my $dt = DateTime->new(
		year  => $year,
		month => $month,
		day   => $day,
	);

	return Date::Pregnancy::calculate_birthday(first_day_of_last_period => $dt);

}

sub current_week {
	my ($day, $month, $year) = @_;

	my $dt = DateTime->new(
		year  => $year,
		month => $month,
		day   => $day,
	);
	my $week = Date::Pregnancy::calculate_week(
		first_day_of_last_period => $dt,
	);
	return $week;
}

sub week_at_date {
	my ($day_dlp, $month_dlp, $year_dlp, $day, $month, $year) = @_;

	my $date = DateTime->new(
		day => $day,
		month => $month,
		year => $year,
	);

	my $dlp = DateTime->new(
		day => $day_dlp,
		month => $month_dlp,
		year => $year_dlp,
	);

	my $week = Date::Pregnancy::calculate_week(
		first_day_of_last_period => $dlp,
		date => $date,
	);

	return $week;
}

sub all_checks {

	if (@CHECKS) {
		return @CHECKS;
	}

	@CHECKS = (

		# --- Trimester 1 ---

		{
			name_it => 'Controllo genetico',
			week_start => 4,
			week_end => 7,
			mandatory => 0,
			trimester => 1,
		},

		{
			name_it => 'Primo appuntamento con il ginecologo',
			week_start => 8,
			week_end => 12,
			mandatory => 1,
			trimester => 1,
		},

		{
			name_it => 'Villocentesi',
			week_start => 10,
			week_end => 12,
			mandatory => 0,
			trimester => 1,
		},

		{
			name_it => 'Ecografia primo trimestre',
			week_start => '11w4d',
			week_end => '12w2d',
			mandatory => 1,
			trimester => 1,
		},

		{
			name_it => 'Translucenza nucale',
			week_start => '11w4d',
			week_end => '12w2d',
			mandatory => 0,
			trimester => 1,
		},

		{
			name_it => 'Bi-test',
			week_start => '11w4d',
			week_end => '12w2d',
			mandatory => 0,
			trimester => 1,
		},

		# --- Trimester 2 ---

		{
			name_it => 'Secondo appuntamento con il ginecologo',
			trimester => 2,
			week_start => 13,
			week_end => 18,
			mandatory => 1,
		},

		{
			name_it => 'Amniocentesi',
			trimester => 2,
			week_start => 16,
			week_end => 18,
			mandatory => 0,
		},

		{
			name_it => 'Terzo appuntamento con il ginecologo',
			trimester => 2,
			week_start => 19,
			week_end => 22,
			mandatory => 1,
		},

		{
			name_it => 'Ecografia del secondo trimestre',
			trimester => 2,
			week_start => 19,
			week_end => 22,
			mandatory => 1,
		},

		# --- Trimester 3 ---

		{
			name_it => 'Quarto appuntamento con il ginecologo',
			trimester => 3,
			week_start => 23,
			week_end => 28,
			mandatory => 1,
		},

		{
			name_it => 'Corso di preparazione al parto',
			trimester => 3,
			week_start => 24,
			week_end => 28,
			mandatory => 0,
		},

		{
			name_it => 'Quinto appuntamento con il ginecologo',
			trimester => 3,
			week_start => 29,
			week_end => 32,
			mandatory => 1,
		},

		{
			name_it => 'Ecografia del terzo trimestre',
			trimester => 3,
			week_start => 30,
			week_end => 32,
			mandatory => 1,
		},

		{
			name_it => 'Sesto appuntamento con il ginecologo',
			trimester => 3,
			week_start => 33,
			week_end => 38,
			mandatory => 1,
		},

		{
			name_it => 'Tampone vaginale e rettale',
			trimester => 3,
			week_start => 35,
			week_end => 37,
			mandatory => 1,
		},

		{
			name_it => 'Settimo appuntamento con il ginecologo',
			trimester => 3,
			week_start => 39,
			week_end => 39,
			mandatory => 1,
		},

		{
			name_it => 'Ottavo appuntamento con il ginecologo',
			trimester => 3,
			week_start => 40,
			week_end => 40,
			mandatory => 1,
		},

		{
			name_it => 'Ecofalda',
			trimester => 3,
			week_start => 41,
			week_end => 41,
			mandatory => 1,
		},

		{
			name_it => 'Cardiotocografia',
			trimester => 3,
			week_start => 41,
			week_end => 41,
			mandatory => 1,
		},

		{
			name_it => 'Nono appuntamento con il ginecologo',
			trimester => 3,
			week_start => 41,
			week_end => 41,
			mandatory => 1,
		}

	);

	return @CHECKS;

}

sub checks_at_week {

	my ($week) = @_;

	my @checks = all_checks();
	my @todo;

	for my $check (@checks) {

		my $week_start = $check->{week_start};
		my $week_end   = $check->{week_end};

		# Round to start of week for start date
		if ($week_start =~ m{^(\d+)w(\d+)d$}) {
			#$week_start = $1 + $2 * 1/7;
			$week_start = $1;
		}

		# Round to next week for end date
		if ($week_end =~ m{^(\d+)w(\d+)d$}) {
			#$week_end = $1 + $2 * 1/7;
			$week_end = $1 + 1;
		}

		if ($week >= $week_start && $week <= $week_end) {
			push @todo, $check;
		}

	}

	return @todo;

}

sub as_ical {

    require Data::ICal;
    require Data::ICal::Entry::Event;
    require Date::ICal;

    my @checks = all_checks();
    my $calendar = Data::ICal->new();
    my $main_url = 'http://www.curvedicrescita.com/exec/article/2010/01/02/appuntamenti-visite-gravidanza';

    while (my $next_event = shift @checks) {
        my $ical_event = Data::ICal::Entry::Event->new();
        $next_event->{url} ||= '/pregnancy/week/' . $next_event->{week_start};
        $ical_event->add_properties(
            status   => 'INCOMPLETE',
            summary  => $next_event->{name_it},
            priority => $next_event->{mandatory} ? 4 : 5,
            dtstart  => ical_date(time, $next_event->{week_start}),
            dtend    => ical_date(time, $next_event->{week_end}, 1),
            url      => $main_url,
        );
        $calendar->add_entry($ical_event);
    }

    print $calendar->as_string();
}

sub ical_date {
    my ($start, $plus_weeks, $end_of_week) = @_;

    my $start_secs = $start + 0;

    # Weeks/days (4w3d)
    if ($plus_weeks =~ m{^(\d+)w(\d+)d$}) {
        $plus_weeks = $2 + 7 * $1;
    }
    else { # Plain weeks number
        $plus_weeks *= 7;
    }

    $plus_weeks *= 86400;

    if ($end_of_week) {
        $plus_weeks += 86400 * 7 - 1;
    }

    $start_secs += $plus_weeks;

    my $ical_date = Date::ICal->new(epoch => $start_secs)->ical;
    return $ical_date;

}

1;

# vim: set ts=4 sw=4 tw=0 et
