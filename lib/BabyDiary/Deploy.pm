# $Id$

package BabyDiary::Deploy;

use strict;
use warnings;
use File::Spec;

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

sub windows_to_unix_path {
    my ($file) = @_;

    # Remove Windows drive letter (if any)
    $file =~ s{^\w:}{};

    # Dest path has forward slashes
    $file =~ s{\\}{/}g;

    return $file;
}

sub deploy_live {
    my ($file, $dest) = @_;

    $file = windows_to_unix_path($file);

    if (! defined $dest) {
        $dest = ssh_dest() . '/' . $file;
    }

    my $copy_cmd = qq{d:\\bin\\pscp $file $dest >NUL};
    #print $copy_cmd, "\n";

    my $status = system($copy_cmd);
    return (0 == $status);
}

1;
