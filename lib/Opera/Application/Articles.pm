# $Id$

# Controller methods related to Articles section
package Opera::Application;

use strict;
use Opera::File::Articles;
use Opera::File::Users;
use Opera::Util;
use Opera::View::Articles;

#
# Delete an article that is in the database
#
sub article_delete
{
    my $self  = $_[0];
    my $query = $self->query();

    # Check if user is logged in before allowing delete
    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Don\'t allow to delete articles');
        $self->user_warning('Please login!', 'Login to application to delete articles');
        return $self->forward('articles');
    }

    # Check if article id was passed
    my $art_id = $self->query->param('id');
    if(! $art_id)
    {
        $self->log('warn', 'Delete of article without article_id...');
        $self->user_warning('Delete failed', 'Can\'t delete without article number');
        $self->forward('articles');
    }

    # User can delete an article if:
    #
    # 1) user is an admin
    # 2) article original poster is the same user
    #
    my $users      = Opera::File::Users->new();
    my $articles   = Opera::File::Articles->new();
    my $curr_user  = $self->session->param('user');
    my $can_delete =
           $users->is_admin($curr_user)                  # User is an admin: can delete everything
        || ($articles->owner($art_id) eq $curr_user);    # User is owner of this article

    if(!$can_delete)
    {
        $self->log('warn', 'Delete of article id ', $art_id, ' is not allowed.');
        $self->user_warning('Article delete not allowed', 'You are not the owner of the article. You are not allowed to delete it');
        $self->forward('articles');
    }

    # Delete article record on db
    my $ok = $articles->delete({id=>$art_id});

    if($ok)
    {
        $self->log('notice', 'Deleted article id ', $art_id);
        $self->user_warning('Article deleted!', 'The selected article was deleted!');
    }
    else
    {
        $self->log('warn', 'Delete of article id ', $art_id, ' *FAILED*');
        $self->user_warning('Article delete failed', 'Sorry! The article wasn\'t deleted. There was some problem. Please retry later or report the problem at <b>bugs@myoperatest.com</b>');
    }

    # Return to articles search
    return $self->forward('articles');
}

#
# Display a form to modify article
#
sub article_modify
{
    my $self = $_[0];
    my $query = $self->query();

    # Check if user is logged in before allowing delete
    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Don\'t allow to modify articles');
        $self->user_warning('Please login!', 'Login to application to modify articles');
        return $self->forward('articles');
    }

    # Check if article id was passed
    my $art_id = $query->param('id');
    if(! $art_id)
    {
        $self->log('warn', 'Modify of article without article_id...');
        $self->user_warning('Modify failed', 'Can\'t modify without article number');
        $self->forward('articles');
    }

    $self->log('notice', 'Modifying article id ', $art_id);

    # Load current article
    my $users    = Opera::File::Users->new();
    my $articles = Opera::File::Articles->new();
    my $rec = $articles->get({
        where => { id => $art_id }
    });

    # Get name of current user
    my $curr_user  = $self->session->param('user');

    # Check that user can modify the article
    my $can_modify =
        $users->is_admin($curr_user)                     # User is an admin: can delete everything
        || ($articles->owner($art_id) eq $curr_user);    # User is owner of this article

    if(!$can_modify)
    {
        $self->log('warn', 'Modify of article id ', $art_id, ' is not allowed.');
        $self->user_warning('Article modify not allowed', 'You are not the owner of the article. You are not allowed to modify it');
        $self->forward('articles');
    }

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    # If article is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( article_content => '<h2>No article found...</h2>' );
        return $tmpl->output();
    }

    # If we come from a modify request with all the needed data,
    # save the modified article now.
    if($query->request_method() eq 'POST')
    {

        # Update query on articles file
        my $update_ok = $articles->update(
            {
                title    => scalar $query->param('title'),
                keywords => scalar $query->param('keywords'),
                content  => scalar $query->param('content'),
                lastupdateon => Opera::Util::current_timestamp(),
                lastupdateby => $curr_user,
            },
            { id => $art_id }
        );

        # Return to article view page
        if(!$update_ok)
        {
            $self->user_warning('Article modify error!', 'Sorry! The article wasn\'t modified. There was some problem. Please retry later or report the problem at <b>bugs@myoperatest.com</b>');
        }
        else
        {
            $self->user_warning('Article modified!', 'The article was modified correctly.');
        }

        return $self->forward('article_view');
    }

    # Article is found, display it nicely formatted
    $self->log('notice', 'Found article `', $rec->{title}, '\'');

    # Supply parameters for all article properties
    for(@{$articles->fields})
    {
        $tmpl->param( 'article_' . $_ => $rec->{$_} );
    }

    # Generate template output
    return $tmpl->output();
}


#
# Create a new article in the database
#
sub article_post
{
    my $self = $_[0];
    my $query = $self->query();

    # Check for user / password 
    $self->log('notice', 'Params received from search articles form');

    my %prm;
    for($query->param())
    {
        $prm{$_} = $query->param($_);
        $self->log('notice', $_, ' = {', $prm{$_}, '}');
    }

    # Try to clean up user input
    # XXX To be done more seriously...
    for($prm{title}, $prm{keywords})
    {
        tr(A-Za-z0-9 _/)()cds;
    }

    # Clean up content. Detect and strip html code, either
    # in "<...>" format, or "&lt;...&gt", or "<..."
    $prm{content} =~ s/<[^>]*>?//g;
    $prm{content} =~ s/&lt;[^>]*(&gt;)?//g;

    # Check credentials against password saved in users file
    my $art = Opera::File::Articles->new();
    my $posted = $art->post({
        title     => $prm{title},
        keywords  => $prm{keywords},
        createdby => $self->session->param('user'),
        content   => $prm{content},
    });

    $self->log('notice', 'Posted article with title `', $prm{title}, '\' => ', ($posted?'OK':'*FAILED*'));

    # Return to articles page
    if(!$posted)
    {
        $self->user_warning('Article post error!', 'Sorry! Your article wasn\'t posted. There was some problem. Please retry later or report the problem at <b>bugs@myoperatest.com</b>');
    }
    else
    {
        $self->user_warning('Article posted!', 'Your article was accepted and posted. Thanks for your contribution!');
    }

    # Return to articles search
    return $self->forward('articles');
}

#
# Display search results for articles, either from suggest-style search-box,
# or from keywords search
#
sub article_search
{
    my $self = $_[0];
    my $query = $self->query();

    # Search of articles can be by single keyword (field=keyword)
    # or by search query (field=q)
    my $term;
    my $keyword;

    if(defined($term = $query->param('q')))
    {
        $self->log('notice', 'Searching articles by term `', $term, '\'');
    }
    elsif(defined($keyword = $query->param('keyword')))
    {
        $self->log('notice', 'Searching articles by keyword `', $term, '\'');
    }

    # Load article (if present)
    my $articles = Opera::File::Articles->new();
    my $list;

    if(defined $keyword && $keyword ne '')
    {
        $keyword = Opera::Util::btrim($keyword);
        $list = $articles->match({
            matchstring => $keyword,
            matchfields => 'title,content,keywords', # keywords',
            # TODO Allow to select boolean or nl modes??
            #mode        => 'boolean',
        });
    }
    elsif(defined $term && $term ne '')
    {
        $term = Opera::Util::btrim($term);
        $list = $articles->match({
            matchstring => $term,
            matchfields => 'title,content,keywords',
        });
    }

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    #
    # Add params and localized messages to display search results
    #

    $tmpl->param(
        search_title      => $self->msg('Search results for &quot;[_1]&quot;', $keyword || $term),
        search_no_results => $self->msg('No results')
    );

    # If some articles found, display them in a TMPL_LOOP
    if($list)
    {
        $self->log('notice', 'Found ', scalar(@$list), ' articles that match');

        for my $art (@$list)
        {
            # Highlight keyword or term
            highlight_term($term,    $art);
            highlight_term($keyword, $art);

            $art->{article_link}     = Opera::View::Articles::format_title($art);
            $art->{article_author}   = Opera::View::Articles::format_author($art);
            $art->{article_keywords} = Opera::View::Articles::format_keywords($art);
            $art->{article_excerpt}  = Opera::View::Articles::format_article_excerpt($art);

        }

        $tmpl->param( search_results => $list );
    }

    # Generate template output
    return $tmpl->output();
}

#
# Make a "marker" style background appear around selected words
#
sub highlight_term
{
    my($string, $article) = @_;

    # Case insensitive search for words
    # XXX Title should not contain HTML code...
    if(defined $string && $string ne '')
    {
        for(qw(title content keywords))
        {
            $article->{$_} =~ s/($string)/<span style="background: yellow">$1<\/span>/gi;
        }
    }
}

#
# Display details about a single article
#
sub article_view
{
    my $self = $_[0];
    my $query = $self->query();

    # Required parameter: "id"
    my $art_id = $query->param('id');
    #$self->log('notice', 'Displaying article id:', $art_id);

    # Load article (if present)
    my $art = Opera::File::Articles->new();
    my $rec = $art->get({
        where => { id => $art_id }
    });

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    #
    # Now overwrite content with a nicely formatted article content...
    #

    # If article is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( article_content => '<h2>No article found...</h2>' );
    }
    # Article is found, display it nicely formatted
    else
    {
        $self->log('notice', 'Found article `', $rec->{title}, '\'');
  
        # Increase number of views of article
        #
        # XXX This is obviously not going to work in this way for highly concurrent environments
        # Also, it can be a good idea to drop the whole concept of articles views, to avoid
        # database writes on every page view...
        $rec->{views}++;
        $art->update({ views=>$rec->{views} }, { id=>$art_id });

        # Supply parameters for all article properties
        $tmpl->param( article_id        => $rec->{id} );
        $tmpl->param( article_createdby => Opera::View::Articles::format_author($rec) );
        # TODO Here we could format the date in any convenient way...
        $tmpl->param( article_createdon => $rec->{createdon} );

        $tmpl->param( article_lastupdateby => Opera::View::Articles::format_author($rec, 'lastupdateby') );
        $tmpl->param( article_lastupdateon => $rec->{lastupdateon} );

        $tmpl->param( article_title     => Opera::View::Articles::format_title($rec) );
        $tmpl->param( article_keywords  => Opera::View::Articles::format_keywords($rec) );
        $tmpl->param( article_views     => $rec->{views} );
        $tmpl->param( article_content => Opera::View::Articles::format_article($rec) );

        # Check permissions for cancel/modify buttons
        #
        # If user is admin, allow cancel and modify.
        # If not, allow remove/change only if logged user is the article author
        my $users = Opera::File::Users->new();
        my $current_user   = $self->session->param('user');
        my $is_admin       = $users->is_admin($current_user);
        my $modify_allowed = $is_admin || $current_user eq $rec->{createdby};

        $self->log('notice', 'Current user [', $current_user, '] is', ($is_admin ? '' : ' *NOT*'), ' an admin');

        if($current_user eq $rec->{createdby})
        {
            $self->log('notice', 'Current user [', $current_user, '] is the author of article');
        }

        $tmpl->param( article_remove_allowed => $modify_allowed );
        $tmpl->param( article_modify_allowed => $modify_allowed );

    }

    # Generate template output
    return $tmpl->output();
}

#
# Retrieve the latest n articles and build an html list with them
#
sub latest_n
{
    my $self  = $_[0];
    my $n     = $_[1] || 5;
    my $order = $_[2] || 'id DESC';

    # Load list from database.
    # Here a caching logic could save us from loading many times the same thing
    $self->log('notice', 'Getting list of articles');

    my $articles = Opera::File::Articles->new();
    my $art_list = $articles->list({
        fields => ['id', 'title', 'createdby', 'views'], 
        limit  => $n,
        order  => [ $order ],
    });

    if(!$art_list)
    {
        $self->log('notice', 'No articles for the top 10');
        return CGI::ol( CGI::li('No articles') );
    }

    my $html_list = '<ul>';

    $self->log('notice', scalar(@$art_list) . ' articles for the top 10');
    for my $art (@$art_list)
    {
        $html_list .= CGI->li(
              Opera::View::Articles::format_title($art)
            . ' by '
            . Opera::View::Articles::format_author($art)
        );
    }

    return($html_list);
}

sub best_n
{
    my($self, $n) = @_;
    $self->latest_n($n, 'views DESC, title ASC');
}

#
# In the real-world, this "cloud" should be generated maybe daily
# and then always cached...
#
sub tags_cloud
{
    my $self = $_[0];

    # We don't generate tag cloud if no module is available
    eval { require HTML::TagCloud };
    if($@)
    {
        $self->log('warn', 'Can\'t generate the tag cloud... No HTML::TagCloud module installed.');
        return;
    }

    # Ok, HTML::TagCloud is present
    my $cloud = HTML::TagCloud->new(levels=>20);
    my $articles = Opera::File::Articles->new();
    my %tags;

    # Get all distinct keywords from database and
    # obtain a frequency distribution
    my %tags = $articles->tags_frequency();

    for my $tag (keys %tags)
    {
        $cloud->add( $tag, 'articles_search?keyword='.CGI::escape($tag), $tags{$tag});
    }

    return $cloud->html_and_css(25);
}

1;

#
# End of class

=pod

=head1 NAME

Opera::Application::Articles - Controller tasks related to Articles section

=head1 SYNOPSIS

Not to be used directly. Is used by main Opera::Application class.

=head1 DESCRIPTION

Contains runmode methods related to Articles section, single article view,
modify and delete, articles search and "aggregate" methods such as "best"
articles, "latest" articles or tag cloud feature.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
