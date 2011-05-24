package BabyDiary;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->plugin(tt_renderer => {
    template_options => {
      INCLUDE_PATH => '../templates'
    }
  });

  # Routes
  my $r = $self->routes;

  $r->route('/')->to('frontpage#index');

  # Normal route to controller
  #$r->route('/welcome')->to('example#welcome');
}

1;
