# $Id$

package Opera::Suggest::Match;

use base 'Opera::Suggest';
use strict;

# Opera::Suggest::Match implementation.
# Works with MySQL full-text indexing operator (MATCH).
sub where
{
    my($self, $opt) = @_;

    my $val = $opt->{value};
    my $dbh = $opt->{dbh} || 'DBI';
    my $quoted_val = $dbh->quote($val);
    my $where;

    # When no parameters, return a null where clause
    if(!$opt->{fields} || ref $opt->{fields} ne 'ARRAY')
    {
        return '';
    }

    # Build a WHERE clause that puts in logical OR
    # all the UPPER(field) = UPPER('%search_term%') subclauses

    my @fld = @{$opt->{fields}};
    $where = 'MATCH(%s) AGAINST (%s)'; # in boolean mode)';
    $where = sprintf($where, join(',',@fld), ($quoted_val) x @fld);

    return($where);
}

#
# Ordering is automatically added when performing MATCH() queries
#
sub order
{
    my $self = shift;
    #return $self->where(@_);
    return '';
}

sub results
{
    my($self, $model_class, $opt) = @_;

    my $list = $model_class->match({
        fields      => \@fields,
        matchfields => $opt->{matchfields},
        matchstring => $opt->{matchstring},
        limit       => $opt->{limit},
    });

    return($list);
}

1;

#
# End of class



    return($list);
}

1;

#
# End of class

=head1 NAME

Opera::Suggest::Match - Implementation of MySQL's MATCH() full-text search suggest engine

=head1 SYNOPSIS

Not to be used directly, but through the C<Opera::Suggest> interface.

=head1 DESCRIPTION

Implements a basic suggest-engine backend that works with MySQL's standard full-text
indexing indices and MATCH() operator.

Should be fast enough for generic use.

=head1 SEE ALSO

=over -

=item  Opera::Suggest

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
