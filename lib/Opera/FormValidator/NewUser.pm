# $Id: NewUser.pm,v 1.2 2007/06/05 21:55:15 cosimo Exp $

package Opera::FormValidator::NewUser;
use strict;
use Opera::File::Users;
use Opera::Util;

#
# Password must be not null
#
sub password
{
    my($self, $opt) = @_;
    return $self->not_null($opt);
}

#
# Confirmed password must be equal to first password
# This is filtered by javascript, so we receive 0 or 1
#
sub password2
{
    my($self, $opt) = @_;
    my $val = $opt->{value};
    my %res = ( ok => 1 );

    if(! defined $val)
    {
        return \%res;
    }

    if($val eq 'false' || $val eq '0')
    {
        $res{ok} = 0;
        $res{reason} = $self->locale->msg('Passwords don\'t match');
        $res{json}   = qq{pw2=document.getElementById('password2');pw2.value='';pw2.focus()};
    }

    return \%res;
}

#
# Real name must be not null
#
sub realname
{
    my($self, $opt) = @_;
    return $self->not_null($opt);
}

#
# Validation routine for username
#
sub username
{
    my($self, $opt) = @_;
    my $logger = $self->logger;

    $logger->notice('Username ', $opt);

    my $user = $opt->{value};

    # Trim username
    $user = Opera::Util::btrim($user);

    if(!$user)
    {
        $logger->warn('Empty username');
        return;
    }

    # Check that user length is >= 5
    if(length $user < 5)
    {
        $logger->notice($self->locale->msg('Username too short'));
        return {
            ok     => 0,
            reason => $self->locale->msg('Username too short'),
        };
    }

    # Check that user is not already taken
    my $users = Opera::File::Users->new();
    my $rec   = $users->get({ where => {username=>$opt->{value}} });

    # Username seems to exist already?
    if($rec && $rec->{username} eq $opt->{value})
    {
        return {
            ok => 0,
            reason => $self->locale->msg('Username already taken')
        };
    }

    # When input is validated, make it lowercase
    my $lowercased = lc $opt->{value};
    return {
        ok   => 1,
        json => qq(var u=document.getElementById('username');if(u) u.value='$lowercased';)
    };

}

1;

#
# End of class

=head1 NAME

Opera::FormValidator::NewUser - New user form field validation routines

=head1 DESCRIPTION

Contains form field validation methods for the new user form.
Every method has the name of the field it validates.

=head1 SEE ALSO

Main form validator class C<Opera::FormValidator>.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
