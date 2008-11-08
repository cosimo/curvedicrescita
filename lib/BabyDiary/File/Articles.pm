# $Id$

# Model class to access articles file on database
package BabyDiary::File::Articles;

use strict;
use base qw(BabyDiary::File::SQLite);

use constant TABLE  => 'articles';
use constant FIELDS => [ qw(id title content createdon createdby lastupdateon lastupdateby keywords views) ];

#
# Tells who is the original creator or the given article
#
sub owner
{
    my($self, $article_id) = @_;

    # Lookup record on database
    my $rec = $self->get({where=>{id=>$article_id}});

    # Record not found
    if(!$rec)
    {
        $self->log('warn', 'Article ', $article_id, ' not found.');
        return(undef);
    }

    # Ok, article found. Return the owner
    $self->log('notice', 'Owner of article ', $article_id, ' is ', $rec->{createdby});
    return($rec->{createdby});
}

#
# Create a new article on the database
#
sub post
{
    require Opera::Util;

    my($self, $art) = @_;
    my $ok = 0;
    my $id;

    # Check that article structure is correct
    if(ref $art ne 'HASH')
    {
        $self->log('warn', 'No data to post article!');
        return($ok);
    }

    if(    (! exists $art->{title}    || ! $art->{title})
        || (! exists $art->{content}  || ! $art->{content})
    )
    {
        $self->log('warn', 'Article hasn\'t all needed data. Can\'t post!');
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
    $self->log('notice', 'New article id = ' . $id);

    return $id;
}

sub related
{
    my ($self, $art) = @_;

    # Get article keywords
    my $rec = $self->get({ where => {id=>$art}});
    my @keywords = split m{\s* , \s*}x => $rec->{keywords};
    my %related;

    # Get all articles with these keywords
    for my $kw (@keywords) {

        my $term = '%' . $kw . '%';

        my $same_kw = $self->list({
            where => 'keywords LIKE ' . $self->quote($term) . ' AND id <> ' . $self->quote($art),
            fields => [ 'id', 'title' ],
        });

        if (! $same_kw || ! ref $same_kw) {
            next;
        }

        for (@{$same_kw}) {
            ++$related{ join("\t", $_->{id}, $_->{title}) };
        }
    }

    my @articles;
    my $n = 1;
    for (sort { $related{$b} <=> $related{$a} } keys %related) {
        my ($id, $title) = split "\t";
        my $relevance = $related{$_};
        if ($relevance < 2) {
            next;
        }
        push @articles, { id=>$id, title =>$title, relevance=>$relevance};
        $self->log('notice', 'Found related article: ' . $title . ' (' . $relevance . ' points)');
        last if $n++ == 3;
    }

    return @articles;
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
        my $sth = $self->dbh->prepare('select distinct(keywords) from articles');
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

1;

#
# End of class

=pod

=head1 NAME

BabyDiary::File::Articles - Model class to access articles file

=head1 SYNOPSIS

    # Instance object
    my $art = BabyDiary::File::Articles->new();

    # Use methods from super-classes, like BabyDiary::File::MySQL
    # or BabyDiary::File::DBI
    my $rec = $art->get({ where=> { id=>18 } });
    if($rec) {
        # Article found ...
    }
    # ...

    # Custom methods
    my %article_data = (
        title    => 'My super title',
        keywords => 'test',
        content  => 'Bla bla bla',
    );

    if( $art->post(\%article_data) ) {
        # Article posted
    } else {
        # An error occurred?
    }

=head1 DESCRIPTION

Model class. Allows to access the MySQL articles table abstracting DBI and SQL aspects,
providing methods to retrieve single or list of records and delete/modify records.

Check out C<BabyDiary::File::MySQL> and C<BabyDiary::File::DBI> classes documentation for more
details about supported methods.

=head1 METHODS

=over -

=item owner($art_id)

Returns the username of the owner of given article.
If article does not exist, returns undefined value.

=item post(\%article)

Post a new article in the database. It's different from a simple C<insert()> because it
automatically fills some fields for you, like creation timestamp and n. of views.

C<%article> hash should contain at least non-empty C<title>, C<keywords> and C<content> values.
Returns primary key identifier of inserted article (C<id> field).

=item tags_frequency()

Reads all keywords in archived articles and returns a hash structure with a set
of C<(tag, occurrences)> pairs. Ordering by occurrences number, you get the most
popular tags in all the articles.

This method can be very expensive if you have got many articles in your db.
It can be useful to cache this information, because probably doesn't change much.

Example:

    # Get an array with tags in popularity order
    my $art  = BabyDiary::File::Articles->new();
    my %tags = $art->tags_frequency();
    my @popular = sort { $tags{$b} <=> $tags{$a} } keys %tags;

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
