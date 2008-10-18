# $Id: Suggest.pm,v 1.3 2007/06/05 21:55:15 cosimo Exp $

# Suggest engines abstraction class
package Opera::Suggest;
use strict;

sub new
{
    my($class, $opt) = @_;
    my $self = {};
    
    $class = ref($class) || $class;
    $opt ||= {};
        
    # Default suggest engine is 'Like';
    $self->{engine} = $opt->{engine} ||= 'Like';
    $self->{engine} = ucfirst lc $self->{engine};

    # Require delegate class
    my $dlg_class = 'Opera::Suggest::' . $self->{engine};
    eval "use $dlg_class";
    if($@)
    {
        # Error in loading suggest engine class.
        # Use null function
        return bless $self, $class;
    }

    bless $self, $dlg_class;
}

#
# Null implementation: return empty results
#
sub results
{
    return();
}

sub where
{
    return;
}

sub order
{
    return;
}

1;

#
# End of class

=head1 NAME

Opera::Suggest - Suggest engines abstraction class

=head1 SYNOPSIS

    my $suggest  = Opera::Suggest->new({ engine=>'MATCH' }); # or 'LIKE'
    my $file     = Opera::File::Articles->new();

    my $list     = $suggest->results( $file, {
        fields      => \@fields,
        matchfields => \@match_fields,
        matchstring => $prm{val},
        limit       => $max_results,
    });

=head1 METHODS

=over -

=item new(\%opt)

Class constructor. Accepts an C<engine> parameter that specifies which
suggest engine should be loaded. Suggest engines are the available
C<Opera::Suggest::*> classes.

=item results($file, \%opt)

Queries the given model class (C<$file> object) and returns the results
according to current active suggest engine.

Internally, it can use the other two methods, C<where()> and C<order> that
build the WHERE and ORDERBY sql clauses.

Options hashref can contain:

=over *

=item fields

Arrayref with all fields to be returned by the query results

=item matchfields

Arrayref with all fields that should be used for search operation.
For example, MATCH engine uses this parameter to build "MATCH()" operator
clauses with related indices.

=item matchstring

This should be the search term.

=item limit

Maximum number of result records

=back

=back

=head1 SEE ALSO

Suggest engines implementation classes, like C<Opera::Suggest::Like>
or C<Opera::Suggest::Match>.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
