# $Id: Articles.pm,v 1.3 2007/06/05 21:55:15 cosimo Exp $

# View class. Contains methods to visually present information to user.
package Opera::View::Articles;

#
# Format and display article content
#
sub format_article
{
    my($art) = @_;
    my $content = $art->{content};
    $content =~ s{\r?\n}{<br/>}g;
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
    my @lines = split /\r?\n/, $content;
    splice(@lines, 2);

    # Add dots `...' to denote continued content
    $lines[1] .= ' ...';

    # Return the first two lines as excerpt
    $content = join("\r\n", @lines);
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
        my $img = '/MyOperaTest/graphics/avatar2.gif';
        if($admin)
        {
        }
        $name =
              CGI->img({src=>'/MyOperaTest/graphics/avatar2.gif'}) . ' '
            . CGI->a({href=>'http://my.opera.com/' . CGI::escape($art->{$key}) . '/about'}, $art->{$key});
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
    my @kwords = split /[\s\,\.\;\:]+/, $art->{keywords};

    # Every keyword becomes an anchor to search by *that* keyword
    for(@kwords)
    {
        $_ = CGI->a({href=>'/cgi-bin/MyOperaTest/start/articles_search?keyword=' . CGI::escape($_)}, $_);
    }

    # Finally return the concatenation of those anchors
    return(join(' ', @kwords));
}

#
# Title of article has link to display the single article
#
sub format_title
{
    my($art) = @_;
    my $title = CGI->strong(
          '&quot;'
        . CGI->a({href=>'/cgi-bin/MyOperaTest/start/article_view?id=' . CGI::escape($art->{id})}, $art->{title})
        . '&quot;'
    );
    return($title);
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
