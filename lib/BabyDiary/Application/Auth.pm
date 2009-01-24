# $Id$

package BabyDiary::Application::Auth;

use strict;
use BabyDiary::File::Users;

#
# Handles authentication-related tasks, such as login credentials check
# and session modify to mark user as authenticated.
#
sub login
{
    my $self = $_[0];
    my $query = $self->query();

    # Check for user / password 
    $self->log('notice', 'Params received from login form');

    my %prm;
    for($query->param())
    {
        $prm{$_} = $query->param($_);
        $self->log('notice', $_, ' = {', $prm{$_}, '}');
    }

    $self->log('notice', 'Login attempt from user [', $prm{user}, '] with password [', $prm{passwd}, ']');

    # Check credentials against password saved in users file
    my $users = BabyDiary::File::Users->new();
    my $user  = $users->get({where=>{username=>$prm{user}}});

    if(!$user)
    {
        $self->log('warn', 'User [' . $prm{user} . '] not found on users file');
        $self->user_warning('Problema nell\'accesso', 'L\'utente <b>' . $prm{user} . '</b> non esiste. Riprova...');
    }
    # User found, check password
    else
    {
        $self->log('notice', 'User [' . $prm{user} . '] found! Checking password');

        # If stored pw hash == input passwd hash, user is authenticated
        my $stored_pw = $user->{password};
        #my $input_pw  = Digest::SHA1::sha1_hex($prm{passwd});
        my $input_pw  = $prm{passwd};

        #$self->log('info', 'Stored password hash [', $stored_pw, ']');
        #$self->log('info', 'Input  password hash [', $input_pw,  ']');

        if($stored_pw eq $input_pw)
        {
            # Make session authenticated from now
            $self->session->param(
                logged => 1,
                admin  => $user->{isadmin},
                user   => $user->{username},
            );

            # Mark last logon into user record
            $users->update({lastlogon=>Opera::Util::current_timestamp()}, {username=>$prm{user}});

            # Flush session to disk
            $self->session->flush();

            $self->log('notice', 'Successful log-in of user [', $prm{user}, ']', ($user->{isadmin} ? ' (Admin)' : ''));
        }
        else
        {
            $self->log('warn', 'Login of user [', $prm{user}, '] failed');
            $self->user_warning('Problema nell\'accesso', 'Nome utente o password sbagliata');
        }
    }

    # Return to original page (or start if nothing defined)
    my $prev_mode = $prm{prev_mode} || 'homepage';
    $self->log('notice', 'Return to ', $prev_mode, ' application runmode');

    return $self->forward($prev_mode);
}

#
# Called when user clicks on Logout button.
# Deletes current session and blanks Session-ID cookie.
#
sub logout
{
    my $self = $_[0];

    # Remove session and cookie
    $self->log('warn', 'Logout of user ', $self->session->param('user'));

    $self->session->param(logged=>'');
    $self->session->param(admin=>'');
    $self->session->param(user=>'');
    $self->session->delete();

    # Return to home page
    $self->forward('homepage');
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
        $result = signup_form($self);
    } else {
        $result = signup_process($self);
    }

    return $result;
}

sub signup_form {
    my ($self) = @_;

    $self->log('notice', 'Signup form invoked');

    my $tmpl = $self->render_view();

    $tmpl->param(page_title => $self->msg('Registrazione nuovo profilo utente'));
    $tmpl->param(referrer   => $ENV{HTTP_REFERER} || '');

    return $tmpl->output();
}

sub signup_process {
    my ($self) = @_;
    $self->log('notice', 'Processing signup form');

    my $next_url = $self->config('CGI_ROOT') . '/signup';
    my $query = $self->query();

    # Check form parameters
    my %prm = $query->Vars;

    # Assume email as username
    $prm{username} = $prm{email};

    my $vld = BabyDiary::FormValidator->new();
    if(! $vld->validate_form($self, 'Signup', \%prm))
    {
        return signup_form($self);
    }

    # Load users file
    my $users = BabyDiary::File::Users->new();

    # Check if username is already present on db
    my $rec = $users->get({where => {username=>$prm{username}}});
    if($rec && $rec->{username} eq $prm{username})
    {
        $self->log('notice', 'Found already existing user {' . $prm{username} . '}');
        $self->user_warning('Registrazione non riuscita!', 'Utente gi&agrave; presente');
        return signup_form($self);
    }

    $self->log('notice', 'Trying to insert a new user {' . $prm{username} . '}');
    my $ok = $users->insert({
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
    });

    $self->log('notice', 'Create new user `', $prm{username}, '\' => ', ($ok?'OK':'*FAILED*'));

    # Return to users page
    if(!$ok)
    {
        $self->user_warning('Errore', 'La creazione del profilo non &egrave; riuscita.');
        return signup_form($self);
    }
    else
    {
        $self->user_warning('Bene!', 'Congratulazioni, ora sei registrato!');
    }

    # Return to sender
    if ($prm{referrer}) {
        return $self->redirect($prm{referrer});
    }
    else {
        return $self->forward('homepage');
    }

}

1;

#
# End of module

=pod

=head1 NAME

Opera::Application::Auth - Authentication-related controller tasks

=head1 SYNOPSIS

Not to be used directly. Is used by main Opera::Application class.

=head1 DESCRIPTION

Handles authentication-related tasks, such as login credentials check
and session modify to mark user as authenticated.

=head1 METHODS

Brief explanation of main methods for this class

=over -

=item login()

Handles the top-bar login form parameters check and user authentication.
If user credentials are ok, session is set up accordingly and user is
then logged to the application with the special "logged" flag on the session.

=item logout()

De-authenticates user, removing auth information from session and deleting
the current session.

=back

=head1 SEE ALSO

=over -

=item L<Opera::Application>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
