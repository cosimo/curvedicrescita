#!/usr/bin/env perl
#
# Generate a PDF from an article
# 
# $Id$

use strict;
#se warnings;

use lib '../lib';
use BabyDiary::File::Articles;
use Data::Dumper;
use Encode;
use HTML::Strip;
use Opera::Util;

sub massage {
	my ($content) = @_;

	$content =~ s{<[bB]>([^<]+)</[bB]>}{B<$1>}gm;
	$content =~ s{<[iI]>([^<]+)</[iI]>}{I<$1>}gm;
	$content =~ s{<pre>([^<]+)</pre>}{C<$1>}gim;
	$content =~ s{<h(\d)>([^<]+)</h\d>}{\n\n=head$1 $2\n\n}gim;
	$content =~ s{<cite>([^<]+)</cite>}{I<$1>}gim;

	# Wipe out <img> tags
	$content =~ s{<img[^>]*>}{}gim;

	#my $hs = HTML::Strip->new( striptags => ['script','iframe','img'] );
	#my $cleaned = $hs->parse($content);

	return $content;
}

my $articles = BabyDiary::File::Articles->new();
my $article_id = $ARGV[0] || 101;

my $art = $articles->get({ where => { id => $article_id } });
my $slug = $articles->slug($article_id);

#print Dumper($art), "\n";
#
#<STDIN>;

my $file = 'www.curvedicrescita.com';
my $title = Encode::decode_utf8($art->{title});
my $content = Encode::decode_utf8($art->{content});
my $author = ucfirst $art->{createdby};
if ($author eq 'Tamara') {
	$author = 'Tamara De Zotti, L<info@curvedicrescita.com>';
}
my $url = "http://www.curvedicrescita.com/exec/article/$slug";
my $date = Opera::Util::format_date($art->{createdon});
my $tags = Encode::decode_utf8($art->{keywords});

my @tags = split m{\s*,\s*} => $tags;
$tags = join(', ', map { "I<$_>" } @tags);

$content = massage($content);

my $pod_content = <<END_OF_POD;
=pod

=head1 $title

I<$url>

=head1 Tags

$tags

=head1 Contenuto

$content

=head1 Data di pubblicazione

$date

=head1 Autore

$author

=head1 Fonte

CurveDiCrescita.com L<http://www.curvedicrescita.com>

=head1 Indirizzo originale

C<$url>

=end

END_OF_POD

open my $podf, '>', $file;
print {$podf} $pod_content;
close $podf;

my $status = system(
	qq{pod2pdf --title "" --icon "../htdocs/img/title_306_31_pink.gif" } .
	qq{--icon-scale 0.6 --output-file "$file.pdf" "$file"}
);
$status >>= 8;

if (0 == $status) {
	unlink $file;
}

