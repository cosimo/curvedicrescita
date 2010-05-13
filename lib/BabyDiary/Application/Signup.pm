package BabyDiary::Application::Signup;

use strict;
use warnings;

use BabyDiary::Activation;
use BabyDiary::File::Users;
use BabyDiary::File::UsersUnregistered;
use BabyDiary::FormValidator;
use BabyDiary::Notifications;
use Opera::Util;

sub activate_user {
    my ($self, $user) = @_;

    my $unreg_users = BabyDiary::File::UsersUnregistered->new();
    my $users = BabyDiary::File::Users->new();

    my $ok = 1;

    # Check that user is not yet in the regular users
    my $dup = $users->get({ where => {username => $user}});
    if ($dup) {
        $self->log('warn', 'User ' . $user . ' already in the regular users. Cannot activate.');
        return;
    }

    my $rec = $unreg_users->get({ where => {username => $user}});

    #
    # Using transaction here locks up SQLite ("Database is locked")
    #

    #$users->begin_transaction();
    $ok = $users->insert($rec);
    $ok &&= $unreg_users->delete({ username => $user });
    #$ok &&= $users->commit();

    return $ok;
}

sub activation {
    my ($self) = @_;

    my %prm = $self->query->Vars;

    $self->log('notice', 'Activation of user {' . $prm{user} . '} key {' . $prm{key} . '}');

    my $tmpl = $self->render_view('signup/activation.html');

    # Check activation key
    my $valid = BabyDiary::Activation::check($prm{user}, $prm{key});

    if ($valid) {
        $self->log(notice => 'Correct key. Going to activate user.');
        $valid = activate_user($self, $prm{user});
        if ($valid) {
            $self->log(notice => 'User ' . $prm{user} . ' activation was successful');

            # Make session authenticated from now
            my $users = BabyDiary::File::Users->new();
            my $user = $users->get({where=>{username=>$prm{user}}});

            if (! $user) {
                $valid = 0;
            }
            else {

                #
                # TODO Move out and share with BD::App::Auth::login
                #
                $self->session->param(
                    logged => 1,
                    admin  => $user->{isadmin},
                    user   => $user->{username},
                );

                $self->session->flush();

                # Mark last logon into user record
                $users->logged_in_now($prm{user});

                # End of shared code
            }

        }
        else {
            $self->log(warn => 'User ' . $prm{user} . ' activation *FAILED*');
        }
    }

    $tmpl->param(user => $prm{user});
    $tmpl->param(key  => $prm{key});
    $tmpl->param(timestamp => Opera::Util::current_timestamp());

    $tmpl->param(user_activated => $valid);

    return $tmpl->output();
}

#
# Shows signup form
#
sub signup
{
    my ($self) = @_;

    my $query = $self->query();
    my $meth = $query->request_method();
    my $result;

    if ($meth ne 'POST') {
        $result = form($self);
    } else {
        $result = process($self);
    }

    return $result;
}

sub form {
    my ($self) = @_;

    $self->log('notice', 'Signup form invoked');

    my $tmpl = $self->render_view();

    $tmpl->param(page_title => $self->msg('Registrazione nuovo profilo utente'));
    $tmpl->param(referrer   => $ENV{HTTP_REFERER} || '');

    return $tmpl->output();
}

sub process {
    my ($self) = @_;
    $self->log('notice', 'Processing signup form');

    my $next_url = $self->url_for('home/signup');
    my $query = $self->query();

    # Check form parameters
    my %prm = $query->Vars;

    my $vld = BabyDiary::FormValidator->new();
    if(! $vld->validate_form($self, 'Signup', \%prm))
    {
        $self->log('warn', 'Signup form rejected');
        return form($self);
    }

    # Assume email as username
    $prm{username} = $prm{email};

    $self->log('notice', 'Signup form ok');

    # Load users file
    my $users = BabyDiary::File::Users->new();
    my $users_unreg = BabyDiary::File::UsersUnregistered->new();

    # Check if username is already present on db
    if ($users->already_exists($prm{username})) {
        $self->log('notice', 'Found already existing user {' . $prm{username} . '}');
        $self->user_warning('Registrazione non riuscita!', 'Utente gi&agrave; presente');
        return form($self);
    }

    $self->log('notice', 'Trying to insert a new user {' . $prm{username} . '}');

    # Add only if it's not yet in unregistered users
    my $ok = $users_unreg->insert_or_replace(
        {
            username  => $prm{username},
            realname  => $prm{realname},
            isadmin   => $prm{isadmin} ? 1 : 0,
            language  => $prm{language},
            # Hash password with SHA1, that is binary compatible with MySQL's sha1() func
            #password  => Digest::SHA1::sha1_hex($prm{password}),
            password  => $prm{password},
            createdon => Opera::Util::current_timestamp(),
            gender    => $prm{gender},
            pregnancy => $prm{pregnancy},
            children  => $prm{children},
            memo      => $prm{memo} || '',
        },
        {
            username=>$prm{username}
        }
    );

    $self->log('notice', 'Create new user `', $prm{username}, '\' => ', ($ok?'OK':'*FAILED*'));

    # Return to users page
    if(!$ok)
    {
        $self->user_warning('Errore', 'La creazione del profilo non &egrave; riuscita.');
        return form($self);
    }

    BabyDiary::Notifications::send_activation_mail($prm{username});

    # Redirect to disallow multiple submits with reload
    $self->redirect($self->url_for('home/signup_thanks'));
}

sub thanks {
    my ($self) = @_;

    $self->log('notice', 'Signup thanks screen');

    my $tmpl = $self->render_view('signup/thanks.html');
    $tmpl->param(referrer => $self->query->param('referrer'));

    return $tmpl->output();
}

1;

