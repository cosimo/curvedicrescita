# $Id$

package BabyDiary::File::Users;

use strict;
use base qw(BabyDiary::File::SQLite);

use constant TABLE  => 'users';
use constant FIELDS => [ qw(username realname password isadmin createdon language lastlogon) ];

sub already_exists {
    my ($self, $username) = @_;
    
    # Check if username is already present on db
    my $rec = $self->get({where => {username=>$username}});
    if($rec && $rec->{username} eq $username) {
        return 1;
    }

    return 0;
}

#
# Tells if a user has administrator powers (can remove/change articles or users)
# This check is done reading from users file, rather than accessing session.
# Privileges can change during the session!
#
sub is_admin
{
    my($self, $user) = @_;

    # Lookup record on database
    my $rec = $self->get({where=>{username=>$user}});

    # Record not found
    if(!$rec)
    {
        $self->log('warn', 'User ', $user, ' not found. Don\'t know if he is an admin.');
        return(undef);
    }

    # Ok, user found. Is he an admin?
    my $is_admin = $rec->{isadmin} ? 1 : 0;
    $self->log('notice', 'User ', $user, ($is_admin ? ' is ' : ' is not '), 'an admin');

    return($is_admin);
}

sub logged_in_now {
    my ($self, $user) = @_;

    $self->update(
        { lastlogon => Opera::Util::current_timestamp() },
        { username => $user }
    );

    return;
}

1;

#
# End of class

=pod

=head1 NAME

Opera::File::Users - Model class to access users file

=head1 SYNOPSIS

    # Instance object
    my $users = Opera::File::Users->new();

    # Use methods from super-classes, like Opera::File::MySQL
    # or Opera::File::DBI
    my $rec = $users->get({ where=> { username=>'cosimo' } });
    if($rec) {
        # Record found ...
    }
    # ...

    # Custom methods
    if( $users->is_admin('cosimo') )
    {
        # Allow to delete articles
    }
    else
    {
        # Sorry, no admin privileges
    }

=head1 DESCRIPTION

Model class. Allows to access the MySQL users table abstracting DBI and SQL aspects,
providing methods to retrieve single or list of records and delete/modify records.

Check out C<Opera::File::MySQL> and C<Opera::File::DBI> classes documentation for more
details about supported methods.

=head1 METHODS

=over -

=item is_admin($user)

Accesses users table and tells if given user C<$user> has administrative privileges.
This check is done physically reading record from users file, rather than accessing the
current session. In fact, B<privileges can be changed during the session!>

Returns a scalar boolean with 0/1 values.

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
