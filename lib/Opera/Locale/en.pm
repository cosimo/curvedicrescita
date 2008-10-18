# $Id$

package Opera::Locale::en;
use strict;
use base q(Opera::Locale);
use vars q(%Lexicon);

%Lexicon = (

    '__test__' => 'My Test Message',          # Used for testing, don't remove!

    # Menu bar
    'msg_menu_home'                       => 'Home',
    'msg_menu_users'                      => 'Users',
    'msg_menu_articles'                   => 'Articles',
    'msg_menu_help'                       => 'Help',
    
    # Homepage
    'msg_home_title'                      => 'This is My Opera Test!',
    'msg_home_intro'                      => 'Yes! This is the test application by Cosimo. If you are a registered user, please login.
If you are not, you can still search articles, but you will have to convince some friend to make a user for you...',

    'msg_home_logged_title'               => 'Nice to see you again!',
    'msg_home_logged_intro'               => q(Now please test the <a href="<!-- tmpl_var mycgi_path -->/articles">Articles</a> and <a href="<!-- tmpl_var mycgi_path -->/users">Users</a> functions, which allow to <b>create</b>, <b>modify</b> and <b>remove</b> articles and users. You can also search for article title and content into the search box in the title bar. If you need (basic) help, check out the <a href="<!-- tmpl_var mycgi_path -->/help">minimal user guide</a>.),

    # Top bar
    'msg_topbar_logged'                   => 'Logged in as <b><!-- tmpl_var name=user --></b><!-- tmpl_if admin --> (<b>Admin</b>)<!-- /tmpl_if -->',
    'msg_topbar_mypage'                   => 'My page',
    'msg_topbar_myaccount'                => 'My account',
    'msg_topbar_inbox'                    => 'Inbox',
    'msg_topbar_mygroups'                 => 'My groups',
    'msg_topbar_logout'                   => 'Logout',

    # Title bar
    'msg_title_members'                   => 'members',

    # Articles section
    'msg_articles_title'                  => 'Articles database',
    'msg_articles_intro'                  => 'Search or create articles from this page. If you need to modify or remove an article, search it before. If you need help on these subjects, you can lookup the fantastic <a href="<!-- tmpl_var mycgi_path -->/help">user guide</a>.',

    # Articles search
    'Search results for &quot;[_1]&quot;' => 'Search results for &quot;[_1]&quot;',
    'No results'                          => 'No results for your search term. Sorry...',

    # Articles sidebox
    'msg_articles_sb_title'               => 'Search articles',
    'msg_articles_sb_intro'               => 'Enter some keywords to search the current articles database. If you find nothing, you can add an article yourself!',
    'msg_articles_sb_tags'                => 'Popular tags',
    'msg_articles_sb_notags'              => 'No popular tags at the moment...',
    'msg_articles_sb_latest',             => 'Latest articles',
    'msg_articles_sb_best'                => 'Most viewed articles',
    'msg_articles_sb_nolatest',           => 'No popular tags at the moment...',

    # Users section
    'msg_users_title'                     => 'Users management',
    'msg_users_intro'                     => 'Search, modify or create users from this page. If you need to modify or remove a user, search it before. If you need help on these subjects, you can lookup the fantastic <a href="<!-- tmpl_var mycgi_path -->/help">user guide</a>.',
    'msg_users_anon_title'                => 'You cannot modify or create user profiles',
    'msg_users_anon_intro'                => 'You should <a href="<!-- tmpl_var mycgi_path -->">login</a> to work with user profiles',

    'msg_users_createnew'                 => 'Post a new article',

    # Users sidebox
    'msg_users_sb_title'                  => 'Search users',
    'msg_users_sb_intro'                  => 'Enter name or parts of name to search the current users database. If you find nothing, you can add an user yourself!',
    'msg_users_sb_inactive'               => 'Most inactive users',
    'msg_users_sb_inactive_explain'       => 'No inactive users at this moment...',

    # Users create form
    'msg_users_fld_username'              => 'Name of new user profile <small>(ex.: jroberts)</small>',
    'msg_users_fld_realname'              => 'Real name of user <small>(ex.: Julia Roberts)</small>',
    'msg_users_fld_password'              => 'Password <small>(choose something secret!)</small>',
    'msg_users_fld_password2'             => 'Repeat password for confirm',
    'msg_users_fld_isadmin'               => 'Has user administrator privilege? <small>(administrators have great power!)</small>',
    'msg_users_fld_language'              => 'Localization language <small>(user interface messages will have this language)</small>',
    'msg_users_review'                    => 'Review the information and confirm it',
    'msg_users_user'                      => 'User: ',
    'msg_users_username'                  => 'Username (<small>not changeable</small>)',

    # Generic messages
    'msg_yes'                             => 'Yes',
    'msg_no'                              => 'No',
    'msg_submit'                          => 'Ok, submit!',

    'Username too short'                  => 'Username is too short. Must be at least 5 chars',
    'Username already taken'              => 'Chosen user name is already taken...',
    'Field "[_1]" is mandatory'           => 'Field "[_1]" is mandatory!',
    'Passwords don\'t match'              => 'Passwords don\'t match!',

);

1;

#
# End of class

=pod

=head1 NAME

Opera::Locale::en - Localized messages for english language

=head1 SYNOPSIS

This class should B<not> be used directly, but rather through L<Opera::Locale> interface.

=head1 DESCRIPTION

Defines all localized messages for one language. All messages are inside a public
C<%Lexicon> hash, as required by Locale::Maketext.

=head1 SEE ALSO

=over -

=item L<Locale::Maketext>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
