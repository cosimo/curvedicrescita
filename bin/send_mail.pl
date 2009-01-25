#!/usr/bin/env perl

use lib '../lib';
use BabyDiary::Notifications;

my $from = 'info@curvedicrescita.com';
my $to   = 'cosimo.streppone@gmail.com';
my $subj = 'Registrazione utente "Pluto"';
my $smtp = 'smtp.getmail.no';
my $text = 'Congratulazioni! Curve di crescita bimbi. Ora sei un utente di Curve Di Crescita.com...';

my $ok = BabyDiary::Notifications::mail({
    from    => $from,
    to      => $to,
    subject => $subj,
    text    => $text,
    smtp    => $smtp,
});

print 'Mail sent? ', ($ok ? 'Yes' : 'No'), "\n";

