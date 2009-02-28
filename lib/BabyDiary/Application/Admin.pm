# $Id: Diary.pm 37 2008-10-28 22:50:53Z Cosimo $

package BabyDiary::Application::Admin;

use strict;

use BabyDiary::File::Articles;
use BabyDiary::File::Sessions;
use BabyDiary::File::Users;
use BabyDiary::File::UsersUnregistered;

sub front_page {
    my ($self) = @_;
    my $query = $self->query();

	my $art   = BabyDiary::File::Articles->new();
	my $users = BabyDiary::File::Users->new();
	my $unreg = BabyDiary::File::UsersUnregistered->new();
	my $sess  = BabyDiary::File::Sessions->new();

	my $total_art   = $art->count();

	my $total_users = $users->count();
	my $total_unreg = $unreg->count();
	my $total_sess  = $sess->count();
	
	my $total_article_views = $art->total_page_views();

	my @stat = (
		{
			stat_name => 'Totale articoli pubblicati',
			stat_value => $total_art,
		},
		{
			stat_name => 'Numero di utenti registrati',
			stat_value => $total_users
		},
		{
			stat_name => 'Numero di utenti non registrati',
			stat_value => $total_unreg,
		},
		{
			stat_name => 'Numero di sessioni aperte',
			stat_value => $total_sess,
		},
		{
			stat_name => 'Totale di visualizzazioni articoli',
			stat_value => sprintf('%s (%.2f in media)', $total_article_views, $total_article_views/$total_art),
		},
		{
			stat_name => 'Carico attuale sul server',
			stat_value => -e '/usr/bin/uptime' ? `uptime` : 'Non disponibile',
		},
	);

	my $tmpl = $self->render_view('admin/main.html');

	$tmpl->param(stats1 => \@stat);

	return $tmpl->output();
}

1;

#
# End of class
