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

	$content =~ s{<script[^>]*>(.+?)</script>}{}gsim;
	$content =~ s{<style[^>]*>(.+?)</style>}{}gsim;
	$content =~ s{<pre>([^<]+)</pre>}{C<< $1 >>}gsim;
	$content =~ s{<h(\d)>([^<]+)</h\d>}{\n\n=head$1 $2\n\n}gim;

	$content =~ s{<cite>([^<]+)</cite>}{I<< $1 >>}gsim;
	$content =~ s{</?cite>}{}gsim;

	$content =~ s{<br>}{\n}gim;
	$content =~ s{<div[^>]*>}{}gim;
	$content =~ s{</div>}{}gim;

	# Lists
	$content =~ s{<[uo]l>}{\n\n=over 4\n}gim;
	$content =~ s{<li[^>]*>}{\n\n=item\n\n}gim;
	$content =~ s{</li>}{}gim;
	$content =~ s{</[uo]l>}{\n\n=back\n\n}gim;

	$content =~ s{<[bB]>(.+?)</[bB]>}{B<< $1 >>}gsm;
	$content =~ s{<[iI]>(.+?)</[iI]>}{I<< $1 >>}gsm;

	# Blockquotes
	#$content =~ s{<blockquote>}{\n\n  }gim;
	#$content =~ s{</blockquote>}{\n\n}gim;
	$content =~ s/<blockquote>(.*?)<\/blockquote>/my $b=$1; my @l=split m{[\r\n]+},$b; for(@l) { s\/[IBC]<< (.+?) >>\/$1\/g; }; "\n\n  ".join("\n  ",@l)."\n\n";/egsim;

	# Links
	$content =~ s{<a href="(.+?)">(.+?)</a>}{$2 (L<$1>) }gim;

	# Wipe out <img> tags
	$content =~ s{<img[^>]*>}{}gim;

	#my $hs = HTML::Strip->new( striptags => ['script','iframe','img'] );
	#my $cleaned = $hs->parse($content);

	$content =~ s{[\s\n]*$}{};
	$content =~ s{<br>$}{}i;
	$content =~ s{<p>$}{}i;

	print $content;

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
my $title;
my $content;
my $tags;
my $decode = 1;

if ($decode) {
	$title = Encode::decode_utf8($art->{title});
	$content = Encode::decode_utf8($art->{content});
	$tags = Encode::decode_utf8($art->{keywords});
}

my $author = ucfirst $art->{createdby};
if ($author eq 'Tamara') {
	$author = 'Tamara De Zotti, L<info@curvedicrescita.com>';
}
my $url = "http://www.curvedicrescita.com/exec/article/$slug";
my $date = Opera::Util::format_date($art->{createdon});
my $last_modification_date = Opera::Util::format_date($art->{lastmodifiedon} || $art->{createdon});

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

  
  

=head1 Autore

$author

=head1 Pubblicato su

Curve di crescita, L<$url>

=head2 Data prima pubblicazione

$date

=head2 Ultima modifica

$last_modification_date

=end

END_OF_POD

open my $podf, '>', $file;
print {$podf} $pod_content;
close $podf;

my $status = system(
	qq{pod2pdf --title "" --icon "../htdocs/img/title_306_31_pink.gif" } .
	qq{--icon-scale 0.6 --output-file "$file.pdf" --footer-text "$url" } .
	qq{"$file"}
);
$status >>= 8;

if (0 == $status) {
	unlink $file;
}

