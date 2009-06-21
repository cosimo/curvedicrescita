# $Id$

# Model class to access article slugs on database
package BabyDiary::File::Comments;

use strict;
use base qw(BabyDiary::File::SQLite);

use constant TABLE  => 'comments';
use constant FIELDS => [ qw(id type rtype rid content createdby createdon lastupdateby lastupdateon keywords published reputation) ];

use Opera::Util;

sub comments_by_article
{
    my ($self, $article_id) = @_;

    my $comments = $self->list({
		where => {
			rtype => 'art',
			rid   => $article_id,
		},
		order => 'createdon',
	});

	if (! $comments) {
		$self->log('notice', 'No comments found for article {' . $article_id . '}');
		return;
	}

	return $comments;
}

sub post {
	my ($self, $article_id, $user, $text) = @_;

	my $comment = {
		type      => 'C',
		rtype     => 'art',
		rid       => $article_id,
		createdby => $user,
		createdon => Opera::Util::current_timestamp,
		published => 1,
		content   => $text,
		reputation=> 0,
	};

	my $result = $self->insert($comment);

	return $result;
}

1;

#
# End of class

