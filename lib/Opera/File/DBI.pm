# $Id$

# Model class to access all DBI sources
package Opera::File::DBI;

use strict;
use SQL::Abstract;
use DBI;

# Inherit from Base class
use base qw(Opera::File::Base);

# These methods are declared abstract: they should be implemented in children classes
__PACKAGE__->_ABSTRACT(qw(FIELDS TABLE));

# These methods are simple accessors/mutators
__PACKAGE__->_ACCESSOR(qw(dbname dbuser dbpass dbh dsn fields table));

sub count
{
    my($self, $where) = @_;
    my $dbh = $self->dbh;
    my $sql = SQL::Abstract->new();
    my $query = $sql->select($self->table, ['count(*)'], $where);
    my @count = $dbh->selectrow_array($query);
    $self->log('notice', $self->table, ' count = ' . $count[0]);
    return($count[0]);
}

sub delete
{
    my($self, $where) = @_;
    my $dbh = $self->dbh;
    my $sql = SQL::Abstract->new();
    my $deleted = 0E0;
    my($query, @values);

    # Perform delete sql query and trap DBI errors
    eval {
        ($query, @values) = $sql->delete($self->table, $where);
        my $sth = $dbh->prepare($query);
        $deleted = $sth->execute(@values);
    };
    if($@)
    {
        $self->log('error', 'Delete from ', $self->table, ' SQL:', $query, ' => *FAILED*');
        $self->log('error', '$@='.$@);
        return;
    }

    $self->log('warning', 'Delete from ', $self->table, ' SQL:', $query, ' => ', $deleted, ' records deleted');
    return($deleted);
}

sub get
{
    my($self, $filter) = @_;
    my $dbh = $self->dbh;
    my $fld = $self->fields || [];

    # Build SQL statement to run
    my $sql = SQL::Abstract->new();
    my($where, @bind) = $sql->select($self->table, $fld, $filter->{where});

    # Prepare DBI query
    my $sth = $dbh->prepare($where);
    if(!$sth)
    {
        $self->log('warn', $self->table(), ' SQL Statement [', $where, '] *FAILED* prepare');
        return undef;
    }

    # Fire query to get only one record
    my $ok = $sth->execute(@bind);

    if(!$ok)
    {
        $self->log('warn', $self->table(), ' SQL Statement [', $where, '] *FAILED* execute');
        return undef;
    }

    # Close statement handle and return hashref
    my $rec = $sth->fetchrow_hashref();
    $sth->finish();

    return($rec);
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

sub list
{
    my($self, $filter) = @_;
    my $dbh = $self->dbh;
    my $fld = $filter->{fields} || $self->fields;
    my @list;

    # Build SQL statement to run
    my $sql = SQL::Abstract->new();
    my($list_sql, @bind) = $sql->select($self->table, $fld, $filter->{where}, $filter->{order});
    $self->log('notice', $self->table, ' list SQL ', $list_sql);

    # Prepare DBI query
    eval {

        my $sth = $dbh->prepare($list_sql);
        if(!$sth)
        {
            $self->log('warn', $self->table(), ' SQL Statement [', $list_sql, '] *FAILED* prepare');
            return undef;
        }

        # Fire query to get a list of records
        my $ok = $sth->execute(@bind);
        if(!$ok)
        {
            $self->log('warn', $self->table(), ' SQL Statement [', $list_sql, '] *FAILED* execute');
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

        $self->log('notice', 'Loaded list of ' . scalar(@list) . ' records');

        # Terminate sql statement
        $sth->finish();
    };

    if($@)
    {
        $self->log('warn', $self->table(), ' list *FAILED* $@='.$@);
        return undef;
    }

    return(\@list);
}

#
# Insert one record. Yeah.
#
sub insert
{
    my($self, $rec) = @_;
    my $dbh = $self->dbh;

    # An hashref must be supplied
    if(ref $rec ne 'HASH')
    {
        return undef;
    }

    # Build SQL statement to run
    my $sql = SQL::Abstract->new();
    my($inssql, @bind) = $sql->insert($self->table, $rec);

    $self->log('warn', 'inssql='.$inssql.' @bind=',@bind);

    # Prepare DBI query
    my $sth = $dbh->prepare($inssql);
    if(!$sth)
    {
        $self->log('warn', $self->table(), ' SQL Statement [', $inssql, '] *FAILED* prepare');
        return undef;
    }

    # Fire query to get only one record
    my $ok = $sth->execute(@bind);

    if(!$ok)
    {
        $self->log('warn', $self->table(), ' SQL Statement [', $inssql, '] *FAILED* execute');
        return undef;
    }

    # Close statement handle and return last_insert_id, if available
    $sth->finish();

    $self->log('notice', 'Insert succeeded');

    return(1);
}

#
# Perform a basic matching using standard SQL LIKE operator
#
sub match
{
    my($self, $filter) = @_;
    my $dbh = $self->dbh;
    my $fld = $filter->{fields} || $self->fields;
    my @list;

    # Transform matchfields in a string anyway
    my $match_fields = $filter->{matchfields};
    if(! ref $match_fields)
    {
        $match_fields = [ split ',' => $match_fields ];
    }

    # Build SQL statement to run
    my $sql = SQL::Abstract->new();
    my $rval = '%' . $filter->{matchstring} . '%';
    my $where = join(' OR ',
        map { $_ . ' LIKE ' . $dbh->quote($rval) }
        @{$match_fields}
    );

    # Fake relevance here. No std SQL for that.
    push @{$fld}, '1 AS relevance';

    # Order by is irrelevant here
    my $order = '';

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


sub update
{
    my($self, $rec, $where) = @_;
    my $dbh = $self->dbh;

    # An hashref must be supplied
    if(ref $rec ne 'HASH')
    {
        return undef;
    }

    # Build SQL statement to run
    my $sql = SQL::Abstract->new();
    my($updsql, @bind) = $sql->update($self->table, $rec, $where);

    $self->log('warn', 'Update SQL '.$updsql.' (', join(',',@bind), ')');

    # Prepare DBI query
    my $sth = $dbh->prepare($updsql);
    if(!$sth)
    {
        $self->log('warn', $self->table(), ' SQL Statement [', $updsql, '] *FAILED* prepare');
        return undef;
    }

    # Fire query to get only one record
    my $ok = $sth->execute(@bind);

    if(!$ok)
    {
        $self->log('warn', $self->table(), ' SQL Statement [', $updsql, '] *FAILED* execute');
        return undef;
    }

    # Close statement handle and return last_insert_id, if available
    $sth->finish();

    return(1);
}


# val, DBI::SQL_TYPE
sub quote
{
    my($self, $val, $type) = @_;
    my $dbh = $self->dbh;
    return $dbh->quote($val);
}

1;

#
# End of class

=pod

=head1 NAME

Opera::File::DBI - base class to access data inside DBI tables

=head1 SYNOPSIS

Use as a base class, deriving from it.

=head1 METHODS

List of class methods follows.

=head2 count( \%where )

Perform an SQL count() operation on the current table.

=head3 Parameters

=over *

=item $where

Hashref, with the same syntax as SQL::Abstract.

=back

=head3 Example

  my $obj = Opera::File::Articles->new();
  my $cnt = $obj->count({ views => ['>', 100] });

=head2 delete( \%where )

Delete records from current file

=head3 Parameters

=over *

=item \%where

Hashref. Syntax is that of SQL::Abstract.

=back

=head3 Example

  my $obj = Opera::File::Articles->new();
  # Delete all articles by Cosimo
  my $del = $obj->delete({ createdby => 'cosimo' });
  print 'Deleted ', $del, ' articles';

=head2 get()

Allows to fetch one single record from current file

=head3 Parameters

=over *

=item \%filter

Hashref. Mandatory key: C<where>

=back

=head3 Example

  my $obj = Opera::File::Articles->new();
  my $rec = $obj->get({ where=>q(title='My Best Article')});
  # $rec is a hashref, result of DBI->selectrow_hashref() call

=head2 insert( \%record )

Inserts a new record into current file. Record must be contained in \%record hashref,
with (field, value) pairs.

=head3 Parameters

=over *

=item \%record

Hashref. Each key is a field name, each value its value. (Ah :-)

=back

=head2 list( \%filter )

Allows to fetch many records at once from current file

=head3 Parameters

=over *

=item \%filter

Hashref. Mandatory key: C<where>. Allowed: C<fields>, C<order>, C<limit>

=back

=head3 Example

  my $user = Opera::File::Users->new();
  # Get list of users never logged on
  my $list = $obj->list({ where=>{lastlogon=>undef} });
  # $list is an arrayref of hashrefs (AOH)

=head2 update( \%new, \%where )

Updates a set of records with information contained in \%new hashref.
Updates records selected by \%where hashref.

=head3 Parameters

=over *

=item \%new

Hashref. Must contain all (field, value) pairs to be updated.

=item \%where

Hashref. Where in SQL::Abstract notation.

=back

=head3 Example

  my $user = Opera::File::Users->new();
  # Promote Cosimo to adminstrator
  my $ok = $user->update({isadmin=>1}, {username=>'cosimo'});

=head1 SEE ALSO

=over *

=item L<DBI>

=item L<SQL::Abstract>

=back

=head1 AUTHOR

Cosimo Streppone, L<cosimo@streppone.it>

=cut
