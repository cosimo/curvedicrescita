# $Id$

package BabyDiary::Deploy;

use strict;
use warnings;

sub user {
    'cosimo';
}

sub password {
    '';
}

sub host {
    'satsrv02.satelgroup.net';
}

sub folder {
    '/var/www2/www.curvedicrescita.com';
}

sub ssh_dest {
    my $url = user() . '@' . host() . ':' . folder();
    return $url;
}

1;

