# $Id$

package BabyDiary::Application::RSS;

use strict;
use Config::Auto;
use Encode;
use XML::RSS;

use BabyDiary::File::Articles;

sub articles {
    my ($how_many) = @_;

	my $conf = Config::Auto::parse('../conf/babydiary.conf');
    my $host = $conf->{root_uri};
	$host =~ s{/$}{};

    if (! defined $how_many) {
        $how_many = 25; 
    }

    my $rss = XML::RSS->new(version => '1.0'); #, encoding=>'ISO-8859-15');

    $rss->channel(
        title => 'CurveDiCrescita.com - Ultimi articoli',
        link  => "$host/exec/rss",
        description => 'Gli ultimi ' . $how_many . ' articoli pubblicati su curvedicrescita.com'
    );

    # Get last <how_many> articles
    my $art = BabyDiary::File::Articles->new();
    my $list = $art->list({
        fields => ['id', 'title', 'content', 'createdby', 'keywords'],
        order  => 'id DESC',
        limit  => $how_many,
    });

    if (! $list) {
        return;
    }

    for my $item (@{$list}) {
        $rss->add_item(
            title => decode('utf-8', $item->{title}),
            link  => $host . $art->url($item->{id}),
            description => decode('utf-8', $item->{content}),
        );
    }

    return $rss->as_string();
}

1;

