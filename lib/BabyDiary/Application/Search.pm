# $Id: Search.pm 357 2009-12-25 17:48:12Z cosimo_2 $

package BabyDiary::Application::Search;

use strict;
use BabyDiary::File::Articles;
use BabyDiary::File::Questions;
use Opera::Util;

#
# Display search results for articles or questions
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
    my $questions = BabyDiary::File::Questions->new();
    my $articles_list;
    my $questions_list;

    if(defined $keyword && $keyword ne '')
    {
        $keyword = Opera::Util::btrim($keyword);
        $articles_list = $articles->match({
			where => { published => {'<>', 0} },
            matchstring => $keyword,
            matchfields => 'title,keywords',
        });

        $questions_list = $questions->match({
			where => { published => {'<>', 0} },
            matchstring => $keyword,
            matchfields => 'title,keywords',
        });
    }
    elsif(defined $term && $term ne '')
    {
        $term = Opera::Util::btrim($term);

        $articles_list = $articles->match({
			where => { published => {'<>', 0} },
            matchstring => $term,
            matchfields => 'title,content,keywords',
        });

        $questions_list = $questions->match({
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

    # If some articles found, display them in a TMPL_LOOP
    if($articles_list)
    {

        my $count = scalar @{ $articles_list };
        $self->log('notice', 'Found ', $count, ' articles that match');

        $tmpl->param(search_results_articles_count => $count);

        for my $art (@{ $articles_list })
        {
            # Highlight keyword or term
            Opera::Util::highlight_term($keyword_or_term, \$art->{content});
            Opera::Util::highlight_term($keyword_or_term, \$art->{title});
            Opera::Util::highlight_term($keyword_or_term, \$art->{keywords});

            $art->{article_link}     = BabyDiary::View::Search::format_title_link($art);
            $art->{article_author}   = BabyDiary::View::Search::format_author($art);
            $art->{article_keywords} = BabyDiary::View::Search::format_keywords($art);
            $art->{article_excerpt}  = BabyDiary::View::Search::format_article_excerpt($art);

			# We have to repeat this, because format_article_excerpt() strips html
			Opera::Util::highlight_term($keyword_or_term, \$art->{article_excerpt});

        }

        $tmpl->param( search_results_articles => $articles_list);
    }

    if($questions_list)
    {

        my $count = scalar @{ $questions_list };
        $self->log('notice', 'Found ', $count, ' articles that match');
        
        $tmpl->param(search_results_questions_count => $count);

        for my $question (@{ $questions_list })
        {
            # Highlight keyword or term
            Opera::Util::highlight_term($keyword_or_term, \$question->{content});
            Opera::Util::highlight_term($keyword_or_term, \$question->{title});
            Opera::Util::highlight_term($keyword_or_term, \$question->{keywords});

            $question->{question_link}     = BabyDiary::View::Articles::format_title_link($question);
            $question->{question_author}   = BabyDiary::View::Articles::format_author($question);
            $question->{question_keywords} = BabyDiary::View::Articles::format_keywords($question);
            $question->{question_excerpt}  = BabyDiary::View::Articles::format_article_excerpt($question);
            $question->{question_answers}  = 11;

			# We have to repeat this, because format_article_excerpt() strips html
			Opera::Util::highlight_term($keyword_or_term, \$question->{question_excerpt});

        }

        $tmpl->param( search_results_questions => $questions_list );

    }

    # Generate template output
    return $tmpl->output();
}

1;

