# $Id: SQLite.pm,v 1.7 2007/06/05 22:38:03 cosimo Exp $

# Custom MYSQL driver for Opera::File::Base class
package Opera::File::SQLite;

use strict;
use Carp;
use base qw(Opera::File::DBI);

#
# Class constructor
#
sub new
{

	my($ref, $opt) = @_;
    my $class = ref $ref || $ref;

    my $table    = $opt->{table}  || $class->TABLE();
	my $fields   = $opt->{fields} || $class->FIELDS();
    my $dbname   = $opt->{dbname} || $class->dbname();

    # Create DSN and connect to SQLite db
    my $dsn = "DBI:SQLite:dbname=$dbname";
	my $dbh = DBI->connect($dsn, "", "", { RaiseError=>1, PrintError=>1 } );

    if(!$dbh || !$dbh->ping())
    {
        croak("Can't connect to DSN `$dsn'");
    }

    my $self = {
    	_dbh      => $dbh,
        _dsn      => $dsn,
        _dbname   => $dbname,
        _dbuser   => '',
        _dbpass   => '',
    	_table    => $table,
    	_fields   => $fields,
    };

	bless $self, $class;
}

1;

#
# End of class

=pod

=head1 NAME

Opera::File::SQLite - Specialization of Opera::File::DBI for SQLite database

=head1 SYNOPSIS

Use as a base class, deriving from it.

=head1 METHODS

Has all methods of Opera::File::DBI, plus some more customized for SQLite.
List follows:

=head2 last_insert_id( $field_name )

Returns the last "id" (usually primary key anyway) field value that was inserted in
a SQL INSERT query with an auto-increment field.

C<$field_name> is the actual field name you want the value of.

=head2 match(\%opt)

Implements SQLite's standard full-text indexing search operator (MATCH) queries.
Returns a list of hashrefs with all records returned by query.
All records automatically have a 'relevance' key that represents the MATCH() operator
evaluation.

\%opt hashref should contain:

=over *

=item fields

Arrayref. List of fields you want your query to return. Example: [ 'id', 'title', 'content' ]

=item matchfields

Arrayref. List of fields you want the MATCH operator to apply (a corresponding
index must exist, or SQLite will give an error).

=item matchstring

Scalar. String to match against.

=item (optional) limit

Scalar. Specifies how many results you want at most.

=back

=head1 SEE ALSO

=over *

=item L<DBI>

=item L<SQL::Abstract>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
