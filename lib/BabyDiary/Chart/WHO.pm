#
# WHO Specific charts
#
# $Id$

package BabyDiary::Chart::WHO;

use strict;
use base q(BabyDiary::Chart);

# 10.3 points = 1 month
# 34   points = 3 months

sub age_x {
    my ($self, $months) = @_;

    my $base;
    my $max;
    my $points_per_month;

    my $range = $self->range;

    if ($range eq '0_2') {
        $base = 111;
        $max  = 715.5;

        $points_per_month = ($max - $base) / 24;

        if    ($months < 0)  { $months = 0 }
        elsif ($months > 24) { $months = 24 }
    }

    elsif ($range eq '0_5') {

        $base = 111;
        $max  = 715.5;

        $points_per_month = ($max - $base) / 60;

        if    ($months < 0)  { $months = 0 }
        elsif ($months > 60) { $months = 60 }
    }

    return $base + $points_per_month * $months;
}

sub chart_color {
    my ($self) = @_;
    return 'green';
}

sub filename {
    my ($self) = @_;

    # Filename shouldn't change for same instance
    if (exists $self->{filename}) {
        return $self->{filename};
    }

    # Weight for age
    my $type  = $self->type() || 'wfa';

    # Age in days
    my $range = $self->range();
    my $gender = $self->kid->gender() eq 'M' ? 'boys' : 'girls';
    my $file  = sprintf 'charts/who/cht_%s_%s_p_%s.pdf', $type, $gender, $range;

    return $self->{filename} = $file;
}

sub mediabox {
    my ($self) = @_;
    # Landscape A4
    return (0, 0, 842, 595);
}

sub weight_y_girls {
    my ($self, $kgs) = @_;

    my $base;
    my $max;
    my $points_per_kg;

    my $range = $self->range;

    if ($range eq '0_2') {
        $base = 50;
        $max  = 404.5;
        $points_per_kg = ($max - $base) / 13;
        if    ($kgs < 2)  { $kgs = 2 }
        elsif ($kgs > 15) { $kgs = 15 }
    }
    
    elsif ($range eq '0_5') {
        $base = 72;
        $max  = 426.5;
        $points_per_kg = ($max - $base) / 22;
        if    ($kgs < 2)  { $kgs = 2 }
        elsif ($kgs > 24) { $kgs = 24 }
    }

    return ($base + $points_per_kg * $kgs);
}

sub weight_y {
    my ($self, $kgs) = @_;
    my $y;

    if ($self->kid->gender eq 'M') {
        $y = $self->weight_y_boys($kgs);
    }
    else {
        $y = $self->weight_y_girls($kgs);
    }

    return $y;
}

sub weight_y_boys {
    my ($self, $kgs) = @_;

    my $base;
    my $max;
    my $points_per_kg;

    my $range = $self->range;

    if ($range eq '0_2') {
        $base = 54;
        $max  = 408.5;
        $points_per_kg = ($max - $base) / 14;
        if    ($kgs < 2)  { $kgs = 2 }
        elsif ($kgs > 16) { $kgs = 16 }
    }

    elsif ($range eq '0_5') {
        $base = 72;
        $max  = 426.5;
        $points_per_kg = ($max - $base) / 22;
        if    ($kgs < 2)  { $kgs = 2 }
        elsif ($kgs > 24) { $kgs = 24 }
    }

    return ($base + $points_per_kg * $kgs);
}

1;
