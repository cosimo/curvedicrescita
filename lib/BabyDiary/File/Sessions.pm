# $Id$

package BabyDiary::File::Sessions;

use strict;
use base qw(BabyDiary::File::SQLite);

# Define the standard schema for CGI::Session' sessions file
use constant TABLE  => 'sessions';
use constant FIELDS => [ qw(id a_session) ];

1;

#
# End of class

=pod

=head1 NAME

Opera::File::Sessions - base class to access CGI::Sessions' sessions table

=head1 SYNOPSIS

  my $sessions = Opera::File::Sessions->new();

  # Get a session data
  my $rec = $sessions->get({where=>{id=>'....'}});
  print $rec->{id}, '=', $rec->{a_session}, "\n";

  # Get count of records in the table
  my $cnt = $sessions->count();
  print "We have $cnt sessions in the table\n";

  # Access the underlying DBI connection
  my $dbh = $sessions->dbh();

=head1 DESCRIPTION

This class is modeled after the C<CGI::Session> default sessions table structure.
Refer to C<CGI::Session> or C<CGI::Session::Tutorial> for more details.

=head1 SEE ALSO

=over *

=item C<CGI::Session>

=item C<CGI::Session::Tutorial>

=item C<DBI>

=back

=head1 METHODS

Nothing special. Check the C<Opera::File::MySQL> parent class.

=cut
