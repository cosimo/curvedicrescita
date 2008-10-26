# $Id: Application.pm 17 2008-10-18 20:28:17Z Cosimo $

package BabyDiary::Application;

$VERSION = '0.01';

use strict;
use warnings;
use base 'CGI::Application';

use CGI::Application::Plugin::ConfigAuto;
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::Session;
use CGI::Carp 'fatalsToBrowser';

# Used to generate password hashes (sha1_hex) the same as those
# generated by MySQL's `sha1()' database function.
use Digest::SHA1;

use File::Spec ();

# Special application runmodes for articles/users sections
use BabyDiary::Application::Articles;
#use BabyDiary::Application::Auth;
#use BabyDiary::Application::Users;

# Log-helper class
use Opera::Logger;

# Localization class
use Opera::Locale;

# Model classes. High-level access to database tables
use BabyDiary::File::Articles;
use BabyDiary::File::Sessions;
use BabyDiary::File::Users;

# Default expire time for sessions
use constant SESSION_EXPIRE_TIME => '+4h';
use constant SERVER_HOME => 'E:/users/cosimo/desktop/curvedicrescita.com';

#
# Define runmodes
#
sub setup
{
    my $self = shift;

    $self->start_mode('homepage');

    # Extract parameter from PATH_INFO automatically (C::A feature)
    # In this way, `/cgi-bin/MyOperaTest/start?mode=login' can be written as
    #              `/cgi-bin/MyOperaTest/start/login'.
    $self->mode_param(param=>'mode', path_info=>1);

    # Runmode for application errors
    $self->error_mode('default_error');

    # Define all run modes
    $self->run_modes(
        homepage => \&BabyDiary::Application::default,
        articles => \&BabyDiary::Application::default,

        article         => \&BabyDiary::Application::Articles::view,
        article_delete  => \&BabyDiary::Application::Articles::delete,
        article_modify  => \&BabyDiary::Application::Articles::modify,
        article_post    => \&BabyDiary::Application::Articles::post,
        article_search  => \&BabyDiary::Application::Articles::search,

    );

=cut
        help            => \&default,
        login           => \&login,             # in O::A::Auth
        logout          => \&logout,            # in O::A::Auth
        articles        => \&default,
        article_post    => \&article_post,      # in O::A::Articles
        article_view    => \&article_view,      # in O::A::Articles
        article_delete  => \&article_delete,    # in O::A::Articles
        article_modify  => \&article_modify,    # in O::A::Articles
        users           => \&default,
        user_create     => \&user_create,       # in O::A::Users
        users_search    => \&user_search,       # in O::A::Users
        user_delete     => \&user_delete,       # in O::A::Users
        user_modify     => \&user_modify,       # in O::A::Users
        user_view       => \&user_view,         # in O::A::Users
=cut

    return;
}

#
# Set up the UTF-8 charset and inits the session
#
sub cgiapp_init
{
    my $self = shift;

    $self->tmpl_path($self->config('TMPL_PATH'));

    # Setup content charset as UTF-8
    $self->header_add(-type=>'text/html; charset=UTF-8');

    # Create or load session object
    $self->session_init();
}

#
# Default runmode. Works for most cases. Load template,
# load parameters, mix everything with energy. Add ice cubes. Voila'!
#
sub default
{
    my $self = $_[0];
    
    # Load state params (n. of registered users, ...) to appear in application title.
    # Instance HTML::Template object and fills its parameters.
    my $tmpl = $self->fill_params();

    # Generate and return output from template
    return $tmpl->output();
}

#
# How application "soft" errors should be handled
#
sub default_error
{
    my $self = $_[0];

    $self->log('error', 'Oops!');

    my @stack_trace = q{};
    my $level = 1;
    while (my @call = caller($level)) {
        push @stack_trace, '<li>' . join(', ', @call) . '</li>';
        $level++;
    }

    return
        '<body style="background:white;color:#333;font-family:Monaco,\'Courier New\';font-size:12px">'
        . '<h1 style="font-family: \'Myriad Web Pro\';color:red;font-size:30px;border-bottom:1px solid red">Oops!</h1>'
        . '<p>The server generated an exception. Following information might help...</p>'
        . '<h2 style="font-family: \'Myriad Web Pro\';color:#333;font-size:24px;border-bottom:1px solid red">Stack trace</h2>'
        . '<ul>' . join("\n", @stack_trace) . '</ul>'
        . '<h2 style="font-family: \'Myriad Web Pro\';color:#333;font-size:24px;border-bottom:1px solid red">Environment</h2>'
        . $self->dump_html();

    # TODO
    # Extend with something meaningful
    return 'Oops!';
}

#
# Load localization messages
#
sub fill_messages
{
    my($self, $tmpl) = @_;

    for my $msgid ($self->locale->all_messages())
    {
        # Replace TMPL_VARs inside language messages (this is an ugly solution,
        # but has much added flexibility in language messages writing)
        my $msg = $self->msg($msgid);

        # Create a "mini" template with only the message string and
        # resolve all tmpl_* tags inside it
        if($msg =~ /tmpl_/)
        {
            my $mini_tmpl = HTML::Template->new( scalarref=>\$msg, associate=>$tmpl );
            $msg = $mini_tmpl->output();
        }

        $tmpl->param($msgid => $msg);

    }

    return;
}

#
# Load static params, like n. of registered users, ...
#
sub fill_params
{
    my $self  = $_[0];
    my %param;

    # Basic application parameters (cgi path, static resources path, ...)
    $param{mycgi_path} = $self->config('CGI_ROOT');
    $param{www_path}   = '/';

    # Calculate users count
    my $users = BabyDiary::File::Users->new();
    $param{users_count} = $users->count();
    $param{current_timestamp} = time();

    # Set a param with the current runmode to show the correct selected menu-item
    my $rm = $self->get_current_runmode() || 'homepage';
    $param{mode} = $rm;
    $param{"menu_$rm"} = 1;

    # Get other params from session
    my $session = $self->session();
    $param{logged} = $session->param('logged');
    $param{admin}  = $session->param('admin');
    $param{user}   = $session->param('user');

    $self->log('notice', 'Got session ' . $session);

    if($self->param('notice_title'))
    {
        $param{notice_title}   = $self->param('notice_title');
        $param{notice_message} = $self->param('notice_message');
    }

    # Load template object
    my $tmpl;
    eval {
        $tmpl = $self->load_tmpl(undef, die_on_bad_params => 0);
    };
    if ($@) {
        $self->log('error', 'Template loading failed: ' . $@);
        die "fail";
    }

    # Add all calculated parameters to HTML::Template template object
    while(my($key, $val) = each(%param))
    {
        # TODO remove debug
        next unless defined $val;
        $self->log('notice', 'fill_params {', $key, '} => {', $val, '}');
        $tmpl->param($key, $val);
    }

    # Add also the static messages
    # TODO For now this is ok. For very large applications, it's not
    #      so good to load *all* messages
    $self->fill_messages($tmpl);

    # For articles-related sections, calculate also lists of latest/best articles
    if(rand() >= 0.5)
    {
        $tmpl->param( articles_latest => $self->BabyDiary::Application::Articles::latest_n() );
    }
    else
    {
        $tmpl->param(
            articles_latest => $self->BabyDiary::Application::Articles::best_n(),
            # Replace also "latest article" message
            msg_articles_sb_latest => $self->msg('msg_articles_sb_best')
        );
    }

    $tmpl->param( articles_cloud => $self->BabyDiary::Application::Articles::tags_cloud() );

    return $tmpl;
}

#
# Initialize Opera::Locale object to retrieve language messages
# Gets user language and loads those messages.
#
# TODO Browser negotiated HTTP-ACCEPT-LANGUAGE ?
#
sub locale
{
    my $self = $_[0];
   
    # Initialize locale handle
    if(! exists $self->{_locale} || ! defined $self->{_locale})
    {
        # Get user language from session or from user record, if possible
        my $curr_user = $self->session->param('user');
        my @lng       = ('en');

        if($curr_user)
        {
            my $users = Opera::File::Users->new();
            my $rec   = $users->get({where=>{username=>$curr_user}});
            if($rec && $rec->{language})
            {
                $self->log('notice', 'User ', $curr_user, ' has language ', $rec->{language});
                unshift @lng, $rec->{language};
            }
        }

        $self->log('notice', 'Initializing locale with (', \@lng, ')');
        $self->{_locale} = Opera::Locale->init(@lng);
    }

    return($self->{_locale});
}

#
# Takes care of initializing log channel and
# centralized logging, delegating to Opera::Logger class
#
sub log
{
    my($self, $level, @msg) = @_;
    my $logger;

    # Get log channel object
    if(! $self->{_log} )
    {
        $self->{_log} = Opera::Logger->new();
    }

    # Write information into the log channel
    if($logger = $self->{_log})
    {
        $logger->write($level, @msg);
    }

    return;
}

#
# Language message accessor
#
sub msg
{
    my($self, $msgid, @params) = @_;

    if(my $locale = $self->locale())
    {
        $msgid = $locale->maketext($msgid, @params);
    }

    return($msgid);
}

#
# Handles the session initialization and CGI::Session configuration,
# expire times. Sessions are stored inside MySQL server.
#
sub session_init
{
    my $self = $_[0];
    my $ses_tbl = BabyDiary::File::Sessions->new();

    #
    # Configure the CGI::Session behaviour
    #

    # Note: CGI::Session is automatically included
    # by CGI::Application::Plugin::Session
    CGI::Session->name('sid');

    # Check if we must remember the cookie/session
    my $expire_time = $self->query->param('remember')
        ? '+1M'                      # 1 Month
        : SESSION_EXPIRE_TIME();     # Default, 4 hours

    $self->log('notice', 'Expire time of session set to ', $expire_time);

    # Begin by changing cookie name, to hide
    $self->session_config(

        # Store sessions into mysql table
        CGI_SESSION_OPTIONS => [ "driver:sqlite;serializer:Storable", $self->query, {Handle=>$ses_tbl->dbh} ],

        # Session / cookie expire in 4 hours by default, or 1 month when user checks 'remember me!'
        DEFAULT_EXPIRY      => $expire_time,
        COOKIE_PARAMS       => {
            # Hide the CGI::Session nature of the cookie... for security reasons
            -name    => 'sid',
            -expires => $expire_time,
            -path    => '/',
        },

        # Don't automatically send cookie. It seems it gets sent every time...
        SEND_COOKIE => 1,
    );

    #---------------------------------------------------------------
    # FIXME REMOVE OR UNDERSTAND WHY EXISTING COOKIE IS IGNORED
    #
    # Check if client has already session id cookie
    my $cookie = $self->query->cookie('sid');

    # No cookie, so issue it now
    if(! defined $cookie || ! $cookie)
    {
        $self->log('notice', 'No cookie present. Sending it now.');
        $self->session_cookie();
    }
    else
    {
        $self->log('notice', 'Session cookie already present. SID=', $cookie);
        $self->session->load($cookie);
    }
    #---------------------------------------------------------------

    return;
}

#
# Tells if the current user is actually logged in or it is
# an anonymous
#
sub user_logged
{
    my $self = $_[0];
    my $logged = 0;

    if(my $session = $self->session())
    {
        $logged = $session->param('logged');
    }

    return($logged);
}

#
# Put out a user warning on the title section of the page.
# This is used to notice user of any warning/message.
#
sub user_warning
{
    my($self, $title, $msg) = @_;
    $title ||= $self->msg('Untitled notice');
    $msg   ||= $self->msg('Nothing to say?');

    $self->param(notice_title   => $title);
    $self->param(notice_message => $msg);

    return;
}


1;

#
# End of class

=pod

=head1 NAME

Opera::Application - Main controller class for MyOperaTest application

=head1 SYNOPSIS

Used like every other CGI::Application subclass, nothing special here.

  my $app = Opera::Application->new();
  $app->run();

=head1 DESCRIPTION

This class is derived from CGI::Application. It works by defining a set of methods
as application "runmodes". Has access to several objects like CGI, CGI::Session,
CGI::Cookie, most of those needed to handle a web application.

=head1 METHODS

Brief explanation of main methods for this class

=over -

=item setup()

Defines all application "runmodes" and start runmode.
Many runmodes are implemented by methods that always belong to C<Opera::Application>
package, but are found in "external" modules, like for example C<Opera::Application::Articles>.
This is meant to clearly separate functionality and to avoid having very heavy packages.

=item cgiapp_init()

CGI::Application specific hook. Allows to execute all initialization steps for our
application, like reading configuration files, and other tasks that must be executed
always for every runmode.

In our case, this takes care of setting up the UTF-8 charset and initializing session
class configuration parameters.

See C<CGI::Application> for more details.

=item default()

Implements default runmode, that consists of loading the appropriate template (named like
the current runmode), fill up with standard application template variables and generating
output.

=item default_error()

Implements a special runmode, called when application has an untrapped exception.
See L<CGI::Application> for more details.

=item fill_message()

Reads all localization messages and fills the underlying L<HTML::Template> object
with all needed language messages. This is done automatically for all localized
messages. It is probably not very efficient. It should be worked on to provide
only the needed messages.

=item fill_params()

Creates the underlying L<HTML::Template> object and provides all needed static
parameters and basic template configuration (static www path, cgi path, ...).

This also takes care of loading (example) n. of members of the community,
articles and users side sections, ...

Basically it does a lot of work!

=item locale()

Simple accessor. Returns an instance of L<Opera::Locale> class, that is delegated
to deal with localization tasks. This method is used by C<msg()>. See ahead.

=item log( $level, @message )

Logging method. Allows to log notices, warnings and errors to a centralized
application log. This is obtained through a proxy class that is L<Opera::Logger>.
There are three levels (now) of logging: notice, warning and error.
They are displayed in three different colors on the log files. Example:

    sub myrunmode {
        my $self = shift;    # Opera::Application
        $self->log('notice', 'My runmode is starting...');
        # ...
        $self->log('warn', 'My runmode is ended in error');
        # ...
    }

=item msg( $msg_id, @params )

'Glue' method. This is meant to access localization language messages in an easy,
practical and compact way. Used throughout the application to output messages like
"Search results for {word}". Example:

    sub myrunmode {
        my $self = shift;    # Opera::Application
        my $myword = $self->query->param('search_term');
        my $message= $self->msg('Search results for [_1]', $myword);
        # Here '$message' string will be localized in current language
        return $message;
    }

This method automatically accesses L<Opera::Locale> class.
See L<Opera::Locale> for more details.

=item session_init()

Called by C<cgiapp_init()>, creates the basic configuration of underlying
L<CGI::Session> class. This is setup for example to avoid the standard "CGISESSID"
cookie, just to avoid revealing the internal structure to external clients.
It also sets the default session expire times, and basic link to sessions table
on MySQL database.

If there's a session cookie, it loads the corresponding session data structure.
If not, cookie is issued to client and session is created.

There's not much more to say, L<CGI::Session> does everything it's needed.

=item user_logged()

Returns a boolean telling if user is logged-in (true) or if it's still anonymous.

=item user_warning( $title, $message )

Sets a special parameter inside template to allow the display of user notices
in a nice and clean way from wherever inside the application.

You must supply title of the notice and main message (they both can contain
also HTML and Javascript). In fact, this is used also by the validation
mechanism.

=back

=head1 SEE ALSO

=over -

=item L<CGI::Application>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
