# $Id$

package BabyDiary::Application::StackTrace;

use strict;
use HTML::Entities ();

sub dump {

    my ($application) = @_;
    my @stack_trace = ();

    # Skip ourselves
    my $level = 2;

    while (my @call = caller($level)) {
        push @stack_trace, '<li>' . join(', ', @call) . '</li>';
        $level++;
    }

    return
        '<body style="background:white;color:#333;font-family:Monaco,\'Courier New\';font-size:12px">'
        . '<h1 style="font-family: \'Myriad Web Pro\';color:red;font-size:30px;border-bottom:1px solid red">Oops!</h1>'
        . '<p>The server generated an exception. Following information might help...</p>'
        . '<h2 style="font-family: \'Myriad Web Pro\';color:#333;font-size:24px;border-bottom:1px solid red">Error message</h2>'
        . '<p>' . HTML::Entities::encode_entities($application->{__error__} || 'none') . '</p>'
        . '<h2 style="font-family: \'Myriad Web Pro\';color:#333;font-size:24px;border-bottom:1px solid red">Stack trace</h2>'
        . '<ul>' . join("\n", @stack_trace) . '</ul>'
        . '<h2 style="font-family: \'Myriad Web Pro\';color:#333;font-size:24px;border-bottom:1px solid red">Environment</h2>'
        . $application->dump_html();

}

1;

