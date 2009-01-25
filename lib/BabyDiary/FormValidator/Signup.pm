# $Id$

package BabyDiary::FormValidator::Signup;

use strict;
use warnings;
use BabyDiary::File::Users;
use Opera::Util;

use base q(BabyDiary::FormValidator);

sub email {
    my($self, $opt) = @_;

    $self->logger('notice', 'Checking user ' . $opt->{value});

    my $res = $self->SUPER::email($opt);

    if ($res->{ok} == 0) {
        return $res;
    }

    # Check that email is not already taken
    my $users = BabyDiary::File::Users->new();
    my $user = $users->get({where => {username=>$opt->{value}}});


    if ($user) {
        return {
            ok     => 0,
            reason => 'Email gi&agrave; utilizzata. Dimenticato la password?',
            json   => qq{var eml=document.getElementById('email');eml.value='';eml.focus()}
        };
    }

    return { ok => 1 };
}

#
# Password must be not null
#
sub password
{
    my($self, $opt) = @_;
    return $self->not_null($opt)
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
        $res{reason} = 'Le password non combaciano',
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

    $logger->notice('Username2 ', $opt);

    my $user = $opt->{value};

    # Trim username
    $user = Opera::Util::btrim($user);

    if(! $user)
    {
        $logger->warn('Empty username');
        return {
            ok => 0,
            reason => 'Il nome utente &egrave; invalido',
        }
    }

    # Check that user length is >= 4
    if(length $user < 4)
    {
        $logger->notice('Username too short');
        return {
            ok     => 0,
            reason => 'Il nome utente &egrave; troppo corto!',
        }
    }

    # Check that user is not already taken
    my $users = BabyDiary::File::Users->new();
    my $rec   = $users->get({ where => {username=>$opt->{value}} });

    # Username seems to exist already?
    if($rec && $rec->{username} eq $opt->{value})
    {
        $logger->warn('Username {' . $opt->{value} . '} already taken');
        return {
            ok => 0,
            reason => 'Email gi&agrave; utilizzata',
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

BabyDiary::FormValidator::Signup - Signup form validation

=head1 DESCRIPTION

Contains form field validation methods for the new user form.
Every method has the name of the field it validates.

=head1 SEE ALSO

Main form validator class C<BabyDiary::FormValidator>.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
