# $Id$

# View class. Contains methods to visually present information to user.
package BabyDiary::View::Questions;

use strict;

use CGI ();
use Digest::MD5 ();
use Encode;
use HTML::Strip;
use BabyDiary::File::Questions;
use BabyDiary::View::Articles;

#
# Format and display question content
#
sub format_question {
	return BabyDiary::View::Articles::format_article(@_);
}

#
# Display article excerpt in search results screen
# Displays only first 2 lines of content.
#
sub format_question_excerpt
{
    my($art) = @_;

    # Take first two lines of the article
    my $content = $art->{content};

    my $html_stripper = HTML::Strip->new();
    $content = $html_stripper->parse($content);
    $content = substr($content, 0, 160) . ' ...';

	if ($^O eq 'MSWin32') {
		$content = encode('utf-8', $content);
	}

    return($content);
}


sub format_author {
	return BabyDiary::View::Articles::format_author(@_);
}

sub format_author_avatar {
	my ($rec, $key) = @_;

	$key ||= 'createdby';
	my $size = 32;

	# Based on www.gravatar.com
	my $user = lc $rec->{$key};
	my $avatar_url = 'http://www.gravatar.com/avatar/';
	my $md5 = Digest::MD5::md5_hex($user);
	$avatar_url .= $md5;

	my %av = (
		class => 'avatar',
		alt => 'user avatar',
		align => 'absmiddle',
		width => $size,
		height => $size,
		src => qq{$avatar_url?s=$size&d=identicon},
	);

	my $html = q{};
	for (keys %av) {
		$html .= qq($_="$av{$_}");
	}

	return qq{<img $html>};

}

sub format_comment {
	return BabyDiary::View::Articles::format_comment(@_);
}

#
# Keywords appear each with a link to search for that keyword
#
sub format_keywords {
	return BabyDiary::View::Articles::format_keywords(@_);
}

#
# Title of question has link to display the single question
#
sub format_title {
	return BabyDiary::View::Articles::format_title(@_);
}

#
# Title of question has link to display the single question
#
{

    my $questions;

    sub format_title_link
    {
        my ($question) = @_;
        my $slug;
        my $title;

        # FIXME Here we don't use $questions->url() because
        # we want to use the internal slug field to speedup
        if (exists $question->{slug}) {
            $slug = $question->{slug};
        } else {
            $questions ||= BabyDiary::File::Questions->new();
            $slug = $questions->slug($question->{id});
        }

		# Mark Non-live questions
		my $title = $question->{title};
		my $style = 'live';

		if (exists $question->{published} && $question->{published} == 0) {
			$style = 'offline';
		}

        if ($slug) {
            $title = CGI->a({
				class=>$style,
				href=>'/exec/question/id/' . CGI::escape($question->{id}) . '/' . $slug
			}, $title);
        }
        else {
            $title = CGI->a({
				class=>$style,
				href=>'/exec/question/id/' . CGI::escape($question->{id})
			}, $title);
        }

        return($title);
    }

}

1;

#
# End of class
