#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';
use BabyDiary::File::Sessions;
use Opera::Logger;

my $log = Opera::Logger->new();

$log->notice('Starting');

my $sessions = BabyDiary::File::Sessions->new();
my $dbh = $sessions->dbh();

$log->notice('Opened sessions file');

my $ok = 1;

$ok &&= $dbh->do('DELETE FROM sessions');

$log->notice('Delete of sessions:', $ok);

$ok &&= $dbh->do('VACUUM FULL');

$log->notice('Vacuum of database:', $ok);

$log->notice('Terminating');

exit ($ok ? 0 : 1);

