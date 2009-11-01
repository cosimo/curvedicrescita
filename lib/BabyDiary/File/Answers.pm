# $Id$

package BabyDiary::File::Answers;

use strict;
use base qw(BabyDiary::File::SQLite);

use constant TABLE  => 'answers';
use constant FIELDS => [ qw(id type rtype rid content createdby createdon lastupdateby lastupdateon keywords published reputation modified) ];

use Opera::Util;

sub answers_by_question {
    my ($self, $question_id) = @_;

    my $answers = $self->list({
		where => {
			type      => 'Q',
			rtype     => 'que',
			rid       => $question_id,
		},
		order => 'createdon',
	});

	if (! $answers) {
		$self->log('notice', 'No answers found for question {' . $question_id . '}');
		return;
	}
	else
	{
		$self->log('notice', 'Found ' . scalar (@{ $answers })
			. ' answers to question {' . $question_id . '}'
		);
	}

	return $answers;
}

sub post {
	my ($self, $question_id, $user, $text) = @_;

	my $answer = {
		type      => 'C',
		rtype     => 'art',
		rid       => $question_id,
		createdby => $user,
		createdon => Opera::Util::current_timestamp,
		published => 1,
		content   => $text,
		reputation=> 0,
	};

	my $result = $self->insert($answer);

	return $result;
}

1;

#
# End of class

