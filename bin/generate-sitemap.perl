#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';
use BabyDiary::File::Articles;
use Config::Auto;
use Data::Dumper;

my $conf = Config::Auto::parse('../conf/babydiary.conf');
my $log = Opera::Logger->new();

$log->notice('Generating the sitemap');

my $base_url = $conf->{root_uri};
my $priority = '0.9';

my $art = BabyDiary::File::Articles->new();
my $list = $art->list({ orderby => 'id' });

print "#\n";
print "# $base_url Google Sitemap\n";
print "#\n";
print "# Last updated on: " . localtime() . "\n";
print "#\n\n";

print "#\n";
print "# Site articles\n";
print "#\n";

for (@$list) {
	my $art_url  = $base_url . 'exec/home/article/?id=' . $_->{id};

	my $last_mod = $_->{lastupdateon} || $_->{createdon};
	$last_mod =~ s{^ (\d+ \- \d+ \- \d+) \s+ (\d+ : \d+ : \d+) $}{$1T$2+0100}x;

	my $change_freq = "monthly";
	print
		$art_url,
		' lastmod=', $last_mod,
		' changefreq=', $change_freq,
		' priority=', $priority, "\n";
}

