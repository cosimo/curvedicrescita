#!/usr/bin/perl
#!c:\dev\perl510\bin\perl.exe

# ==============================================================
# Deploy last source code tree to live installation
# 
# Usage: deploy-live.perl
#
# $Id: copy-live.perl 179 2009-02-28 14:39:52Z cosimo $
# ==============================================================

BEGIN {
    # Unbuffer stdout to make results appear as soon as possible
    $| = 1;
}

use strict;
use warnings;
use lib 'lib';
use Getopt::Long;
use BabyDiary::Deploy;

BabyDiary::Deploy::new_revision();

my $result = BabyDiary::Deploy::launch_missiles();

if ($result) {
	print "Deployment succeeded!\n";
}
else {
	print "Deployment *FAILED* OMG\n";
}

