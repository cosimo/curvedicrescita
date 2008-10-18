# $Id$

package Opera::View::Users;

use strict;
use CGI;

#
# Display isadmin flag
#
sub format_isadmin
{
    my($usr, $key) = @_;
    my $flag = '';
    $key ||= 'isadmin';
    my $img = '/MyOperaTest/graphics/validate/ko.gif';

    if(exists $usr->{$key} && $usr->{$key})
    {
        substr($img, -6) = 'ok.gif';
    }

    $flag = CGI->img({src=>$img, border=>0});

    return($flag);
}


#
# Display username information in forms/pages/...
#
sub format_username
{
    my($usr, $key) = @_;
    my $name = '';
    $key ||= 'username';

    if(exists $usr->{$key} && $usr->{$key} ne '')
    {
        my $img = '/MyOperaTest/graphics/avatar2.gif';
        $name =
              CGI->img({src=>'/MyOperaTest/graphics/avatar2.gif'}) . ' '
            . CGI->a({href=>'/cgi-bin/MyOperaTest/start/user_view?username=' . CGI->escape($usr->{$key})}, $usr->{$key});
    }

    return($name);
}


1;

#
# End of class

=head1 NAME

Opera::View::Users - Visually present information about users

=head1 SYNOPSIS

    my %user = (
        username  => 'cosimo',
        realname  => 'Cosimo Streppone',
        isadmin   => 1,
        # ...
    );

    # Displays link to user view form
    print Opera::View::Users::format_username(\%user);

    # Displays a yes/no graphic symbol as html img
    print Opera::View::Users::format_isadmin(\%user);

=head1 FUNCTIONS

Each "format_*" function accepts a full users record (as hashref)
and outputs (x)html code visually present information such as username.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
