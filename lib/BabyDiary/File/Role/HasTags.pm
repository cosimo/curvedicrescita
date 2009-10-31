package BabyDiary::File::Role::HasTags;

use strict;

sub related {
    my ($self, $art) = @_;

    # Get list of keywords
    my $rec = $self->get({ where => {id=>$art}});
    my @keywords = split m{\s* , \s*}x => $rec->{keywords};
    my %related;

    # Get all articles with these keywords
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

    my @items;
    my $n = 1;
    for (sort { $related{$b} <=> $related{$a} } keys %related) {

        my ($id, $title) = split "\t";

        my $relevance = $related{$_};
        if ($relevance < 2) {
            next;
        }

        push @items, {
			id        => $id,
			title     => $title,
			relevance => $relevance,
			url       => $self->url($id),
		};

        $self->log('notice', 'Found related items: ' . $title . ' (' . $relevance . ' points)');
        last if $n++ == 5;

    }

    return @items;
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
			'SELECT DISTINCT(keywords) FROM ' . $self->table()
			. ' WHERE published <> 0'
		);

        if ($sth->execute())
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

