#!/usr/bin/env perl

use strict;
use lib '../lib';
use BabyDiary::Kid;
use BabyDiary::Chart;
use BabyDiary::Chart::CDC;
use BabyDiary::Chart::WHO;

my @giulia_points = (
    [ 25, 4, 2008, 3.110 ],
    [ 30, 4, 2008, 3.110 ],
    [ 8,  5, 2008, 3.380 ],
    [ 13, 5, 2008, 3.510 ],
    [ 19, 5, 2008, 3.770 ],
    [ 24, 5, 2008, 3.880 ],
    [ 26, 5, 2008, 4.055 ],
    [ 2,  6, 2008, 4.220 ],
    [ 6,  6, 2008, 4.325 ],
    [ 16, 6, 2008, 4.500 ],
    [ 25, 6, 2008, 4.610 ],
    [ 28, 6, 2008, 4.700 ],
    [ 8,  7, 2008, 4.900 ],
    [ 15, 7, 2008, 5.050 ],
    [ 24, 7, 2008, 5.260 ],
    [ 24, 9, 2008, 6.145 ],
);

my @andrea_points = (
    [ 20, 10, 2006, 3.110 ],
    [ 25, 10, 2006, 3.150 ],
    [ 17, 11, 2006, 4.250 ],
    [ 10,  1, 2007, 6.370 ],
    [  2,  2, 2007, 6.820 ],
    [ 23,  2, 2007, 7.140 ],
    [  9,  3, 2007, 7.440 ],
    [ 23,  3, 2007, 7.580 ],
    [ 20,  4, 2007, 8.140 ],
    [ 11,  5, 2007, 8.200 ],
    [ 16,  6, 2007, 9.040 ],
    [ 13,  7, 2007, 9.570 ],
    [ 27,  7, 2007, 9.790 ],
    [ 14,  9, 2007, 10.260 ],
    [ 11,  6, 2008, 13.200 ],
);

my $giulia = BabyDiary::Kid->new(
    name => 'Giulia Streppone',
    birthdate => '25/04/2008',
    color => 'blue',
    gender => 'f',
);

my $andrea = BabyDiary::Kid->new(
    name => 'Andrea Streppone',
    birthdate => '13/10/2006',
    color => 'blue',
    gender => 'm',
);

my $chart = BabyDiary::Chart::WHO->new(
    #kid   => $andrea,
    kid   => $giulia,
    type  => 'wfa',
);

$chart->draw_weight_chart(\@giulia_points);
#$chart->draw_weight_chart(\@andrea_points);

binmode STDOUT;
print $chart->pdf->stringify();

