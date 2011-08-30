#
# WHO Specific charts
#
# $Id$

package BabyDiary::Chart::CDC;

use strict;
use base q(BabyDiary::Chart);

sub filename {
    my ($self) = @_;

    # Filename shouldn't change for same instance
    if (exists $self->{filename}) {
        return $self->{filename};
    }

    # Weight for age
    my $type  = $self->type() || 'wfa';

    # Age in days
    my $chart = $self->kid->gender() eq 'M' ? 1 : 2;
    my $age   = $self->kid->age();
    $chart += $age <= (2 * 366) ? 0 : 2;
    my $file = sprintf 'charts/cdc/chart%02d.pdf', $chart;

    return $self->{filename} = $file;
}

# 10.3 points = 1 month
# 34   points = 3 months

sub age_x {
    my ($self, $months) = @_;

    my $base = 99.70;
    my $max  = 512.25;

    my $points_per_month = ($max - $base) / 36;

    if    ($months < 0)  { $months = 0 }
    elsif ($months > 36) { $months = 36 }

    return $base + $points_per_month * $months;
}

sub mediabox {
    my ($self) = @_;
    return (0, 0, 595, 842);
}

sub weight_y {
    my ($self, $kgs) = @_;

    my $base = 43;
    my $max  = 698;

    my $points_per_kg = ($max - $base) / 19;

    if    ($kgs < 2)  { $kgs = 2 }
    elsif ($kgs > 19) { $kgs = 19 }

    return $base + $points_per_kg * $kgs;
}

1;
