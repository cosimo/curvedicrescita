# $Id: ModifyUser.pm 17 2008-10-18 20:28:17Z Cosimo $

package BabyDiary::FormValidator::ModifyUser;
use strict;
use base q(BabyDiary::FormValidator::NewUser);

#
# Username validation is ok, because when modifying,
# username is already assigned.
#
sub username
{
    return { ok => 1 };
}

#
# Confirmed password must be equal to first password
# This is *not* filtered by javascript. We receive the full confirm password.
#
sub password2
{
    my($self, $opt) = @_;
    my $val = $opt->{value};
    # If "record" key is passed, we are in an "offline" whole form validation.
    # Otherwise, we are probably in an AJAX call. AJAX calls don't send the
    # full record to be checked
    my $rec = exists $opt->{record} ? $opt->{record} : undef;
    my %res = ( ok => 1 );

    # When not called in whole-form context (that is, in CGI AJAX mode)
    if(! $rec)
    {
        if(! defined $val)
        {
            return \%res;
        }

        # Password1 and Password2 don't match. Output an error
        elsif($val eq 'false' || $val eq '0')
        {
            $res{ok} = 0;
            $res{reason} = $self->locale->msg('Passwords don\'t match');
            $res{json}   = qq{pw2=document.getElementById('password2');pw2.value='';pw2.focus()};
        }
    }

    # Called in whole-form mode (there is the "record" key).
    # If password2 is different from password 1, emit an error
    elsif($val ne $rec->{password})
    {
        $res{ok}     = 0;
        $res{reason} = $self->locale->msg('Passwords don\'t match');
        # Blank confirm password and focus it
        $res{json}   = qq{pw2=document.getElementById('password2');pw2.value='';pw2.focus()};
    }

    return \%res;
}

1;

#
# End of class

=head1 NAME

BabyDiary::FormValidator::ModifyUser - User modify form field validation routines

=head1 DESCRIPTION

Contains form field validation methods for the user modify form.
Every method has the name of the field it validates.
It derives from NewUser form, but overrides some methods (for example, password
check works in a totally different way, because it must keep the hashed passwords
like they are).

=head1 SEE ALSO

Main form validator class C<BabyDiary::FormValidator>.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
