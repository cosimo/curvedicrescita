package Net::DNS::Method::CurveDiCrescita;

use Net::DNS::Method;
use Net::DNS;

our $DOMAIN = 'curvedicrescita.com';
our $IP     = '84.215.51.134';
our $BIND   = '192.168.1.2:53';

our @ISA = qw(Net::DNS::Method);

sub new { bless [], $_[0]; }

sub A { 
    my $self = shift;
    my $q = shift;
    my $a = shift;
    
    $a->header->rcode('NOERROR');

    my $requested_host = $q->qname();
    my $type = $q->qclass() . ' ' . $q->qtype();

    print "------------------------------------------\n";
    print "==> QUERY $type [$requested_host] on " . localtime() . "\n";

    if ($requested_host =~ m{$DOMAIN$}) {
        my $answer = Net::DNS::RR->new($requested_host . ' 10 IN A ' . $IP);
        $a->push('answer', $answer);
        print "<== ANSWERED [$IP]\n";
        print "------------------------------------------\n\n";
        return NS_OK;
    }

    print "<== FAIL\n";
    print "------------------------------------------\n\n";

    #return NS_IGNORE;
    return NS_FAIL;
}

package main;

use Net::DNS;
use Net::DNS::Method;
use Net::DNS::Server;

our $queries = 0;

sub terminate {
    print "$queries queries served\n";
    exit;
}

$SIG{INT} = \&terminate;

my $method = Net::DNS::Method::CurveDiCrescita->new;
my $server = new Net::DNS::Server ($BIND, [ $method ])
    or die "Cannot create server object: $!";

print "Listening to DNS queries on $BIND...\n";

while ($server->get_question()) {
    $server->process;
    $server->send_response();
    $queries++;
}

terminate();

