#
# Google Sitemap generator
#
# TODO Add support for questions
#
# $Id$

package BabyDiary::Sitemap;

use strict;
use warnings;
use CGI;
use Config::Auto;

use BabyDiary::Application::Search;
use BabyDiary::File::Articles;
use BabyDiary::File::Questions;
use BabyDiary::File::Slugs;
use Opera::Util;

sub generate {

	my $conf = Config::Auto::parse('../conf/babydiary.conf');
	my $log = Opera::Logger->new();

	$log->notice('Generating the sitemap');

	my $base_url = $conf->{root_uri};

	my $art = BabyDiary::File::Articles->new();
	my $list = $art->list({
		where => { published => {'<>', 0} },
		order => 'id DESC'
	});

	print
		"#\n",
		"# $base_url Google Sitemap\n",
		"#\n",
		"# Last updated on: " . localtime() . "\n",
		"#\n\n",
		"\n",
		;

	print
		"#\n",
		"# Front-page\n",
		"#\n";

	my $fp_article = $list->[0];
	my $fp_lastmod = $fp_article->{lastupdateon} || $fp_article->{createdon};
	$fp_lastmod = Opera::Util::format_date_iso8601($fp_lastmod);

	print $base_url, ' changefreq=daily lastmod=', $fp_lastmod, ' priority=1.0', "\n";
	print $base_url, 'exec/home changefreq=daily lastmod=', $fp_lastmod, ' priority=1.0', "\n";

	print "\n#\n# RSS feed\n#\n";
	print $base_url, 'exec/rss changefreq=daily priority=0.8', "\n";

	print "\n#\n# Diary/curves page\n#\n";
	print $base_url, 'exec/home/diary changefreq=weekly priority=0.7', "\n";

	print "\n#\n# Signup page\n#\n";
	print $base_url, 'exec/home/signup changefreq=monthly priority=0.2', "\n";

	print "\n#\n# Tags page\n#\n";
	print $base_url, 'exec/home/tags changefreq=weekly priority=0.75', "\n";

	print
		"\n#\n",
		"# Articles\n",
		"#\n",
		;

	# Most recent 30 articles have more priority
	my $n_art = 30;

	for (@$list) {

		my $art_url  = $art->url($_->{id});
		$art_url =~ s{^/}{};
		$art_url = $base_url . $art_url;

		my $last_mod = $_->{lastupdateon} || $_->{createdon};
		$last_mod = Opera::Util::format_date_iso8601($last_mod);

		my $priority = 0.95;
		if ($_->{views} > 1000) {
			$priority = 0.7;
		} elsif ($_->{views} > 500) {
			$priority = 0.8;
		} elsif ($_->{views} > 100) {
			$priority = 0.9;
		}

		if ($n_art-- > 0) {
			$priority += 1.0;
			$priority = 0.99 if $priority >= 1.0;
		}

		my $change_freq = "monthly";
		printf "%s lastmod=%s changefreq=%s priority=%1.2f\n",
			$art_url, $last_mod, $change_freq, $priority;

	}

	print "\n";
	print "#\n";
	print "# Tag-based searches\n";
	print "#\n";

	my $tags = BabyDiary::Application::Search::all_tags_frequency();

	for (sort keys %{ $tags }) {
		my $tag_url  = $base_url . 'exec/home/search/?keyword=' . CGI::escape($_);
		my $priority = 0.5;
		my $hits = $tags->{$_};

		if ($hits > 25) {
			$priority = 0.9;
		} elsif ($hits > 15) {
			$priority = 0.8;	
		} elsif ($hits > 5) {
			$priority = 0.7;
		}

		print $tag_url, ' changefreq=weekly priority=', $priority, "\n";
	}

	print "\n";
	print "#\n";
	print "# Latest questions page\n";
	print "#\n";
	print $base_url, 'exec/question/latest changefreq=weekly priority=0.95', "\n";

	print "\n";
	print "#\n";
	print "# Questions\n";
	print "#\n";

	my $questions = BabyDiary::File::Questions->new();
	$list = $questions->list({
		where => { published => {'<>', 0} },
		order => 'id DESC'
	});

	my $n_questions = 30;

	for (@$list) {

		my $q_url  = $questions->url($_->{id});

		$q_url =~ s{^/}{};
		$q_url = $base_url . $q_url ;

		my $last_mod = $_->{lastupdateon} || $_->{createdon};
		$last_mod = Opera::Util::format_date_iso8601($last_mod);

		my $priority = 0.95;
		if ($_->{views} > 1000) {
			$priority = 0.5;
		} elsif ($_->{views} > 500) {
			$priority = 0.6;
		} elsif ($_->{views} > 100) {
			$priority = 0.8;
		}

		if ($n_questions-- > 0) {
			$priority += 1.0;
			$priority = 0.99 if $priority >= 1.0;
		}

		my $change_freq = "weekly";
		printf "%s lastmod=%s changefreq=%s priority=%1.2f\n",
			$q_url, $last_mod, $change_freq, $priority;

	}

	return;
}

1;
