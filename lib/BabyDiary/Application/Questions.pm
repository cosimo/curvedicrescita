# $Id$
#
# TODO remove comments part and transform into answers
#

# Controller methods related to Questions section
package BabyDiary::Application::Questions;

use strict;
use CGI ();
use HTML::Entities;

use BabyDiary::File::Answers;
use BabyDiary::File::Favorites;
use BabyDiary::File::Questions;
use BabyDiary::File::Users;
use BabyDiary::View::Questions;
use Opera::Util;

#
# Delete an question that is in the database
#
sub delete
{
    my $self  = $_[0];
    my $query = $self->query();

    # Check if user is logged in before allowing delete
    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Don\'t allow to delete questions');
        $self->user_warning('Please login!', 'Login to application to delete questions');
        $self->forward('questions_latest');
    }

    # Check if question id was passed
    my $question_id = $self->query->param('id');
    if(! $question_id)
    {
        $self->log('warn', 'Delete of question without question_id...');
        $self->user_warning('Delete failed', 'Can\'t delete without question number');
        $self->forward('questions_latest');
    }

    # User can delete an question if:
    #
    # 1) user is an admin
    # 2) question original poster is the same user
    #
    my $users      = BabyDiary::File::Users->new();
    my $questions   = BabyDiary::File::Questions->new();
    my $curr_user  = $self->session->param('user');
    my $can_delete = $users->is_admin($curr_user)                  # User is an admin: can delete everything
                  || ($questions->owner($question_id) eq $curr_user);    # User is owner of this question

    if(!$can_delete)
    {
        $self->log('warn', 'Delete of question id ', $question_id, ' is not allowed.');
        $self->user_warning('Question delete not allowed', 'You are not the owner of the question. You are not allowed to delete it');
        $self->forward('questions_latest');
    }

    # Delete question record on db
    my $ok = $questions->delete({id=>$question_id});

    if($ok)
    {
        $self->log('notice', 'Deleted question id ', $question_id);
        $self->user_warning('Question deleted!', 'The selected question was deleted!', 'info');
    }
    else
    {
        $self->log('warn', 'Delete of question id ', $question_id, ' *FAILED*');
        $self->user_warning(
			'Question delete failed',
			'Sorry! The question wasn\'t deleted. There was some problem. Please retry later or report the problem at <b>info@curvedicrescita.com</b>'
		);
    }

    # Return to latest questions list
    return $self->redirect('/exec/question/latest');
}

#
# Display a form to modify question
#
sub modify
{
    my $self = $_[0];
    my $query = $self->query();

    # Check if user is logged in before allowing delete
    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Don\'t allow to modify questions');
        $self->user_warning('Please login!', 'Login to application to modify questions');
        return $self->forward('questions');
    }

    # Check if question id was passed
    my $question_id = $query->param('id');
    if(! $question_id)
    {
        $self->log('warn', 'Modify of question without question_id...');
        $self->user_warning('Modify failed', 'Can\'t modify without question number');
        $self->forward('questions');
    }

    $self->log('notice', 'Modifying question id ', $question_id);

    # Load current question
    my $users    = BabyDiary::File::Users->new();
    my $questions = BabyDiary::File::Questions->new();
    my $rec = $questions->get({
        where => { id => $question_id }
    });

    # Get name of current user
    my $curr_user  = $self->session->param('user');

    # Check that user can modify the question
    my $can_modify =
        $users->is_admin($curr_user)                     # User is an admin: can delete everything
        || ($questions->owner($question_id) eq $curr_user);    # User is owner of this question

    if(!$can_modify)
    {
        $self->log('warn', 'Modify of question id ', $question_id, ' is not allowed.');
        $self->user_warning('Question modify not allowed', 'You are not the owner of the question. You are not allowed to modify it');
        $self->forward('questions');
    }

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    # If question is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( question_content => '<h2>Articolo non trovato...</h2>' );
        return $tmpl->output();
    }

    # If we come from a modify request with all the needed data,
    # save the modified question now.
    if($query->request_method() eq 'POST')
    {

        # Update query on questions file
		my %to_update = (
			title    => scalar $query->param('title'),
            keywords => scalar $query->param('keywords'),
            content  => scalar $query->param('content'),
            published=> scalar $query->param('published'),
            private  => scalar $query->param('private'),
		);

		# If question *wasn't* published yet, don't update last modify by and timestamp.
		# We use the previous state, not the soon-to-be-new one
		my $published_state = exists $rec->{published} ? $rec->{published} : undef;

		# Question is live if 'published' > 0
		if (defined $published_state && $published_state > 0) {
			$to_update{lastupdateon} = Opera::Util::current_timestamp();
			$to_update{lastupdateby} = $curr_user;
		}

        my $update_ok = $questions->update(\%to_update, {id=>$question_id});

        # Return to question view page
        if(!$update_ok)
        {
            $self->user_warning('Errore nella modifica', 'Ci dispiace, ma la domanda non è stata modificata. C\'è stato un problema. Riprova più tardi.');
        }
        else
        {
            $self->user_warning('Domanda modificata', 'La domanda è stata modificata!', 'info');
        }

        return $self->forward('question');
    }

    # Question is found, display it nicely formatted
    $self->log('notice', 'Found question `', $rec->{title}, '\'');

    # Supply parameters for all question properties
    for(@{$questions->fields})
    {
        $tmpl->param( 'question_' . $_ => $rec->{$_} );
    }

	# Special case for 'published' drop-down list
	$tmpl->param('question_published_' . ($rec->{published}||'0') => 1);

    # Generate template output
    return $tmpl->output();
}


#
# Create a new question in the database
#
sub post
{
    my $self = $_[0];
    my $query = $self->query();

    # Check for user / password 
    $self->log('notice', 'Params received from question create/modify form');

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

    my $question = BabyDiary::File::Questions->new();
    my $posted = $question->post({
        title     => $prm{title},
        keywords  => $prm{keywords},
        createdby => $self->session->param('user'),
        content   => $prm{content},
		published => $prm{published},
        private   => $prm{private},
    });

    $self->log('notice', 'Posted question with title `', $prm{title}, '\' => ', ($posted?'OK':'*FAILED*'));

    # Return to questions page
    if(!$posted)
    {
        $self->redirect_with_user_message(
			"Errore nel post della domanda",
			$self->url_for('question/latest'),
			'warning'
		);
		return;
    }

	if ($self->config('send_questions_notification')) {

	    my $current_user = $self->session->param('user');

		require BabyDiary::Notifications;
		BabyDiary::Notifications::send_question_mail(
			$current_user,
			$posted,
			$prm{content},
		);
	}

    return $self->redirect_with_user_message(
		'La tua domanda &egrave; stata ricevuta. Grazie per il tuo contributo!',
		'question/latest',
		'notice',
	);

}

sub delete_comment {
	my ($self) = @_;

	my $query = $self->query;
	my $comment_id = $query->param('cid');
	my $question_id = $query->param('id');

	# Only numeric ids
	$comment_id =~ s{\D}{}g;
	$question_id =~ s{\D}{}g;

	# Only admins can delete comments
	my $is_admin = $self->session->param('admin');
	if (! $is_admin) {
		return $self->go_back_or_forward('question');
	}

	my $comm = BabyDiary::File::Comments->new();
	my $filter = { id => $comment_id };
	my $comment = $comm->get({ where => $filter });

	if (! $comment) {
		$self->user_warning(
			'Commento non trovato',
			q(Il commento da rimuovere non &egrave; stato trovato...)
		);
		return $self->forward('question');
	}

	my $deleted = $comm->delete({
		id => $comment_id
	});

	if (! $deleted) {
		$self->user_warning(
			'Commento non rimosso',
			q(C'&egrave; stato un problema nella cancellazione del commento.<br/>Per favore riprova pi&ugrave; tardi.)
		);
		return $self->forward('question');
	}

	# TODO: 'rtype' can differ from 'ART'
	my $questions = BabyDiary::File::Questions->new();
	my $slug = $questions->slug($question_id || $comment->{rid});
	my $prev_url = "/exec/question/$slug#comments";

	$self->header_type('redirect');
	$self->header_props(-url => $prev_url);

	return;
}

#
# Default view: list of latest questions
#
sub latest
{
    my ($self, $how_many) = @_;

	# By default, show how many
	$how_many ||= 15;

    my $questions = BabyDiary::File::Questions->new();

	# Not yet used here
	my $keyword_or_term = q{};

	# Get latest open questions
    my $list = $questions->list({
		where => {
			open => 7,
			published => { '<>' => 0 },
		},
		order => 'createdon DESC',
		limit => $how_many,
	});

    # Fill all template parameters
    my $tmpl = $self->fill_params();

	my $title = $self->msg(q(Domande piu' recenti));
    $tmpl->param(page_title => $title);

	# Highlight menu section
	$tmpl->param(questions_latest => 1);

    # If some questions found, display them in a TMPL_LOOP
    if ($list) {

        my $count = scalar @$list;
        $self->log('notice', 'Found ', $count, ' latest questions');

        my $fav = BabyDiary::File::Favorites->new();
	    my $current_user = $self->session->param('user');

        for my $question (@$list) {

            # Highlight keyword or term
            Opera::Util::highlight_term($keyword_or_term, \$question->{content});
            Opera::Util::highlight_term($keyword_or_term, \$question->{title});
            Opera::Util::highlight_term($keyword_or_term, \$question->{keywords});

            $question->{question_link}     = BabyDiary::View::Questions::format_title_link($question);
            $question->{question_author}   = BabyDiary::View::Questions::format_author($question);
            $question->{question_keywords} = BabyDiary::View::Questions::format_keywords($question);
            $question->{question_excerpt}  = BabyDiary::View::Questions::format_question_excerpt($question);
            $question->{question_private}  = $question->{private};

			# Necessary for the vote/favorite part to work
            $question->{question_reputation} = $question->{reputation};
            $question->{logged} = $self->user_logged;

			# For question deletion by admin
            $question->{admin} = $self->session->param('admin');
			$question->{cgi_root} = $tmpl->param('cgi_root');

			$question->{createdby_avatar} =
				BabyDiary::View::Questions::format_author_avatar($question);

			$question->{createdby} = BabyDiary::View::Questions::format_author($question);
			$question->{createdon} = Opera::Util::format_date_natural($question->{createdon});

            # Favorited?
            $question->{question_favorited} = $fav->check($current_user, 'question', $question->{id});

			# XXX Disabled for now, until we find a better design/layout
            #$question->{question_favorited_count} = $fav->how_many('question', $question->{id});

			# How many answers did we get?
			$question->{question_answers_count} = $questions->how_many_answers($question->{id});

			# To decide singular/plural word
			$question->{one_answer} = $question->{question_answers_count} == 1;

			# We have to repeat this, because format_question_excerpt() strips html
			Opera::Util::highlight_term($keyword_or_term, \$question->{question_excerpt});

        }

        $tmpl->param(latest_questions => $list);
    }

    # Generate template output
    return $tmpl->output();
}

# Display a form to post a new question
sub new_form
{
    my ($self) = @_;

    if(! $self->user_logged())
    {
        $self->log('warn', 'User is not logged in. Do not allow to post questions');
		my $msg = 'Accedi per fare una domanda';
		my $redir_url = $self->config('cgi_root')
			. '/question/latest?'
			. 'notice_message=' . CGI::escape($msg)
			. '&notice_class=warning';

        $self->redirect($redir_url);
    }

    $self->log('notice', 'Displaying form for new question');

    # Fill all template parameters
    my $tmpl = $self->fill_params();

	$tmpl->param(new_question => 1);
	$tmpl->param(questions_latest => 0);

    # Generate template output
    return $tmpl->output();
}

sub post_answer {
	my ($self) = @_;

	my $query = $self->query;
	my $question_id = $query->param('id');
	my $answer = $query->param('text');

	# Only numeric ids
	$question_id =~ s{\D}{}g;

	# Strip dangerous content from comment html
	$answer = BabyDiary::View::Questions::format_comment($answer);

	# Only registered and logged in users can comment
	my $current_user = $self->session->param('user');
	if (! $current_user) {
		my $msg = 'Devi accedere per poter rispondere a una domanda.';
		return $self->redirect_with_user_message($msg, 'question/latest', 'warning');
	}

	my $ans = BabyDiary::File::Answers->new();
	my $posted = $ans->post($question_id, $current_user, $answer);

	if (! $posted) {
		$self->log('warn', "Failed to post answer by $current_user to question $question_id");
		my $msg = q(C'&egrave; stato un problema nella pubblicazione della risposta.<br/>Per favore riprova pi&ugrave; tardi.);
		return $self->redirect_with_user_message($msg, 'question/latest', 'warning');
	}

	$self->log('notice', "Posted new answer by $current_user to question $question_id");

	if ($self->config('send_answers_notification')) {
		require BabyDiary::Notifications;
		BabyDiary::Notifications::send_answer_mail(
			$current_user,
			$question_id,
			$answer,
		);
	}

	my $questions = BabyDiary::File::Questions->new();
	my $slug = $questions->slug($question_id);
	my $prev_url = $self->url_for("question/$slug#last-answer");

	$self->log('notice', "Redirecting to question '$slug'");

	$self->redirect($prev_url);
	return;
}

sub post_comment {
	my ($self) = @_;

	my $query = $self->query;
	my $question_id = $query->param('id');
	my $comment    = $query->param('text');

	# Only numeric ids
	$question_id =~ s{\D}{}g;

	# Strip dangerous content from comment html
	$comment = BabyDiary::View::Questions::format_comment($comment);

	# Only registered and logged in users can comment
	my $current_user = $self->session->param('user');
	if (! $current_user) {
		$self->user_warning(
			'Accesso richiesto',
			'Per postare commenti agli questionicoli &egrave; richiesto l\'accesso.'
		);
		return $self->forward('question');
	}

	my $comm = BabyDiary::File::Comments->new();
	my $posted = $comm->post($question_id, $current_user, $comment);

	if (! $posted) {
		$self->user_warning(
			'Commento non pubblicato',
			q(C'&egrave; stato un problema nella pubblicazione del commento.<br/>Per favore riprova pi&ugrave; tardi.)
		);
		return $self->forward('question');
	}

	if ($self->config('send_comments_notification')) {
		require BabyDiary::Notifications;
		BabyDiary::Notifications::send_comment_mail(
			$current_user,
			$question_id,
			$comment
		);
	}

	my $questions = BabyDiary::File::Questions->new();
	my $slug = $questions->slug($question_id);
	my $prev_url = "/exec/question/$slug#last-comment";

	$self->redirect($prev_url);

	return;
}

#
# Display search results for questions, either from suggest-style search-box,
# or from keywords search
#
sub search
{
    my $self = $_[0];
    my $query = $self->query();

    # Search of questions can be by single keyword (field=keyword)
    # or by search query (field=q)
    my $term;
    my $keyword;

    if(defined($term = $query->param('q')))
    {
        $self->log('notice', 'Searching questions by term `', $term, '\'');
    }
    elsif(defined($keyword = $query->param('keyword')))
    {
        $self->log('notice', 'Searching questions by keyword `', $term, '\'');
    }

    # Load question (if present)
    my $questions = BabyDiary::File::Questions->new();
    my $list;

    if(defined $keyword && $keyword ne '')
    {
        $keyword = Opera::Util::btrim($keyword);
        $list = $questions->match({
			where => { published => {'<>', 0} },
            matchstring => $keyword,
            matchfields => 'title,keywords',
        });
    }
    elsif(defined $term && $term ne '')
    {
        $term = Opera::Util::btrim($term);
        $list = $questions->match({
			where => { published => {'<>', 0} },
            matchstring => $term,
            matchfields => 'title,content,keywords',
        });
    }

	my $keyword_or_term = $keyword || $term;

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    #
    # Add params and localized messages to display search results
    #
	my $title = $self->msg('Risultati della ricerca per &quot;[_1]&quot;', $keyword_or_term);

    $tmpl->param(
        page_title        => $title,
        search_title      => $title,
        search_no_results => $self->msg('Nessun risultato trovato in base ai criteri'),
    );

    # If some questions found, display them in a TMPL_LOOP
    if($list)
    {

        my $count = scalar @$list;
        $self->log('notice', 'Found ', $count, ' questions that match');
        
        $tmpl->param(search_results_count => $count);

        for my $question (@$list)
        {
            # Highlight keyword or term
            Opera::Util::highlight_term($keyword_or_term, \$question->{content});
            Opera::Util::highlight_term($keyword_or_term, \$question->{title});
            Opera::Util::highlight_term($keyword_or_term, \$question->{keywords});

            $question->{question_link}     = BabyDiary::View::Questions::format_title_link($question);
            $question->{question_author}   = BabyDiary::View::Questions::format_author($question);
            $question->{question_keywords} = BabyDiary::View::Questions::format_keywords($question);
            $question->{question_excerpt}  = BabyDiary::View::Questions::format_question_excerpt($question);
            $question->{question_private}  = $question->{private};

			# We have to repeat this, because format_question_excerpt() strips html
			Opera::Util::highlight_term($keyword_or_term, \$question->{question_excerpt});

        }

        $tmpl->param( search_results => $list );
    }

    # Generate template output
    return $tmpl->output();
}

#
# Display details about a single question
#
sub view
{
    my $self = $_[0];
    my $query = $self->query();

    # Required parameter: "id"
    my $question_id = $query->param('id');

    # it.answers.yahoo.com broken link
    $question_id =~ s{\D}{}g;

    $self->log('notice', 'Displaying question id:', $question_id);

    # Fill all template parameters
    my $tmpl = $self->fill_params();

    # Render selected question to template
    render($self, $tmpl, $question_id);

    # Generate template output
    return $tmpl->output();
}

sub render {
    my ($self, $tmpl, $question_id) = @_;

    # Load question (if present)
    my $ok  = 0;
    my $question = BabyDiary::File::Questions->new();

 	# Check if current visitor is an admin
	my $users = BabyDiary::File::Users->new();
	my $current_user = $self->session->param('user');
	my $is_admin = $users->is_admin($current_user);

	# Make sure that only admins (and authors) can see unpublished questions
	my @question_filter = $is_admin
		? ( )
		: ( published => {'<>', 0} )
		;

    # If no question selected, fetch the
	# front-page default one
    my $rec;

    if (defined $question_id)
    {
        $rec = $question->get({
            where => {
				@question_filter,
				id => $question_id,
			}
        });
    }

    #
    # Now overwrite content with a nicely formatted question content...
    #

    # If question is not found, display a notice
    if(!$rec)
    {
        $tmpl->param( question_content => "" );
    }
    # Question is found, display it nicely formatted
    else
    {
        $self->log('notice', 'Found question `', $rec->{title}, '\'');

        # Increase number of views of question (only for non-admin users)
        #
        # XXX This is obviously not going to work in this way for highly concurrent environments
        # Also, it can be a good idea to drop the whole concept of questions views, to avoid
        # database writes on every page view...

        # We don't want our admin work to impact on visit count
        if (! $is_admin) {
            $rec->{views}++;
            $question->update({ views=>$rec->{views} }, { id=>$question_id });
        }

        # Supply parameters for all question properties
        $tmpl->param(
			id                 => $rec->{id},
        	question_id        => $rec->{id},
        	question_createdby => BabyDiary::View::Questions::format_author($rec),
        	question_createdby_avatar => BabyDiary::View::Questions::format_author_avatar($rec),
        	question_createdon => Opera::Util::format_date_natural($rec->{createdon}),
        	question_lastupdateby => BabyDiary::View::Questions::format_author($rec, 'lastupdateby'),
        	question_lastupdateon => $rec->{lastupdateon},
            question_private   => $rec->{private},
		);

        # Replicate question title for document/page title
        my $question_title = BabyDiary::View::Questions::format_title($rec);

        $tmpl->param(

			page_title         => $question_title,
			question_title     => $question_title,
			question_keywords  => BabyDiary::View::Questions::format_keywords($rec),
			question_views     => $rec->{views},
			question_content   => BabyDiary::View::Questions::format_question($rec),
			question_published => $rec->{published},
			question_reputation=> $rec->{reputation},

			# Artificial published states for the drop-down list
        	'question_published_' . ($rec->{published} || '0') => 1,
		);

        # Check permissions for cancel/modify buttons
        #
        # If user is admin, allow cancel and modify.
        # If not, allow remove/change only if logged user is the question author
        my $modify_allowed = $is_admin || $current_user eq $rec->{createdby};

        $self->log('notice', 'Current user [', $current_user, '] is', ($is_admin ? '' : ' *NOT*'), ' an admin');

        if($current_user eq $rec->{createdby})
        {
            $self->log('notice', 'Current user [', $current_user, '] is the author of question');
        }

        $tmpl->param(
			question_remove_allowed => $modify_allowed,
        	question_modify_allowed => $modify_allowed,
		);

		# Favorited status
		my $fav = BabyDiary::File::Favorites->new();
		my $fav_status = $fav->check($current_user, 'question', $question_id);
		$tmpl->param( question_favorited => $fav_status );

        #
        # Build related questions section
        # 
        my @related = $question->related($question_id);
        $tmpl->param( question_related => \@related );

		render_answers($self, $tmpl, $question_id);

        $ok = 1;
    }

    return $ok;
}

sub render_answers {
	my ($self, $tmpl, $question_id) = @_;

	my $answers_allowed = 1;
	my $current_user = $self->session->param('user');
	if (! $current_user) {
		$answers_allowed = 0;
	}

	$tmpl->param( answers_allowed => $answers_allowed );

	my $ans = BabyDiary::File::Answers->new();
	my $answers_list = $ans->answers_by_question($question_id);
	if ($answers_list) {

		# How many answers found
		$tmpl->param(question_answers => scalar @{ $answers_list });

		my $is_admin = $self->session->param('admin');
		my %user_cache;
		my $users = BabyDiary::File::Users->new();

		for my $a (@{ $answers_list }) {

			#
			# Format username
			#
			my $username = $a->{createdby};

            # Special users are flagged so that comment is highlighted
            my $is_official = 0;
            if ($username eq 'tamara' || $username eq 'info@curvedicrescita.com') {
                $is_official = 1;
            }

			my $userdata;
			if (exists $user_cache{$username}) {
				$userdata = $user_cache{$username};	
			}
			else {
				$userdata = $users->get({ where => {username => $a->{createdby}} });
				$user_cache{$username} = $userdata;
			}

			$a->{createdby} = BabyDiary::View::Questions::format_author($a);
			$a->{createdon} = Opera::Util::format_date_natural($a->{createdon});

			$a->{createdby_avatar} =
				BabyDiary::View::Questions::format_author_avatar($userdata, 'username');

			$a->{admin} = $is_admin;
			$a->{question_id} = $question_id;

            # Answer is from someone that administers the site
            $a->{is_official} = $is_official;

		}

		$tmpl->param( answers_list => $answers_list );

	}

	return;
}

#
# Build the list of topics on the left sidebar
#
sub topics
{
    my ($self) = @_;
    my $keyword = 'scheda';

    # Load list from database.
    $self->log('notice', 'Getting list of questions for topics sidebar');

	# By default, don't show non-published questions
	my @question_filter = (
		published => { '<>', 0 },
	);

	# Admins must see everything
	my $is_admin = $self->session->param('admin');
	if ($is_admin) {
		@question_filter = ();
	}

    my $questions = BabyDiary::File::Questions->new();
    my $question_list = $questions->list({
        fields => ['id', 'title', 'createdby', 'views', 'published', 'lastupdateon'], 
        where  => {
			@question_filter,
			keywords => { LIKE => '%scheda%' },
		},
        order  => ['id'],
    });

    if (! $question_list) {
        $self->log('notice', 'No questions for the topics sidebar');
        return;
    }

    $self->log('notice', 'Found ' . scalar(@$question_list) . ' questions for the topics sidebar');

	my @two_weeks_ago = localtime(time() - 14 * 86400);
	my $thr_date = sprintf '%04d-%02d-%02d',
		$two_weeks_ago[5] + 1900,
		$two_weeks_ago[4] + 1,
		$two_weeks_ago[3];

	for my $question (@{$question_list}) {
		$question->{url} = $questions->url($question->{id});
		$question->{link} = BabyDiary::View::Questions::format_title_link($question);
		# Mark last-updated questions
		$question->{new} = $question->{lastupdateon} ge $thr_date ? 1 : 0;
	}

    return($question_list);
}

#
# Retrieve the latest n questions and build an html list with them
#
sub latest_n
{
    my $self  = $_[0];
    my $n     = $_[1] || 5;
    my $order = $_[2] || 'id DESC';

    # Load list from database.
    # Here a caching logic could save us from loading many times the same thing
    $self->log('notice', 'Getting list of questions');

	# By default, admins can see everything, even non-published questions
	my $is_admin = $self->session->param('admin');
	my @question_filter = (
		published => {'<>', 0}
	);

    my $questions = BabyDiary::File::Questions->new();
    my $question_list = $questions->list({
        fields => ['id', 'title', 'createdby', 'views', 'published'],
		where  => $is_admin
			? undef
			: { @question_filter },
        limit  => $n,
        order  => [ $order ],
    });

    if(!$question_list)
    {
        $self->log('notice', 'No questions for the top 10');
        return CGI::ul( CGI::li('No questions') );
    }

    my $html_list = '<ul>';

    $self->log('notice', scalar(@$question_list) . ' questions for the top 10');
    for my $question (@$question_list) {
        $html_list .= CGI->li(
        	BabyDiary::View::Questions::format_title_link($question)
        );
    }

    $html_list .= '</ul>';

    $self->log('notice', 'Latest n questions completed');

    return($html_list);
}

sub best_n
{
    my($self, $n) = @_;

    latest_n($self, $n, 'views DESC, title ASC');
}

sub worst_n
{
    my($self, $n) = @_;

    latest_n($self, $n, 'views ASC, title ASC');
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
    my $questions = BabyDiary::File::Questions->new();

    # Get all distinct keywords from database and
    # obtain a frequency distribution
    my %tags = $questions->tags_frequency();

    for my $tag (keys %tags)
    {
        $cloud->add( $tag, $self->url_for('home/article_search?keyword='.CGI::escape($tag)), $tags{$tag});
    }

    $self->log('notice', 'Tag cloud completed (' . scalar(keys %tags) . ' tags found)');

    return $cloud->html(25);
}

sub cumulus_cloud
{
    my $self = $_[0];
    my $questions = BabyDiary::File::Questions->new();
    my $html;
    my %tags = $questions->tags_frequency();

    # Limit n. of tags
    my $n = 30;

    for my $tag (sort { $tags{$b} <=> $tags{$a} } keys %tags)
    {

        my $font_size = 2 * $tags{$tag};
        $font_size = 10 if $font_size < 10;
        $font_size = 25 if $font_size > 25;

        $html .= '<a href="' . $self->url_for('home/article_search?keyword='.CGI::escape($tag)).
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

