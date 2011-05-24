package BabyDiary::Frontpage;

use Mojo::Base 'Mojolicious::Controller';

use lib '../../../lib';
use lib './lib';
use BabyDiary::File::Articles;

# This action will render a template
sub index {
  my $self = shift;

  my $art = BabyDiary::File::Articles->new();
  my $best = $art->best();

  $self->stash({
    hallo => 1,
    articles => {
      best => $best
    }
  });

  $self->render();
}

1;
