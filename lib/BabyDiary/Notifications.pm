#
# Various notifications code (email, ...)
#
# $Id$

package BabyDiary::Notifications;

use strict;
use warnings;
use Config::Auto;

sub mail {
    my ($args) = @_;

	my $conf = Config::Auto::parse('../conf/babydiary.conf');
	$args->{smtp} ||= $conf->{smtp_host};

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

	require BabyDiary::File::UsersUnregistered;
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

	# Send the activation mail to the user
	my %message = (
        from    => 'info@curvedicrescita.com',
        to      => $user,
        subject => $subject,
        text    => $text,
	);
	my $sent = mail(\%message);

	# Send also to myself for double checking...
	$message{to} = 'Cosimo Streppone <cosimo@streppone.it>';
	mail(\%message);

    return $sent;
}

sub send_comment_mail {
    my ($user, $article, $comment) = @_;

	require BabyDiary::File::Articles;
	require BabyDiary::File::Users;

	my $users = BabyDiary::File::Users->new();
	my $articles = BabyDiary::File::Articles->new();

    my $user_info = $users->get({where => {username=>$user}});
    if (! $user_info) {
        warn "No user '$user' found? Can't send comment notification email\n";
        return;
    }

	my $art_info  = $articles->get({where => {id=>$article}});
	if (! $art_info) {
		warn "No article '$article' found. Can't send comment notification email\n";
		return;
	}

	my $realname = $user_info->{realname};

	my $title = $art_info->{title};
    my $subject = qq(Nuovo commento di $realname all'articolo '$title');
	my $art_link = 'http://www.curvedicrescita.com/exec/article/' . $articles->slug($article);

	my $text = <<EMAIL_TEXT;
Caro amministratore,

$realname ha appena pubblicato un nuovo commento all'articolo
$title su www.curvedicrescita.com, scrivendo (in html):

-----------------------------
$comment
-----------------------------

Vai all'articolo:
  $art_link

Vai direttamente ai commenti:
  $art_link#comments

-- 
Lo staff di curvedicrescita.com

EMAIL_TEXT

	# Send the activation mail to the user
	my %message = (
        from    => 'info@curvedicrescita.com',
        to      => 'info@curvedicrescita.com',
        subject => $subject,
        text    => $text,
	);

	my $sent = mail(\%message);

	# Send also to myself for double checking...
	$message{to} = 'Cosimo Streppone <cosimo@streppone.it>';
	mail(\%message);

    return $sent;
}

1;

