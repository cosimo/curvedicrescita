#
# Various notifications code (email, ...)
#
# $Id$

package BabyDiary::Notifications;

use strict;
use warnings;
use Carp;
use Config::Auto;

sub mail {
    my ($args) = @_;

    my $conf = Config::Auto::parse('../conf/babydiary.conf');
    $args->{smtp} ||= $conf->{smtp_host};
    $args->{from} ||= default_sender();

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
    $text .= "Una volta attivato, potrai commentare gli articoli sul sito.\n\n";
    $text .= "A breve sara' anche possibile iniziare a tenere un diario del tuo bambino\n";
    $text .= "e vedere le sue curve di crescita.\n\n";
    $text .= "Per qualsiasi dubbio o problema, non esitare a contattarci:\n";
    $text .= "info\@curvedicrescita.com\n\n";
    $text .= "-- \n";
    $text .= "Curve di crescita\n\n";

	# Send the activation mail to the user
	my %message = (
        from    => default_sender(),
        to      => $user,
        subject => $subject,
        text    => $text,
	);
	my $sent = mail(\%message);

	# Notify administrator as well
	$message{to} = default_recipient();
	mail(\%message);

    return $sent;
}

sub default_recipient {
	my $conf = Config::Auto::parse('../conf/babydiary.conf');
    my $to = $conf->{send_admin_mail_to};
    if (! defined $to || ! $to || ref $to ne 'ARRAY') {
        croak "Wrong or no 'send_admin_mail_to' defined in the configuration!";
    }
    return $to->[0];
}

sub default_sender {
	my $conf = Config::Auto::parse('../conf/babydiary.conf');
    my $to = $conf->{send_admin_mail_from};
    if (! defined $to || ! $to || ref $to ne 'ARRAY') {
        croak "Wrong or no 'send_admin_mail_from' defined in the configuration!";
    }
    return $to->[0];
}

sub send_answer_mail {
    my ($user, $question, $answer) = @_;

	require BabyDiary::File::Questions;
	require BabyDiary::File::Users;

	my $users = BabyDiary::File::Users->new();
	my $questions = BabyDiary::File::Questions->new();

    my $user_info = $users->get({where => {username=>$user}});
    if (! $user_info) {
        warn "No user '$user' found? Can't send answer notification email\n";
        return;
    }

	my $question_info  = $questions->get({where => {id=>$question}});
	if (! $question_info) {
		warn "No question '$question' found. Can't send answer notification email\n";
		return;
	}

	my $realname = $user_info->{realname};

	my $title = $question_info->{title};
    my $subject = qq(Nuova risposta di $realname alla domanda '$title');
	my $question_link = 'http://www.curvedicrescita.com/exec/question/' . $questions->slug($question);

	my $text = <<EMAIL_TEXT;
Caro amministratore,

$realname ha appena pubblicato una nuova risposta alla domanda
$title su www.curvedicrescita.com:

-----------------------------
$answer
-----------------------------

Vai alla domanda:
  $question_link

Vai direttamente alle risposte:
  $question_link#answers

-- 
Lo staff di curvedicrescita.com

EMAIL_TEXT

	# Send the answer mail to the user
	my %message = (
        from    => default_sender(),
        to      => $user,
        subject => $subject,
        text    => $text,
	);

	my $sent = mail(\%message);

	# Notify administrator
	$message{to} = default_recipient();
	mail(\%message);

    return $sent;
}

sub send_question_mail {
    my ($user, $question) = @_;

	require BabyDiary::File::Questions;
	require BabyDiary::File::Users;

	my $users = BabyDiary::File::Users->new();
	my $questions = BabyDiary::File::Questions->new();

    my $user_info = $users->get({where => {username=>$user}});
    if (! $user_info) {
        warn "No user '$user' found? Can't send question notification email\n";
        return;
    }

	my $question_info  = $questions->get({where => {id=>$question}});
	if (! $question_info) {
		warn "No question '$question' found. Can't send question notification email\n";
		return;
	}

	my $realname = $user_info->{realname};

	my $title = $question_info->{title};
    my $subject = qq(Nuova domanda di $realname: '$title');
	my $question_link = 'http://www.curvedicrescita.com/exec/question/' . $questions->slug($question);

	my $text = <<EMAIL_TEXT;
Caro amministratore,

$realname ha appena pubblicato una nuova domanda
dal titolo $title su www.curvedicrescita.com.

Vai alla domanda:
  $question_link

-- 
Lo staff di curvedicrescita.com

EMAIL_TEXT

	# Send the activation mail to the user
	my %message = (
        from    => default_sender(),
        to      => default_recipient(),
        subject => $subject,
        text    => $text,
	);

	my $sent = mail(\%message);

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
        from    => default_sender(),
        to      => default_recipient(),
        subject => $subject,
        text    => $text,
	);

	my $sent = mail(\%message);

    return $sent;
}

1;

