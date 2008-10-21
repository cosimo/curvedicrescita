#!/usr/bin/env perl

use strict;
use warnings;
use File::Slurp ();
use HTML::BBCode ();

my $file = File::Slurp::read_file($ARGV[0]) or die "Can't read file $ARGV[0]: $!";
my $bbc = HTML::BBCode->new({ stripscripts => 1, linebreaks => 1 });
my $html = $bbc->parse($file);

print $html;
