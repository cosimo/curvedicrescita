# $Id$

# View class. Contains methods to visually present information to user.
package BabyDiary::View::Articles;

use strict;
use CGI ();
use HTML::BBCode;
use HTML::Strip;
use BabyDiary::File::Articles;

#
# Format and display article content
#
sub format_article
{
    my($art) = @_;
    my $content = $art->{content};
   
    $content =~ s{\r?\n\r?\n}{<br/><br/>}g;

	my @words = Opera::Util::search_url_terms();
	for (@words) {
		Opera::Util::highlight_term($_, \$content);
	}

    #my $bbc = HTML::BBCode->new({
    #    stripscripts => 1,
    #    linebreaks => 1,
    #});
    #
    #$content = $bbc->parse($content);

    return($content);
}

#
# Display article excerpt in search results screen
# Displays only first 2 lines of content.
#
sub format_article_excerpt
{
    my($art) = @_;

    # Take first two lines of the article
    my $content = $art->{content};

    my $html_stripper = HTML::Strip->new();
    $content = $html_stripper->parse($content);

    my @lines = split /\r?\n/, $content;
    my @excerpt;

    my $chars = 0;
    for (@lines) {
        push @excerpt, $_;
        $chars += length;
        last if $chars > 80;
    }

    # Add dots `...' to denote continued content
    $excerpt[$#excerpt] .= ' ...';

    # Return the first two lines as excerpt
    $content = join("\r\n", @excerpt);

	# Highlight html links?
	#$content =~ s{(http://\S+\b)}{<a href="$1">$1</a>}g;

    return($content);
}

#
# Display article author name as link to my.opera.com profile
#
sub format_author
{
    my($art, $key) = @_;
    my $name = '';
    $key ||= 'createdby';

    if(exists $art->{$key} && $art->{$key} ne '')
    {
        $name = CGI->a({href=>'/exec/home/user/' . CGI::escape($art->{$key}) }, $art->{$key});
    }

    return($name);
}

#
# Keywords appear each with a link to search for that keyword
#
sub format_keywords
{
    my($art) = @_;

    # Separate keywords
    my @kwords = split m{\s* , \s*}x => $art->{keywords};

    # Every keyword becomes an anchor to search by *that* keyword
    for(@kwords)
    {
        $_ = CGI->a({
            href=>'/exec/home/article_search/?keyword=' . CGI::escape($_)
        }, $_);
    }

    # Finally return the concatenation of those anchors
    return join(' ', @kwords);
}

#
# Title of article has link to display the single article
#
sub format_title
{
    my($art) = @_;
    return $art->{title};
}

#
# Title of article has link to display the single article
#
{

    my $articles;

    sub format_title_link
    {
        my ($art) = @_;
        my $slug;
        my $title;

        if (exists $art->{slug}) {
            $slug = $art->{slug};
        } else {
            $articles ||= BabyDiary::File::Articles->new();
            $slug = $articles->slug($art->{id});
        }

        if ($slug) {
            $title = CGI->a({href=>'/exec/article/' . $slug}, $art->{title});
        }
        else {
            $title = CGI->a({href=>'/exec/home/article/?id=' . CGI::escape($art->{id})}, $art->{title});
        }

        return($title);
    }

}

1;

#
# End of class

=head1 NAME

Opera::View::Articles - Visually present information about articles to user.

=head1 SYNOPSIS

    my %article = (
        title     => 'My totally new article',
        content   => 'Bla bla bla',
        createdby => 'cosimo',
        # ...
    );

    print Opera::View::Articles::format_author(\%article);
    print Opera::View::Articles::format_title(\%article);
    # ...

=head1 FUNCTIONS

Each "format_*" function accepts a full articles record (as hashref)
and outputs (x)html code visually present information, such as article
author or title, to final user.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
