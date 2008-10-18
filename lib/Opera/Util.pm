# $Id: Util.pm,v 1.4 2007/06/05 21:55:15 cosimo Exp $

# Misc utility functions
package Opera::Util;

use strict;
use Time::Piece;

{
    my $time_obj;

    # Generate dates in SQL ISO format (YYYY-MM-DD hh:mm:ss)
    # for MySQL timestamp field values
    sub current_timestamp
    {
        my $ts;
        $time_obj ||= Time::Piece->new();
        $ts  = $time_obj->ymd();
        $ts .= ' ';
        $ts .= $time_obj->hms();
        return($ts);
    }
}

#
# Trim from a string both leading and trailing spaces
#
sub btrim
{
    my $string = $_[0];
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return($string);
}

1;

#
# End of module

=pod

=head1 NAME

Opera::Util - Misceallaneous utility functions

=head1 SYNOPSIS

  my $string = ' BLA BLA BLA    ';
  my $trimmed = Opera::Util::btrim($string);
  # $trimmed = 'BLA BLA BLA';

  my $ts = Opera::Util::current_timestamp();
  # $ts = '2007-06-05 21:57:28';

=head1 DESCRIPTION

Ungrouped utility functions. If they grow into something more organized, they
will be split in date/time, string, ...

=head1 METHODS

Brief explanation of main methods for this class

=over -

=item btrim($str)

Trims leading and trailing spaces from a string. Returns result in another string.

=item current_timestamp()

Returns the current timestamp as string in MySQL compatible format.
Example: '2007-06-05 21:57:28'

=back

=head1 SEE ALSO

=over -

=item L<Time::Piece>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut

