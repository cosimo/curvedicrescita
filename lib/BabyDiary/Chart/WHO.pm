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

    my $base = 111;
    my $max  = 715.5;

    my $points_per_month = ($max - $base) / 24;

    if    ($months < 0)  { $months = 0 }
    elsif ($months > 24) { $months = 24 }

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
    my $age   = $self->kid->age();

    if ($age <= 2 * 365) {
        $age = '0_2';
    }
    else {
        $age = '0_5';
    }

    my $gender = $self->kid->gender() eq 'M' ? 'boys' : 'girls';
    my $file  = sprintf 'charts/who/cht_%s_%s_p_%s.pdf', $type, $gender, $age;

    return $self->{filename} = $file;
}

sub mediabox {
    my ($self) = @_;
    return (0, 0, 842, 595);
}

sub weight_y_girls {
    my ($self, $kgs) = @_;

    my $base = 50;
    my $max  = 404.5;

    my $points_per_kg = ($max - $base) / 13;

    if    ($kgs < 2)  { $kgs = 2 }
    elsif ($kgs > 15) { $kgs = 15 }

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

    my $base = 54;
    my $max  = 408.5;

    my $points_per_kg = ($max - $base) / 14;

    if    ($kgs < 2)  { $kgs = 2 }
    elsif ($kgs > 16) { $kgs = 16 }

    return ($base + $points_per_kg * $kgs);
}

1;
