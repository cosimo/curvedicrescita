#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';

use CGI::Application::PSGI;
use Plack::Builder;
use BabyDiary::Application;

my $psgi_app = sub {
    my $env = shift;
    my $cgi_app = BabyDiary::Application->new({
        PARAMS => { cfg_file => '../conf/babydiary.conf' },
        QUERY => CGI::PSGI->new($env)
    });
    # Gentleman, start your PSGI engines!
    CGI::Application::PSGI->run($cgi_app);
};

builder {

    enable 'Plack::Middleware::Static', 
        path => qr{^/ (img/ | js/ | css/ | swf/ | favicon\.ico$) }x,
        root => '../htdocs',
        ;

    $psgi_app;
}

