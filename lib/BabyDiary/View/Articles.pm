# $Id$

# View class. Contains methods to visually present information to user.
package BabyDiary::View::Articles;

use strict;
use CGI ();
use Digest::MD5 ();
use HTML::BBCode;
use HTML::LinkExtor;
use HTML::Strip;
use BabyDiary::File::Articles;
use BabyDiary::File::Users;
use BabyDiary::View::Users;
use Opera::Util;

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

    # Quick hack for the "this article is also available..."
    $content =~ s/This article is also available in [^\.]*?\.//i;

    my @lines = split /\r?\n/, $content;
    my @excerpt;
    my $max_words = 50;

    for (@lines) {

        next if m{^ \s* $}x;   # Empty lines
        my @words = split /\s+/;

        while ($max_words-- > 0) {
            push @excerpt, shift @words;
        }

        last if $max_words == 0;
    }

    #    push @excerpt, $_;
    #    $words += ($_ =~ s/\s+/\s/);
    #    last if $words > 40;
    #    #$chars += length;
    #    #last if $chars > 160;
    #}

    # Add dots `...' to denote continued content
    $excerpt[$#excerpt] .= ' ... <a class="read-more" href="' . $art->{href} . '">Leggi</a>';

    # Return the first two lines as excerpt
    $content = join(' ', @excerpt);

	# Highlight html links?
	#$content =~ s{(http://\S+\b)}{<a href="$1">$1</a>}g;

    return($content);
}

sub format_author
{
    my($art, $key) = @_;
    my $name = '';
    $key ||= 'createdby';

    if (exists $art->{$key} && $art->{$key} ne '') {

		# User page NIY
		#$name = CGI->a({href=>'/exec/home/user/' . CGI::escape($art->{$key}) }, $art->{$key});

		my $users = BabyDiary::File::Users->new();
		my $rec = $users->get_by_id($art->{$key});
		$name = $rec->{realname} || 'anonimo?';
		$name = ucfirst $name;
        $name = BabyDiary::View::Users::firstname_from_realname($name);
    }

    return $name;
}

sub format_author_avatar {
	my ($rec, $key) = @_;

	$key ||= 'createdby';
	my $size = 40;

	# Based on www.gravatar.com
	my $user = lc $rec->{$key};
	my $avatar_url = 'http://www.gravatar.com/avatar/';
	my $md5 = Digest::MD5::md5_hex($user);
	$avatar_url .= $md5;

	my %av = (
		class => 'avatar',
		alt => 'user avatar',
		align => 'left',
		width => $size,
		height => $size,
        style => 'padding:5px',
		src => qq{$avatar_url?s=$size&d=identicon},
	);

	my $html = q{};
	for (keys %av) {
		$html .= qq($_="$av{$_}");
	}

	return qq{<img $html>};

}
sub format_comment {
	my ($comment) = @_;
	
	# Trim trailing spaces from comment
	$comment =~ s{^\s+}{};
	$comment =~ s{\s+$}{};

	return $comment;

	# TODO: Strip script/iframe tags for security reasons
	#my $hs = HTML::Strip->new();
	#$hs->set_striptags(['script','iframe']);
	#return $hs->parse($comment);
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
            href=>'/exec/home/search/?keyword=' . CGI::escape($_)
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

		# Mark Non-live articles
		my $title = $art->{title};
		my $style = 'live';

		if (exists $art->{published} && $art->{published} == 0) {
			$style = 'offline';
		}

        my $href;
        if ($slug) {
            $href = "/exec/article/$slug";
        }
        else {
            $href = "/exec/home/article/?id=" . CGI::escape($art->{id});
        }

        # ARGGHH Really bad to do this from here...
        $art->{href} = $href;

        $title = CGI->a({class=>$style, href=>$href}, $title);
        return($title);
    }

}

sub get_first_image {
    my ($article_content) = @_;
    if ($article_content !~ m{^<[iI][mM][gG] ([^>]+) >}x) {
        return;
    }

    my $img_attr = $1;
    my $width;
    my $height;
    my $src;

    if ($img_attr !~ m{ src = " ([^"]+) " }xi) {
        return;
    }
    
    $src = $1;

    if ($img_attr =~ m{ width = "? (\d+) \D }xi) {
        $width = $1;
    }
    
    if ($img_attr =~ m{ height = "? (\d+) \D }xi) {
        $height = $1;
    }

    return {
        src => $src,
        width => $width,
        height => $height,
    };

}

sub handle_coverpic_attributes {
    my ($art, $coverpic) = @_;

    $art->{coverpic} = $coverpic->{src};

    my $max_size = 150;
    my $width = $coverpic->{width};
    my $height = $coverpic->{height};

    $art->{coverpic_w} = $max_size;
    $art->{coverpic_h} = $max_size;

    if ($width && $height) {
        my $aspect_ratio = $width / $height;
        my $portrait_pic = ($aspect_ratio < 1.0);
        if ($portrait_pic) {
            $art->{coverpic_w} = $max_size * $aspect_ratio;
        }
        else {
            $art->{coverpic_h} = $max_size / $aspect_ratio;
        }
    }

    return;
}

sub process {
    my ($art, $additional_loop_vars) = @_;

    $art->{keywords} = format_keywords($art);
    $art->{author} = format_author($art);
    $art->{link} = format_title_link($art);

    # Prepare stripped down content for article summary
    $art->{excerpt} = format_article_excerpt($art);
    $art->{avatar} = format_author_avatar($art);
    $art->{createdon} = Opera::Util::format_date($art->{createdon});
    $art->{lastupdateon} = Opera::Util::format_date($art->{lastupdateon});

    my $coverpic = get_first_image($art->{content});
    if ($coverpic) {
        handle_coverpic_attributes($art, $coverpic);
    }

    # Global vars aren't replicated in TMPL_LOOPs
    if ($additional_loop_vars) {
        for (keys %{ $additional_loop_vars }) {
            $art->{$_} = $additional_loop_vars->{$_};
        }
    }

    return $art;
}

1;

