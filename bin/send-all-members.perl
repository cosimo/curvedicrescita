#!/usr/bin/env perl
#
# Send mail to all members
#
# $Id$

BEGIN { $| = 1 }

use strict;
use warnings;
use utf8;
use lib '../lib';

use BabyDiary::Notifications;
use BabyDiary::File::Users;

# Get list of mails
my $users = BabyDiary::File::Users->new();
my $user_list = $users->list();
my @recipients;

for (@{ $user_list }) {
    my $username = lc $_->{username};
    my $realname = $_->{realname};
    push @recipients, qq{"$realname" <$username>};
}

undef $users;
undef $user_list;

# Prepare subject and text to be sent
my $subj = 'Buon Natale da Curve di Crescita!';
my $text =

qq{Ai nostri fedeli lettori, un caloroso augurio di Buon Natale
e Buone Feste!

Che l'anno nuovo possa avverare tutti i vostri
desideri e progetti nel modo migliore.

http://www.curvedicrescita.com/exec/article/2009/12/24/buon-natale

Se è da un po' che non visitate il sito, da circa un mese abbiamo
aggiunto un'interessante sezione "Domande", in cui si possono porre
domande e offrire risposte ad altri utenti.

http://www.curvedicrescita.com/exec/question/latest/

Inoltre stiamo lavorando a nuove funzionalità, come la registrazione
dei propri bimbi. Questo consentirà anche di ricevere utili consigli
in base all'età del bambino.

Aspettiamo anche i vostri consigli.
Arrivederci all'anno nuovo!

-- 
CurveDiCrescita.com
};

# To double check
push @recipients,
    q("Tamara De Zotti" <info@curvedicrescita.com>),
    q("Tamara De Zotti" <tamara.dezotti@gmail.com>)
    ;

my $to_send = scalar @recipients;

for my $to (@recipients) {

    my $ok = BabyDiary::Notifications::mail({
        to      => $to,
        subject => $subj,
        text    => $text,
    });

    if ($ok) {
        $to_send--;
        print "- sent mail to '$to'. $to_send to go.\n";
    }

}

if ($to_send == 0) {
    print "All mails sent successfully!\n";
}
else {
    print "$to_send mails failed sending!\n";
}

