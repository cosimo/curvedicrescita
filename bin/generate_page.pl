#!/usr/bin/env perl

use strict;
use lib '../lib';
use BabyDiary::Application;

my $app = BabyDiary::Application->new(
    PARAMS => {cfg_file => '../conf/babydiary.conf'}
);

$app->run();
