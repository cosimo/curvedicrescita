# $Id$

# Model class to access questions file on database
package BabyDiary::File::Questions;

use strict;

use base qw(BabyDiary::File::SQLite);
use BabyDiary::File::Slugs;
use Opera::Util;

use constant TABLE  => 'questions';
use constant FIELDS => [ qw(id title slug content open createdby createdon lastupdateon lastupdateby keywords published views favorited modified) ];

our $slugs;

sub add_slug {
	my ($self, $question) = @_;

	# Check if question already has a slug
	my $id = $question->{id};
	my $slug;

	$slugs ||= BabyDiary::File::Slugs->new();
	my $slug_rec = $slugs->get({ where => {type=>'question', id=>$id}} );

	if ($slug_rec) {
		$slug = $slug_rec->{slug};
		return $slug;
	}

	# Prepend date to question slug
	my $question_date = $question->{createdon};
	$question_date =~ s{^(\d+)-(\d+)-(\d+).*$}{$1/$2/$3};
	$slug = $question_date . '/' . Opera::Util::slug($question->{title});

	my $ok = $slugs->insert_or_replace(
		{
			slug  => $slug,
			id    => $id,
			type  => 'question',
			state => 'A'
		},
		{
			id => $id,
			type => 'question'
		}
	);

	return $ok ? $slug : undef;
}

# Overriden to delete the slug
sub delete {
	my ($self, $where) = @_;
	my $deleted = $self->SUPER::delete($where);

	if ($deleted && $where->{id} ) {
		$self->log('notice', 'Question ' . $where->{id} . ' deleted. Delete slug.');
		$slugs ||= BabyDiary::File::Slugs->new();
		$slugs->delete({ type=>'question', id=>$where->{id} });
	}

	return $deleted;
}

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

#
# Create a new question on the database
#
sub post
{
    require Opera::Util;

    my($self, $art) = @_;
    my $ok = 0;
    my $id;

    # Check that question structure is correct
    if(ref $art ne 'HASH')
    {
        $self->log('warn', 'No data to post question!');
        return($ok);
    }

    if(    (! exists $art->{title}    || ! $art->{title})
        || (! exists $art->{content}  || ! $art->{content})
    )
    {
        $self->log('warn', 'Question hasn\'t all needed data. Can\'t post!');
        return($ok);
    }

    for(sort(keys(%$art)))
    {
        $self->log('notice', 'Article ' , $_ , ': `', $art->{$_}, '\'');
    }

    # Put default data
    #$art->{createdby} ||= '';
    $art->{createdon} = Opera::Util::current_timestamp();
    $art->{views}     = 0;
    $art->{id}        = undef;
	$art->{published} = 0;

    # Insert record and retrieve the primary key id
    eval { $ok = $self->insert($art); };
    if ($@) {
        $self->log('error', 'Insert failed: ' . $@);
        $ok = 0;
    }

    # Retrieve last insert id
    if(!$ok)
    {
        $self->log('error', 'Article post failed because INSERT failed!');
        return;
    }

    # Article was posted correctly, retrieve auto-inc id
    my $id = $self->last_insert_id();
    $self->log('notice', 'New question id = ' . $id);

	# Necessary for the slug to be linked to the question
	$art->{id} = $id;

	# Write the slug now
	$ok = $self->add_slug($art);

	$self->log('notice', "Slug $id add " . ($ok ? " ok ($ok)" : "*FAILED*"));

    return $id;
}

sub related
{
    my ($self, $art) = @_;

    # Get question keywords
    my $rec = $self->get({ where => {id=>$art}});
    my @keywords = split m{\s* , \s*}x => $rec->{keywords};
    my %related;

    # Get all questions with these keywords
    for my $kw (@keywords) {

        my $term = '%' . $kw . '%';

        my $same_kw = $self->list({
            where =>
				  'keywords LIKE ' . $self->quote($term)
				. ' AND id <> ' . $self->quote($art)
				. ' AND published <> 0',
            fields => [ 'id', 'title' ],
        });

        if (! $same_kw || ! ref $same_kw) {
            next;
        }

        for (@{$same_kw}) {
            ++$related{ join("\t", $_->{id}, $_->{title}) };
        }
    }

    my @questions;
    my $n = 1;
    for (sort { $related{$b} <=> $related{$a} } keys %related) {
        my ($id, $title) = split "\t";
        my $relevance = $related{$_};
        if ($relevance < 2) {
            next;
        }
        push @questions, {
			id => $id,
			title => $title,
			relevance => $relevance,
			url => $self->url($id),
		};
        $self->log('notice', 'Found related question: ' . $title . ' (' . $relevance . ' points)');
        last if $n++ == 3;
    }

    return @questions;
}

sub slug {
	my ($self, $id) = @_;
	$slugs ||= BabyDiary::File::Slugs->new();
	my $slug_rec = $slugs->get({ where => {type=>'question', id=>$id} });
	if (! $slug_rec) {
		return;
	}
	return $slug_rec->{slug};
}

#
# Calculates tags frequency distribution, returning a hash
# with (tag, count) pairs.
#
# If its more convenient, we can also use DBI directly...
#
sub tags_frequency
{
    my $self = $_[0];
    my %tags;

    # Trap fatal SQL errors
    eval {

        # Get all different `keywords' field values from database
        my $sth = $self->dbh->prepare(
			'SELECT DISTINCT(keywords) FROM questions '
			. ' WHERE published <> 0'
		);
        if( $sth->execute() )
        {
            while(defined(my $rec = $sth->fetch))
            {
                # Tokenize words and isolate single tags
                for(split m{\s* , \s*}x => $rec->[0]) {
                    # Count +1 for this tag
                    $tags{$_}++;
                }
            }
            # Close SQL statement
            $sth->finish();
        }

    };

    # Was there an error? Log it
    if($@)
    {
        $self->log('error', 'Database error reading the tags frequency: '.$@);
        return();
    }

    return %tags;
}

sub total_page_views {
	my ($self) = @_;

	my $total_page_views;
	my $question_sum = $self->list({ fields => 'sum(views) AS total_page_views' });

	if ($question_sum) {
		$total_page_views = $question_sum->[0]->{total_page_views};
	}

	return $total_page_views;
}

sub url {
	my ($self, $id) = @_;
	my $url;

	my $slug = $self->slug($id);
	if (! defined $slug) {
		$url = '/exec/home/question/?id=' . $id;
	}
	else {
		$url = '/exec/question/' . $slug;
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
