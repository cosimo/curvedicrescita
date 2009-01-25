#
# User activation related logic
#
# $Id$

package BabyDiary::Activation;

use strict;
use warnings;
use Digest::SHA1;

sub check {
    my ($user, $key) = @_;
    my $valid = 1;

    my $correct_key = key($user);

    if ($key ne $correct_key) {
        $valid = 0;
    }

    return $valid;
}

sub key {
    my ($user) = @_;
    my $secret = secret();
    my $key = Digest::SHA1::sha1_hex($secret . '>>' . $user);
    return $key;
}

sub secret {
    return 'A1200+2703+C64+cc.com>>';
}

sub url {
    my ($user) = @_;

    my $key = key($user);
    my $url = sprintf(
        'http://www.curvedicrescita.com/exec/home/signup_activation?key=%s&user=%s',
        CGI->escape($key),
        CGI->escape($user)
    );

    return $url;
}

1;

