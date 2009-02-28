#
# Various notifications code (email, ...)
#
# $Id$

package BabyDiary::Notifications;

use strict;
use warnings;
use BabyDiary::File::UsersUnregistered;

use constant DEFAULT_SMTP => 'localhost';

sub mail {
    my ($args) = @_;

    $args->{smtp} ||= DEFAULT_SMTP;

    require MIME::Lite;

    my $msg = MIME::Lite->new(
        From    => $args->{from},
        To      => $args->{to},
        Subject => $args->{subject},
        Data    => $args->{text},
    ) or (warn "No msg?", return);

    $msg->add(Organization => 'CurveDiCrescita.com');

    MIME::Lite->send('smtp', $args->{smtp}, Timeout => 30);

    eval { $msg->send() };
    if ($@) {
        warn "Problems in sending mail to $$args{to}: $@\n";
        return 0;
    }

    return 1;
}

sub send_activation_mail {
    my ($user) = @_;

    my $unreg = BabyDiary::File::UsersUnregistered->new();
    my $user_info = $unreg->get({where => {username=>$user}});

    if (! $user_info) {
        warn "No user '$user' found? Can't send activation email\n";
        return;
    }

    require BabyDiary::Activation;
    my $activation_url = BabyDiary::Activation::url($user);

    my $subject = qq(Attivazione utente '$user' su CurveDiCrescita.com);
    my $gender = $user_info->{gender};

    my $final = $gender eq 'f' ? 'a' : 'o';

    my $text = sprintf qq(\nCar%s %s,\n\n), $final, $user_info->{realname};
    $text .= sprintf(qq(grazie per esserti iscritt%s a www.curvedicrescita.com!\n\n), $final);
    $text .= qq(Clicca su questo collegamento per confermare la tua iscrizione:\n\n);
    $text .= $activation_url . "\n\n";
    $text .= "Una volta attivato, potrai iniziare a tenere un diario del tuo bambino\n";
    $text .= "e vedere le sue curve di crescita, ma anche tanto altro!\n\n";
    $text .= "Per qualsiasi dubbio o problema, non esitare a contattarci:\n";
    $text .= "info\@curvedicrescita.com\n\n";
    $text .= "-- \n";
    $text .= "Lo staff di curvedicrescita.com\n\n";

    my $sent = mail({
        from => 'info@curvedicrescita.com',
        to   => 'cosimo@streppone.it', #$user,
        subject => $subject,
        text => $text,
    });

    return $sent;
}

1;

