# $Id: Questions.pm 258 2009-06-21 20:11:31Z cosimo $

# View class. Contains methods to visually present information to user.
package BabyDiary::View::Questions;

use strict;
use CGI ();
use HTML::Strip;
use BabyDiary::File::Questions;

#
# Format and display question content
#
sub format_question {
	return BabyDiary::View::Articles::format_article(@_);
}

#
# Display question excerpt in search results screen
# Displays only first 2 lines of content.
#
sub format_question_excerpt {
	return BabyDiary::View::Articles::format_question_excerpt(@_);
}

#
# Display question author name as link to my.opera.com profile
#
sub format_author {
	return BabyDiary::View::Articles::format_author(@_);
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
	return BabyDiary::View::Articles::format_keywords(@_);
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
            $title = CGI->a({class=>$style, href=>'/exec/question/' . $slug}, $title);
        }
        else {
            $title = CGI->a({class=>$style, href=>'/exec/question/id/' . CGI::escape($question->{id})}, $title);
        }

        return($title);
    }

}

1;

#
# End of class
