# $Id$

# Base model class to access *every* type of file
package Opera::File::Base;

use strict;
use DBI;
use Carp;
use Opera::Logger;

#
# Internal methods for the innard works of the class
#

#
# Declare an accessor/mutator method for the class
# (read/write a property)
#
sub _ACCESSOR (@)
{
    no strict 'refs';
    my($pkg, @methods) = @_;
    for my $meth (@methods)
    {
        *{"$pkg\:\:$meth"} = sub {
            my $self = shift;
            my $ret_val;

            if(@_)
            {
                my $new_val = $_[0];
                $self->{"_$meth"} = $ret_val = $new_val;
            }
            else
            {
                no strict 'refs';
                my $class_meth = uc $meth;
                $ret_val = $self->{"_$meth"} || $self->$class_meth();
            }
            return($ret_val);
        };
    }
    return;
}

#
# Declare an abstract method for the class
# (a method that must be overridden in sub-classes)
#
sub _ABSTRACT (@)
{
    no strict 'refs';
    my($pkg, @methods) = @_;
    for my $meth (@methods)
    {
        *{"$pkg\:\:$meth"} = sub {
            croak(__PACKAGE__ . '::' . $meth . '() method must be implemented!');
        };
    }
    return;
}

#
# Takes care of initializing log channel and
# centralized logging, delegating to Opera::Logger class
#
sub log
{
    my($self, $level, @msg) = @_;
    my $logger;

    # Get log channel object
    if(! $self->{_log} )
    {
        $self->{_log} = Opera::Logger->new();
    }

    # Write information into the log channel
    if($logger = $self->{_log})
    {
        $logger->write($level, @msg);
    }

    return;
}

#
# Generic quoting for csv, text, whatever files
# 
sub quote
{
    my($self, $val) = @_;
    $val =~ s/'/\\'/g;
    return q(') . $val . q(');
}

1;

#
# End of class

