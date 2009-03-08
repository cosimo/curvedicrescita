# $Id$

# Controller methods related to Articles section
package BabyDiary::Application::Articles;

use strict;
use HTML::Entities;
use BabyDiary::File::Articles;
use BabyDiary::File::Users;
use Opera::Util;
use BabyDiary::View::Articles;

#
# Delete an article that is in the database
#
sub delete
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
    my $users      = BabyDiary::File::Users->new();
    my $articles   = BabyDiary::File::Articles->new();
    my $curr_user  = $self->session->param('user');
    my $can_delete = $users->is_admin($curr_user)                  # User is an admin: can delete everything
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
sub modify
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
    my $users    = BabyDiary::File::Users->new();
    my $articles = BabyDiary::File::Articles->new();
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
        $tmpl->param( article_content => '<h2>Articolo non trovato...</h2>' );
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

        return $self->forward('article');
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
sub post
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
        tr{<>}{}ds;
    }

    # Clean up content. Detect and strip html code, either
    # in "<...>" format, or "&lt;...&gt", or "<..."
    #$prm{content} =~ s/<[^>]*>?//g;
    #$prm{content} =~ s/&lt;[^>]*(&gt;)?//g;

    # Check credentials against password saved in users file
    my $art = BabyDiary::File::Articles->new();
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
sub search
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
    my $articles = BabyDiary::File::Articles->new();
    my $list;

    if(defined $keyword && $keyword ne '')
    {
        $keyword = Opera::Util::btrim($keyword);
        $list = $articles->match({
            matchstring => $keyword,
            matchfields => 'title,keywords',
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
        search_title      => $self->msg('Risultati della ricerca per &quot;[_1]&quot;', $keyword || $term),
        search_no_results => $self->msg('Nessun risultato trovato in base ai criteri'),
    );

    # If some articles found, display them in a TMPL_LOOP
    if($list)
    {

        my $count = scalar @$list;
        $self->log('notice', 'Found ', $count, ' articles that match');
        
        $tmpl->param(search_results_count => $count);

        for my $art (@$list)
        {
            # Highlight keyword or term
            highlight_term($term,    $art);
            highlight_term($keyword, $art);

            $art->{article_link}     = BabyDiary::View::Articles::format_title_link($art);
            $art->{article_author}   = BabyDiary::View::Articles::format_author($art);
            $art->{article_keywords} = BabyDiary::View::Articles::format_keywords($art);
            $art->{article_excerpt}  = BabyDiary::View::Articles::format_article_excerpt($art);
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
sub view
{
    my $self = $_[0];
    my $query = $self->query();

    # Required parameter: "id"
    my $art_id = $query->param('id');

    # it.answers.yahoo.com broken link
    $art_id =~ s{\D}{}g;

    $self->log('notice', 'Displaying article id:', $art_id);

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    # Render selected article to template
    render($self, $tmpl, $art_id);

    # Generate template output
    return $tmpl->output();
}

sub render {
    my ($self, $tmpl, $art_id) = @_;

    # Load article (if present)
    my $ok  = 0;
    my $art = BabyDiary::File::Articles->new();
   
    # If no article selected, fetch the latest
    my $rec;
    if (defined $art_id)
    {
        $rec = $art->get({
            where => { id => $art_id }
        });
    }
    else
    {
        $self->log('notice', 'Fetching latest article');
        my $list = $art->list({
            order => 'id DESC',
            limit => 1,
        });
        if ($list) {
            $rec = $list->[0];
            $art_id = $rec->{id};
        }
    }

    #
    # Now overwrite content with a nicely formatted article content...
    #

    # If article is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( article_content => '<h2>Nessun articolo trovato...</h2>' );
    }
    # Article is found, display it nicely formatted
    else
    {
        $self->log('notice', 'Found article `', $rec->{title}, '\'');

        # Increase number of views of article (only for non-admin users)
        #
        # XXX This is obviously not going to work in this way for highly concurrent environments
        # Also, it can be a good idea to drop the whole concept of articles views, to avoid
        # database writes on every page view...

        my $users = BabyDiary::File::Users->new();
        my $current_user   = $self->session->param('user');
        my $is_admin = $users->is_admin($current_user);

        # We don't want our admin work to impact on visit count
        if (! $is_admin) {
            $rec->{views}++;
            $art->update({ views=>$rec->{views} }, { id=>$art_id });
        }

        # Supply parameters for all article properties
        $tmpl->param( article_id        => $rec->{id} );
        $tmpl->param( article_createdby => BabyDiary::View::Articles::format_author($rec) );
        # TODO Here we could format the date in any convenient way...
        $tmpl->param( article_createdon => $rec->{createdon} );

        $tmpl->param( article_lastupdateby => BabyDiary::View::Articles::format_author($rec, 'lastupdateby') );
        $tmpl->param( article_lastupdateon => $rec->{lastupdateon} );

        # Replicate article title for document/page title
        my $article_title = BabyDiary::View::Articles::format_title($rec);
        $tmpl->param( article_title   => $article_title );
        $tmpl->param( page_title      => $article_title );
        $tmpl->param( article_keywords=> BabyDiary::View::Articles::format_keywords($rec) );
        $tmpl->param( article_views   => $rec->{views} );
        $tmpl->param( article_content => BabyDiary::View::Articles::format_article($rec) );

        # Check permissions for cancel/modify buttons
        #
        # If user is admin, allow cancel and modify.
        # If not, allow remove/change only if logged user is the article author
        my $modify_allowed = $is_admin || $current_user eq $rec->{createdby};

        $self->log('notice', 'Current user [', $current_user, '] is', ($is_admin ? '' : ' *NOT*'), ' an admin');

        if($current_user eq $rec->{createdby})
        {
            $self->log('notice', 'Current user [', $current_user, '] is the author of article');
        }

        $tmpl->param( article_remove_allowed => $modify_allowed );
        $tmpl->param( article_modify_allowed => $modify_allowed );

        #
        # Build related articles section
        # 
        my @related = $art->related($art_id);
        $tmpl->param( article_related => \@related );

        $ok = 1;
    }

    return $ok;
}

#
# Build the list of topics on the left sidebar
#
sub topics
{
    my ($self) = @_;
    my $keyword = 'scheda';

    # Load list from database.
    $self->log('notice', 'Getting list of articles for topics sidebar');

    my $articles = BabyDiary::File::Articles->new();
    my $art_list = $articles->list({
        fields => ['id', 'title', 'createdby', 'views'], 
        where  => q(keywords LIKE '%scheda%'),
        order  => ['id'],
    });

    if(!$art_list)
    {
        $self->log('notice', 'No articles for the topics sidebar');
        return;
    }

    $self->log('notice', 'Found ' . scalar(@$art_list) . ' articles for the topics sidebar');

    return($art_list);
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

    my $articles = BabyDiary::File::Articles->new();
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
              BabyDiary::View::Articles::format_title_link($art)
            #. ' di '
            #. BabyDiary::View::Articles::format_author($art)
        );
    }

    $html_list .= '</ul>';

    $self->log('notice', 'Latest n articles completed');

    return($html_list);
}

sub best_n
{
    my($self, $n) = @_;

    latest_n($self, $n, 'views DESC, title ASC');
}

#
# Show a page with all the tags sorted
#
sub tags
{
    my $self = $_[0];

    my $articles = BabyDiary::File::Articles->new();

    # Get all distinct keywords from database and
    # obtain a frequency distribution
    my %tags = $articles->tags_frequency();
    
    # Fill all template parameters
    my $tmpl = $self->fill_params();

    # Sort tags in order of popularity and display them
    my @tag_loop;
	my $base_path = $tmpl->param('mycgi_path');

    for (sort {$tags{$b} <=> $tags{$a}} keys %tags) {

        push @tag_loop, {

            tag => $_,
            occurrencies => $tags{$_},
			display => int(rand(2)) - 1,

			# No-globals policy require this
			mycgi_path => $base_path,

        };

    }

    $tmpl->param(tags => \@tag_loop);

    return $tmpl->output();
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
    my $articles = BabyDiary::File::Articles->new();

    # Get all distinct keywords from database and
    # obtain a frequency distribution
    my %tags = $articles->tags_frequency();

    for my $tag (keys %tags)
    {
        $cloud->add( $tag, $self->url_for('article_search?keyword='.CGI::escape($tag)), $tags{$tag});
    }

    $self->log('notice', 'Tag cloud completed (' . scalar(keys %tags) . ' tags found)');

    return $cloud->html(25);
}

sub cumulus_cloud
{
    my $self = $_[0];
    my $articles = BabyDiary::File::Articles->new();
    my $html;
    my %tags = $articles->tags_frequency();

    # Limit n. of tags
    my $n = 30;

    for my $tag (sort { $tags{$b} <=> $tags{$a} } keys %tags)
    {

        if ($tag eq 'scheda') {
            next;
        }

        # "Unpopular tags"
        #my $font_size = 50 / $tags{$tag};

        my $font_size = 2 * $tags{$tag};
        $font_size = 10 if $font_size < 10;
        $font_size = 25 if $font_size > 25;

        $html .= '<a href="' . $self->url_for('article_search?keyword='.CGI::escape($tag)).
            '" title="' . $tags{$tag} . ' ' . substr($tag, 0, 20) .
            '" rel="tag" class="tag-link-' . ($tags{$tag}) . '" style="font-size:' . $font_size . '">' .
            HTML::Entities::decode_entities($tag) . '</a>';

        last if 0 == $n--;

    }

    # Enclose everything in a <tags> element
    $html = '<tags>' . $html . '</tags>';
    $html = CGI::escape($html);

    return $html;
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
