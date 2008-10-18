# $Id: Auth.pm,v 1.4 2007/06/05 21:55:15 cosimo Exp $

package Opera::Application;

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

    # Sanitize user input, removing all non-alphanumeric chars
    # FIXME Rather simple. Must define something more sophisticated.
    for($prm{user}, $prm{passwd})
    {
        tr/A-Za-z0-9//cds;
    }

    # Check credentials against password saved in users file
    my $users = Opera::File::Users->new();
    my $user  = $users->get({where=>{username=>$prm{user}}});

    if(!$user)
    {
        $self->log('warn', 'User [' . $prm{user} . '] not found on users file');
        $self->user_warning('Authentication failed', 'User <b>' . $prm{user} . '</b> not found! Please retry...');
    }
    # User found, check password
    else
    {
        $self->log('notice', 'User [' . $prm{user} . '] found! Checking password');

        # If stored pw hash == input passwd hash, user is authenticated
        my $stored_pw = $user->{password};
        my $input_pw  = Digest::SHA1::sha1_hex($prm{passwd});

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
            $self->user_warning('Authentication failed', 'Invalid password!');
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
