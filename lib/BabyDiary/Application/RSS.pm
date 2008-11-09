# $Id: $

package BabyDiary::Application::RSS;

use strict;
use XML::RSS;

use BabyDiary::File::Articles;

sub articles {
    my ($how_many) = @_;
    my $host = 'http://192.168.1.4';

    if (! defined $how_many) {
        $how_many = 50; 
    }

    my $rss = XML::RSS->new( version => '0.9' );

    $rss->channel(
        title => 'CurveDiCrescita.com - Ultimi articoli',
        link  => "$host/exec/rss",
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

    for (@{$list}) {
        $rss->add_item(
            title => $_->{title},
            link  => "$host/exec/home/article/?id=$$_{id}"
        );
    }

    return $rss->as_string();
}

1;

