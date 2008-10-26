# $Id$

package Opera::Application;

use strict;
use Opera::File::Users;
use Opera::FormValidator;
use Opera::Util;
use Opera::View::Users;
use HTML::FillInForm;

sub user_create
{
    my $self = $_[0];
    my $query = $self->query();

    # Check form parameters
    my %prm = $query->Vars;
    my $vld = Opera::FormValidator->new();
    if(! $vld->validate_form($self, 'NewUser', \%prm))
    {
        return $self->forward('users');
    }

    # Load users file
    my $users = Opera::File::Users->new();

    # Check if username is already present on db
    my $rec   = $users->get({where => {username=>$prm{username}}});
    if($rec && $rec->{username} eq $prm{username})
    {
        $self->user_warning('User creation error!', $self->locale->msg('User already taken'));
        return $self->forward('users');
    }

    my $ok = $users->insert({
        username  => $prm{username},
        realname  => $prm{realname},
        isadmin   => $prm{isadmin} ? 1 : 0,
        language  => $prm{language},
        # Hash password with SHA1, that is binary compatible with MySQL's sha1() func
        password  => Digest::SHA1::sha1_hex($prm{password}),
        createdon => Opera::Util::current_timestamp(),
    });

    $self->log('notice', 'Create new user `', $prm{username}, '\' => ', ($ok?'OK':'*FAILED*'));

    # Return to users page
    if(!$ok)
    {
        $self->user_warning('User creation error!', 'Sorry! User not created. There was some problem. Please retry later or report the problem at <b>bugs@myoperatest.com</b>');
    }
    else
    {
        $self->user_warning('User created!', 'The new user profile was created successfully.');
    }

    # Return to user create form
    return $self->forward('users');
}

#
# Delete a user that is in the database
#
sub user_delete
{
    my $self  = $_[0];
    my $query = $self->query();

    # Check if user is logged in before allowing delete
    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Disallow delete');
        $self->user_warning('Please login!', 'Login to application to delete users');
        return $self->forward('users');
    }

    # Check if username was properly passed
    my $user = $self->query->param('username');
    if(!$user)
    {
        $self->log('warn', 'Delete of user without username...');
        $self->user_warning('Delete failed', 'Can\'t delete without username');
        $self->forward('users');
    }

    # We can delete an user if current user is an admin
    my $users      = Opera::File::Users->new();
    my $curr_user  = $self->session->param('user');
    my $can_delete = $users->is_admin($curr_user);

    if(!$can_delete)
    {
        $self->log('warn', 'Delete of user ', $user, ' is not allowed.');
        $self->user_warning('User delete not allowed', 'You are not an administrator. You are not allowed to delete users');
        $self->forward('users');
    }

    # Delete article record on db
    my $ok = $users->delete({username=>$user});

    if($ok)
    {
        $self->log('notice', 'Deleted user ', $user);
        $self->user_warning('User deleted!', 'The selected user profile ' . $user . ' was deleted!');
    }
    else
    {
        $self->log('warn', 'Delete of user ', $user, ' *FAILED*');
        $self->user_warning('User delete failed', 'Sorry! The user `', $user, '\' wasn\'t deleted. There was some problem. Please retry later or report the problem at <b>bugs@myoperatest.com</b>');
    }

    # Return to users search
    return $self->forward('users');
}

#
# Display a form to modify user
#
sub user_modify
{
    my $self = $_[0];
    my $query = $self->query();

    # Check if user is logged in before allowing delete
    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Don\'t allow to modify users');
        $self->user_warning('Please login!', 'Login to application to modify users');
        return $self->forward('users');
    }

    # Check if username was passed
    my $user = $query->param('username');
    if(! $user)
    {
        $self->log('warn', 'Modify of user without username...');
        $self->user_warning('Modify failed', 'Can\'t modify without username');
        $self->forward('users');
    }

    $self->log('notice', 'Modifying user ', $user);

    # Load current user record
    my $users = Opera::File::Users->new();
    my $rec = $users->get({
        where => { username => $user }
    });

    # Get name of current user
    my $curr_user = $self->session->param('user');

    # Check that user can modify the user profile
    my $can_modify = $users->is_admin($curr_user);

    if(!$can_modify)
    {
        $self->log('warn', 'Modify of user profile ', $user, ' is not allowed.');
        $self->user_warning('User modify not allowed', 'You are not an administrator. You are not allowed to modify profiles');
        $self->forward('users');
    }

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    # If user record is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( user_content => '<h2>No user profile found...</h2>' );
        return $tmpl->output();
    }

    # If we come from a modify request with all the needed data,
    # save the modified user profile now
    if($query->request_method() eq 'POST' && ! exists $self->{recurse})
    {

        #
        # Try to validate provided information and  detect errors
        #
        my $vld = Opera::FormValidator->new();
        my %prm = $query->Vars();
        if(! $vld->validate_form($self, 'ModifyUser', \%prm))
        {
            # Avoid endless loops after forward in case of errors
            $self->{recurse} = 1;
            return $self->forward('user_modify');
        }

        # If password doesn't match with stored one, we must change it
        # and, of course, also rehash it with SHA1
        if($rec->{password} ne $query->param('password') || length $rec->{password} != 40)
        {
            $query->param(password => Digest::SHA1::sha1_hex($query->param('password')) );
        }

        # Update query on users file
        my $update_ok = $users->update(
            {
                realname => scalar $query->param('realname'),
                isadmin  => scalar $query->param('isadmin') ? 1 : 0,
                password => scalar $query->param('password'),
                language => scalar $query->param('language'),
            },
            { username => $user }
        );

        # Return to article view page
        if(!$update_ok)
        {
            $self->user_warning('User modify error!', 'Sorry! The profile wasn\'t modified. There wassome problem. Please retry later or report the problem at <b>bugs@myoperatest.com</b>');
        }
        else
        {
            $self->user_warning('User modified!', 'The user profile was modified correctly.');
        }

        # Now update user session if current user is the one updated.
        # In this way we can have interface language changed immediately, for example
        # Probably, it's better *not* to change admin status while in a running session
        if($curr_user eq $user)
        {
            $self->session->param(language => scalar $query->param('language'));
        }

        return $self->forward('user_view');
    }

    # User was found, display it nicely formatted
    $self->log('notice', 'Found user `', $rec->{username}, '\'');

    # Supply parameters for all user properties
    for(@{$users->fields})
    {
        $tmpl->param( $_ => $rec->{$_} );
    }

    # Generate template output
    my $out  = $tmpl->output();

    # Automatically fill-in-form for user editing
    my $form = HTML::FillInForm->new();
    $rec->{password2} = $rec->{password};
    $self->log('warn', $rec);

    my $filled = $form->fill(scalarref => \$out, fdat => $rec, target=>'f3');

    return $filled;
}


#
# Display search results for users from suggest-style search-box,
#
sub user_search
{
    my $self = $_[0];
    my $query = $self->query();

    # Search of users can be only by search query (field=q)
    my $term;
    if(defined($term = $query->param('q')))
    {
        $self->log('notice', 'Searching users by term `', $term, '\'');
    }

    # Load user record
    my $users = Opera::File::Users->new();
    my $list;

    if(defined $term && $term ne '')
    {
        require Opera::Suggest;
        $term = Opera::Util::btrim($term);
        my $suggest = Opera::Suggest->new({engine => 'LIKE'});
        $list = $suggest->results( $users, {
            fields      => ['username', 'realname'],
            matchfields => ['username', 'realname'],
            matchstring => $term,
        });
    }

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    #
    # Add params and localized messages to display search results
    #

    $tmpl->param(
        search_title      => $self->msg('Search results for &quot;[_1]&quot;', $term),
        search_no_results => $self->msg('No results')
    );

    # If some users found, display them in a TMPL_LOOP
    if($list)
    {
        $self->log('notice', 'Found ', scalar(@$list), ' users that match');

        for my $usr (@$list)
        {
            $usr->{username} = Opera::View::Users::format_username($usr);
        }

        $tmpl->param( search_results => $list );
    }

    # Generate template output
    return $tmpl->output();
}

#
# Display details about a single user
#
sub user_view
{
    my $self = $_[0];
    my $query = $self->query();

    # Required parameter: "username"
    my $user = $query->param('username');
    $self->log('notice', 'Displaying user:', $user);

    # Load article (if present)
    my $users = Opera::File::Users->new();
    my $rec   = $users->get({
        where => { username => $user }
    });

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    #
    # Now overwrite content with a nicely formatted article content...
    #

    # If article is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( user_content => 'No user found...' );
    }
    # User found, display all his properties
    else
    {
        $self->log('notice', 'Found user `', $rec->{username}, '\'');
 
        # Supply parameters for all article properties
        $tmpl->param( username  => $rec->{username} );
        $tmpl->param( createdon => $rec->{createdon});
        $tmpl->param( lastlogon => $rec->{lastlogon});
        $tmpl->param( isadmin   => Opera::View::Users::format_isadmin($rec) );
        $tmpl->param( realname  => $rec->{realname} );
        $tmpl->param( language  => $rec->{language} );

        # Check permissions for cancel/modify buttons
        #
        # If user is admin, allow cancel and modify.
        my $current_user   = $self->session->param('user');
        my $is_admin       = $users->is_admin($current_user);

        $self->log('notice', 'Current user ', $current_user, ' is', ($is_admin ? '' : ' *NOT*'), ' an admin');

        $tmpl->param( user_remove_allowed => $is_admin );
        $tmpl->param( user_modify_allowed => $is_admin );

    }

    # Generate template output
    return $tmpl->output();
}

1;

#
# End of class

=pod

=head1 NAME

Opera::Application::Users - Controller tasks related to Users section

=head1 SYNOPSIS

Not to be used directly. Is used by main Opera::Application class.

=head1 DESCRIPTION

Contains runmode methods related to Users section, like user creation,
record view, modify and delete and users search.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
