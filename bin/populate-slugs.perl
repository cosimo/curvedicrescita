#!/usr/bin/env perl

use strict;
use warnings;

use lib '../lib';
use BabyDiary::File::Articles;
use BabyDiary::File::Slugs;
use Opera::Util;

my $art   = BabyDiary::File::Articles->new();
my $slugs = BabyDiary::File::Slugs->new();

my $list = $art->list();

if (! $list) {
	exit;
}

for (@$list) {
	my $article = $_;
	my $id = $article->{id};

	my $slug;
	my $slug_rec = $slugs->get({ where => {type=>'article', id=>$id}} );
	if ($slug_rec) {
		$slug = $slug_rec->{slug};
		print "Article $id already has slug '$slug'\n";
		next;
	}

	my $slug = Opera::Util::slug($article->{title});

	#my $ok = $slugs->insert({slug=>$slug, id=>$id, type=>'article', state=>'A'});
	#
	#if ($ok) {
		print "Article $id now has slug '$slug'\n";
	#}
	#else {
#		print "Failed to add slug for article $id\n";
#	}

}

