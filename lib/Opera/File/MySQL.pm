# $Id: MySQL.pm,v 1.7 2007/06/05 22:38:03 cosimo Exp $

# Custom MYSQL driver for Opera::File::Base class
package Opera::File::MySQL;

use strict;
use Carp;
use base qw(Opera::File::DBI);

use constant DBNAME => 'babydiary';
use constant DBUSER => 'root';
use constant DBPASS => '';

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
    my $dbuser   = $opt->{dbuser} || $class->dbuser();
    my $dbpass   = $opt->{dbpass} || $class->dbpass();

    # Create DSN and connect to MySQL db
    my $dsn = "DBI:mysql:$dbname";
	my $dbh = DBI->connect($dsn, $dbuser, $dbpass, { RaiseError=>1, PrintError=>1 } );

    if(!$dbh || !$dbh->ping())
    {
        croak("Can't connect to DSN `$dsn'");
    }

    my $self = {
    	_dbh      => $dbh,
        _dsn      => $dsn,
        _dbname   => $dbname,
        _dbuser   => $dbuser,
        _dbpass   => $dbpass,
    	_table    => $table,
    	_fields   => $fields,
    };

	bless $self, $class;
}
    
#
# Retrieve last insert id after an insert.
# By default, primary key id is called 'id' (only by convention)
# 
sub last_insert_id
{
    my($self, $id_fld) = @_;
    my $dbh  = $self->dbh();
    my $id;

    # Default auto-increment field is `id'
    $id_fld ||= 'id';

    eval {
        $id = $dbh->last_insert_id(undef, $self->dbname, $self->table, 'id')
    };

    # Log everything ...
    if($@)
    {
        $self->log('error', 'Failed call to last_insert_id: $@='.$@);
    }
    else
    {
        $self->log('notice', 'Fetched ', $self->table, '.last_insert_id = `', $id, '\'');
    }

    return($id);
}

#
# Perform a full-text matching using MySQL MyISAM match feature
# Automatically adds a "relevance" key in the records list
#
sub match
{
    my($self, $filter) = @_;
    my $dbh = $self->dbh;
    my $fld = $filter->{fields} || $self->fields;
    my @list;

    # Transform matchfields in a string anyway
    my $match_fields = $filter->{matchfields};
    if(ref $match_fields eq 'ARRAY')
    {
        $match_fields = join ',', @{$filter->{matchfields}};
    }

    # Build SQL statement to run
    my $sql = SQL::Abstract->new();
    my $where = sprintf('match(%s) against (%s)',
        $match_fields,
        $dbh->quote($filter->{matchstring})
    );

    # Add relevance as last field to be obtained from query
    # In this way we can show the relevance next to each article
    push @$fld, "$where AS relevance";

    # Order by is irrelevant here
    my $order = '';# $where;

    my($match_sql, @bind) = $sql->select($self->table, $fld, $where, $order);
    $self->log('notice', $self->table, ' match SQL ', $match_sql);

    # Prepare DBI query
    eval {

        my $sth = $dbh->prepare($match_sql);
        if(!$sth)
        {
            $self->log('warn', $self->table(), ' SQL Statement [', $match_sql, '] *FAILED* prepare');
            return undef;
        }

        # Fire query to get a list of records
        my $ok = $sth->execute(@bind);
        if(!$ok)
        {
            $self->log('warn', $self->table(), ' SQL Statement [', $match_sql, '] *FAILED* execute');
            return undef;
        }

        # Close statement handle and return hashref
        my $limit = exists $filter->{limit} ? $filter->{limit} : 0;
        my $nrec = 0;
        my $rec;

        while( $limit==0 || $nrec < $limit )
        {
            # Duplicate records because fetchrow_arrayref returns always the same ref
            last unless ($rec = $sth->fetchrow_hashref());
            push @list, { %$rec };
            $nrec++;
        }

        $self->log('notice', 'Matched ' . scalar(@list) . ' records');

        # Terminate sql statement
        $sth->finish();
    };

    if($@)
    {
        $self->log('warn', $self->table(), ' match *FAILED* $@='.$@);
        return undef;
    }

    return(\@list);
}

1;

#
# End of class

=pod

=head1 NAME

Opera::File::MySQL - Specialization of Opera::File::DBI for MySQL database

=head1 SYNOPSIS

Use as a base class, deriving from it.

=head1 METHODS

Has all methods of Opera::File::DBI, plus some more customized for MySQL.
List follows:

=head2 last_insert_id( $field_name )

Returns the last "id" (usually primary key anyway) field value that was inserted in
a SQL INSERT query with an auto-increment field.

C<$field_name> is the actual field name you want the value of.

=head2 match(\%opt)

Implements MySQL's standard full-text indexing search operator (MATCH) queries.
Returns a list of hashrefs with all records returned by query.
All records automatically have a 'relevance' key that represents the MATCH() operator
evaluation.

\%opt hashref should contain:

=over *

=item fields

Arrayref. List of fields you want your query to return. Example: [ 'id', 'title', 'content' ]

=item matchfields

Arrayref. List of fields you want the MATCH operator to apply (a corresponding
index must exist, or MySQL will give an error).

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
