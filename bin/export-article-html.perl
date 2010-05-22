#!/usr/bin/env perl
#
# Print out html for an article
#

use strict;
use warnings;

sub header {
    my ($title) = @_;
    return <<END_OF_HEAD;
<html>
<head>
    <title>$title</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="Author" content="Tamara De Zotti">
</head>
<body>
<h1>$title</h1>
END_OF_HEAD
}

sub closing {
    return "</body>\n</html>\n";
}

sub wrap_paragraphs {
    my ($html) = @_;

    # Try to put convenience <p/> tags around paragraphs
    my @para = split m{\r?\n\r?\n}, $html;

    for (@para) {
        unless ($_ =~ m{^<p>} && $_ =~ m{</p>\s*$}) {
            $_ =~ s{^\s*}{};
            $_ =~ s{\s*$}{};
            $_ = '<p>' . $_ . '</p>';
        }
    }

    $html = join("\n\n", @para);

    return $html;
}

my $title = $ARGV[0] || 'Untitled';
my $json = q{};

while (<STDIN>) {
    $json .= $_;
}

if (! $json) {
    die "No article json loaded?\n";
}

my $article = JSON::XS->new()->decode($json);

my $title = $article->{title};
my $html = $article->{content};

$html = join "\n",
    header($title),
    wrap_paragraphs($html),
    closing(),
    ;

print $html;

