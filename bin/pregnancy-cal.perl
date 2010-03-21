#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';
use BabyDiary::Application::Pregnancy;

my $day = $ARGV[0] || 1;
my $month = $ARGV[1] || 1;
my $year = $ARGV[2] || 2010;

print BabyDiary::Application::Pregnancy::ical($day, $month, $year);

