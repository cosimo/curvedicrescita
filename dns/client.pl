#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Net::DNS;

sub resolve {
    my ($address) = @_;
    my $res = Net::DNS::Resolver->new();
    my $query = $res->search($address);
    my $resolved = q{};

    if ($query) {
        for my $rr ($query->answer) {
            next unless $rr->type eq "A";
            $resolved = $rr->address;
            last;
        }
    } else {
        warn "Lookup failed: ", $res->errorstring, "\n";
    }

    return $resolved;
}

my $address = $ARGV[0] or die "$0 <address>\n";
my $resolved = resolve($address);

print "$address is $resolved";

