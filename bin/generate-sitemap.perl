#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';
use BabyDiary::File::Articles;
use CGI;
use Config::Auto;

my $conf = Config::Auto::parse('../conf/babydiary.conf');
my $log = Opera::Logger->new();

$log->notice('Generating the sitemap');

my $base_url = $conf->{root_uri};

my $art = BabyDiary::File::Articles->new();
my $list = $art->list({ order => 'id DESC' });
my %tags = $art->tags_frequency();

print "#\n";
print "# $base_url Google Sitemap\n";
print "#\n";
print "# Last updated on: " . localtime() . "\n";
print "#\n\n";

print "#\n";
print "# Site articles\n";
print "#\n";

# Most recent 30 articles have more priority
my $n_art = 30;

for (@$list) {
	my $art_url  = $base_url . 'exec/home/article/?id=' . $_->{id};

	my $last_mod = $_->{lastupdateon} || $_->{createdon};
	$last_mod =~ s{^ (\d+ \- \d+ \- \d+) \s+ (\d+ : \d+ : \d+) $}{$1T$2+01:00}x;

	my $priority = 0.7;
	if ($_->{views} > 1000) {
		$priority = 0.95;
	} elsif ($_->{views} > 500) {
		$priority = 0.85;
	} elsif ($_->{views} > 100) {
		$priority = 0.8;
	}

	if ($n_art-- > 0) {
		$priority += 1.0;
		$priority = 0.99 if $priority >= 1.0;
	}

	my $change_freq = "monthly";
	printf "%s lastmod=%s changefreq=%s priority=%1.2f\n",
		$art_url, $last_mod, $change_freq, $priority;

}

print "#\n";
print "# Tags\n";
print "#\n";

for (sort keys %tags) {
	my $tag_url  = $base_url . 'exec/home/article_search/?keyword=' . CGI::escape($_);
	my $priority = 0.5;
	my $hits = $tags{$_};

	if ($hits > 50) {
		$priority = 0.9;
	} elsif ($hits > 25) {
		$priority = 0.8;	
	} elsif ($hits > 10) {
		$priority = 0.7;
	}

	print $tag_url, ' changefreq=weekly priority=', $priority, "\n";
}

