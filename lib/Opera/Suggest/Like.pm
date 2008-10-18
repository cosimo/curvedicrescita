# $Id$

package Opera::Suggest::Like;

use base 'Opera::Suggest';
use strict;

# Opera::Suggest::Like implementation.
# Returns results based only on SQL LIKE operator applied to table fields
sub where
{
    my($self, $opt) = @_;

    my $val = $opt->{value};
    my $dbh = $opt->{dbh} || 'DBI';
    my $quoted_val = $dbh->quote('%' . $val . '%');
    my $where;

    # When no parameters, return a null where clause
    if(!$opt->{fields} || ref $opt->{fields} ne 'ARRAY')
    {
        return '';
    }

    # Build a WHERE clause that puts in logical OR
    # all the UPPER(field) = UPPER('%search_term%') subclauses

    my @fld = @{$opt->{fields}};
    $where = join ' OR ', map { "UPPER($_) LIKE UPPER(\%s)" } @fld;
    $where = sprintf($where, ($quoted_val) x @fld);

    return($where);
}

#
# Order by first field given in the query
#
sub order
{
    my($self, $opt) = @_;
    if( ! $opt || ! exists $opt->{fields} )
    {
        return '';
    }
    return $opt->{fields}->[0];
}

sub results
{
    my($self, $model_class, $opt) = @_;

    # Init params for where() and order() methods
    my %param = (
        fields => $opt->{matchfields},
        value  => $opt->{matchstring},
        dbh    => $model_class->dbh(),
    );

    my $where = $self->where(\%param);
    my $order = $self->order(\%param);

    # Invoke Opera::File::DBI->list() method to obtain a list of records
    # that match the search term.
    my $list = $model_class->list({
        fields      => $opt->{fields},
        where       => $where,
        order       => $order,
        limit       => $opt->{limit},
    });

    return($list);
}


1;

#
# End of class

=head1 NAME

Opera::Suggest::Like - Implementation of SQL LIKE operator suggest engine

=head1 SYNOPSIS

Not to be used directly, but through the C<Opera::Suggest> interface.

=head1 DESCRIPTION

Implements a basic suggest-engine backend that works on the standard SQL LIKE
operator. When user searches for 'xxx', results can include 'fooxxxbar',
'xxxfoo', 'FOOXXX', ...

Nothing very special, works well for many cases, but it's usually not optimized
for "field LIKE '%word%'" style queries.

=head1 SEE ALSO

=over -

=item  Opera::Suggest

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
