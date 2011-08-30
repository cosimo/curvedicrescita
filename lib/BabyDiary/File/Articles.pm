# $Id$

# Model class to access articles file on database
package BabyDiary::File::Articles;

use strict;
use List::Util ();
use base qw(
    BabyDiary::File::SQLite
    BabyDiary::File::Role::HasTags
    BabyDiary::File::Role::HasSlug
    BabyDiary::File::Role::HasViews
);

use constant TABLE  => 'articles';
use constant FIELDS => [ qw(id title content createdon createdby lastupdateon lastupdateby keywords published views book_index) ];

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
    $art->{published} = 0;

    # Remove slug before inserting record, or else it will fail
    my $slug = exists $art->{slug} ? delete $art->{slug} : undef;

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

    # Necessary for the slug to be linked to the article
    $art->{id} = $id;

    # Write the slug now
    if (defined $slug) {
        $art->{slug} = $slug;
    }

    $ok = $self->add_slug($art);

    $self->log('notice', "Slug $id add " . ($ok ? " ok ($ok)" : "*FAILED*"));

    return $id;
}

sub best {
    my ($self, $where) = @_;

    # How many to get in the end
    my $n = 5;

    $where ||= {};
    $where->{published} = {'<>', 0};

    my $art_list = $self->list({
        where  => $where,
        # Avoid showing always the best n. That's boring.
        limit  => $n * 4,
        # If there's more than one, give me the most recent(s)
        order  => [ 'views DESC, id DESC' ],
    });

    # Select a random 5 articles from the n
    my @shuffled = List::Util::shuffle(@{ $art_list });
    my @random_5 = splice(@shuffled, 0, $n);

    return \@random_5;
}

sub latest {
    my ($self, $where) = @_;

    # How many to get
    my $n = 5;

    $where ||= {};
    $where->{published} = {'<>', 0};

    my $art_list = $self->list({
        where  => $where,
        limit  => $n,
        # If there's more than one, give me the most recent(s)
        order  => [ 'id DESC' ],
    });

    return $art_list;
}

sub pick_randomly {
    my ($self, $where) = @_;

    $where ||= {};
    $where->{published} = {'<>', 0};

    my $art_list = $self->list({
        where  => $where,
        limit  => 5,
        # If there's more than one, give me the most recent(s)
        order  => [ 'RANDOM()' ],
    });

    return $art_list;
}

sub frontpage {
    my ($self, $where) = @_;

    # How many to get
    my $n = 1;

    # Show only the frontpage article (published = 3)
    $where ||= {};
    $where->{published} = 3;

    my $art_list = $self->list({
        where  => $where,
        limit  => $n,
        # If there's more than one, give me the most recent(s)
        order  => [ 'id DESC' ],
    });

    return $art_list;
}

sub type {
    return 'article'
}

sub url {
    my ($self, $id) = @_;
    my $url;

    my $slug = $self->slug($id);
    if (! defined $slug) {
        $url = '/exec/home/article/?id=' . $id;
    }
    else {
        $url = '/exec/article/' . $slug;
    }

    return $url;
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
