# $Id$

# Model class to access questions file on database
package BabyDiary::File::Questions;

use strict;

use base qw(
	BabyDiary::File::SQLite
	BabyDiary::File::Role::HasTags
	BabyDiary::File::Role::HasSlug
	BabyDiary::File::Role::HasViews
);

use constant TABLE  => 'questions';
use constant FIELDS => [ qw(
	id
	title
	slug
	content
	open
	createdby
	createdon
	lastupdateon
	lastupdateby
	keywords
	published
	views
	favorited
	reputation
	answers
	modified
    private
) ];

our $ANSWERS;

#
# Tells who is the original creator or the given question
#
sub owner
{
    my($self, $question_id) = @_;

    # Lookup record on database
    my $rec = $self->get({where=>{id=>$question_id}});

    # Record not found
    if(!$rec)
    {
        $self->log('warn', 'Question ', $question_id, ' not found.');
        return(undef);
    }

    # Ok, question found. Return the owner
    $self->log('notice', 'Owner of question ', $question_id, ' is ', $rec->{createdby});
    return($rec->{createdby});
}

sub how_many_answers {
	my ($self, $id) = @_;

	require BabyDiary::File::Answers;
	my $answers = $ANSWERS ||= BabyDiary::File::Answers->new();

	my $how_many = $answers->list({
		fields => [ 'count(*)' ],
		where => {
			rtype => 'que',
			rid   => $id,
			published => 1,
		}
	});

	if (! $how_many || ref $how_many ne 'ARRAY') {
		return;
	}

	return $how_many->[0]->{'count(*)'};
}

#
# Create a new question on the database
#
sub post
{
    require Opera::Util;

    my($self, $question) = @_;
    my $ok = 0;
    my $id;

    # Check that question structure is correct
    if(ref $question ne 'HASH')
    {
        $self->log('warn', 'No data to post question!');
        return($ok);
    }

    if(    (! exists $question->{title}    || ! $question->{title})
        || (! exists $question->{content}  || ! $question->{content})
    )
    {
        $self->log('warn', 'Question hasn\'t all needed data. Can\'t post!');
        return($ok);
    }

    for(sort(keys(%$question)))
    {
        $self->log('notice', 'Question ' , $_ , ': `', $question->{$_}, '\'');
    }

    # Put default data
    $question->{createdon} = Opera::Util::current_timestamp();
    $question->{views}     = 0;
    $question->{id}        = undef;

	# Questions are published directly
	$question->{published} = 1;

    # Default is public questions
    $question->{private} = 0 unless exists $question->{private};

	$question->{slug} = Opera::Util::slug($question->{title}, $question->{createdon});

    # Insert record and retrieve the primary key id
    eval { $ok = $self->insert($question); };
    if ($@) {
        $self->log('error', 'Insert failed: ' . $@);
        $ok = 0;
    }

    # Retrieve last insert id
    if(!$ok)
    {
        $self->log('error', 'Question post failed because INSERT failed!');
        return;
    }

    # Question was posted correctly, retrieve auto-inc id
    my $id = $self->last_insert_id();
    $self->log('notice', 'New question id = ' . $id);

	# Necessary for the slug to be linked to the question
	$question->{id} = $id;

	# Write the slug now
	$ok = $self->add_slug($question);

	$self->log('notice', "Slug $id add " . ($ok ? " ok ($ok)" : "*FAILED*"));

    return $id;
}

sub type {
	return 'question'
}

sub url {
	my ($self, $id) = @_;
	my $url;

	my $slug = $self->slug($id);
	if (! defined $slug) {
		$url = '/exec/question/id/' . $id;
	}
	else {
		$url = '/exec/question/id/' . $id . '/' . $slug;
	}

	return $url;
}

1;

#
# End of class

=pod

=head1 NAME

BabyDiary::File::Questions - Model class to access questions file

=head1 SYNOPSIS

    # Instance object
    my $art = BabyDiary::File::Questions->new();

    # Use methods from super-classes, like BabyDiary::File::MySQL
    # or BabyDiary::File::DBI
    my $rec = $art->get({ where=> { id=>18 } });
    if($rec) {
        # Article found ...
    }
    # ...

    # Custom methods
    my %question_data = (
        title    => 'My super title',
        keywords => 'test',
        content  => 'Bla bla bla',
    );

    if( $art->post(\%question_data) ) {
        # Article posted
    } else {
        # An error occurred?
    }

=head1 DESCRIPTION

Model class. Allows to access the MySQL questions table abstracting DBI and SQL aspects,
providing methods to retrieve single or list of records and delete/modify records.

Check out C<BabyDiary::File::MySQL> and C<BabyDiary::File::DBI> classes documentation for more
details about supported methods.

=head1 METHODS

=over -

=item owner($question_id)

Returns the username of the owner of given question.
If question does not exist, returns undefined value.

=item post(\%question)

Post a new question in the database. It's different from a simple C<insert()> because it
automatically fills some fields for you, like creation timestamp and n. of views.

C<%question> hash should contain at least non-empty C<title>, C<keywords> and C<content> values.
Returns primary key identifier of inserted question (C<id> field).

=item tags_frequency()

Reads all keywords in archived questions and returns a hash structure with a set
of C<(tag, occurrences)> pairs. Ordering by occurrences number, you get the most
popular tags in all the questions.

This method can be very expensive if you have got many questions in your db.
It can be useful to cache this information, because probably doesn't change much.

Example:

    # Get an array with tags in popularity order
    my $art  = BabyDiary::File::Questions->new();
    my %tags = $art->tags_frequency();
    my @popular = sort { $tags{$b} <=> $tags{$a} } keys %tags;

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
