# $Id: FormValidator.pm,v 1.2 2007/06/05 21:55:15 cosimo Exp $

# Generic Form validation class
package Opera::FormValidator;

use strict;
use Opera::Locale;
use Opera::Logger;

# Singleton classes for locale and logging
our $locale;
our $logger;

#
# Create new instance of form validator object
#
sub new
{
    my($class, $opt) = @_;
    $class = ref($class) || $class;

    # Link this new object to locale class 
    # Form error messages must be localized
    # XXX init() wants a language list...
    $locale ||= Opera::Locale->init();

    # Validation routine must log error messages
    $logger ||= Opera::Logger->new();

    my $self = {
        _locale => $locale,
        _logger => $logger,
    };
    bless $self, $class;
}

#
# Access to locale class for localized messages
#
sub locale
{
    my $self = $_[0];
    return $self->{_locale};
}

#
# Access to logger class, for validation error messages
#
sub logger
{
    my $self = $_[0];
    return $self->{_logger};
}

#
# Call to validate a single field value and to have a response
#
sub validate
{
    no strict 'refs';

    my($self, $opt) = @_;
    my $form  = $opt->{form};
    my $field = lc $opt->{field};
    my $result= { ok => 1 };

    # Require form module
    my $vld_class = 'Opera::FormValidator::' . $form;
    eval "use $vld_class";
    if($@)
    {
        $self->logger->warn('Error in loading ', $vld_class, ' class: $@='.$@);
        return { ok => 0, reason => $@ };
    }

    # Call the function named after the field to be validated
    my $func = "${vld_class}::${field}";

    # Result from validate call is a hashref
    if(defined &$func)
    {
        $result = $func->($self, $opt);
    }

    return($result);
}

#
# Generic method to validate a whole form
#
sub validate_form
{
    my($self, $app, $form, $vars) = @_;
    my $status = 1;

    # Try to clean up user input and detect errors
    my $result;

    for my $fld (keys %$vars)
    {

        # Validate single field passing also the full record
        # This allows for *multi-field* validations (password/confirm_password
        # for example)
        $result = $self->validate({
            form   => $form,
            field  => $fld,
            value  => $vars->{$fld},
            record => $vars,
        });

        # Check validation status
        if(!$result->{ok})
        {
            $app->user_warning(
                # Title
                'Error in form data',
                # Message + Javascript code
                'Field "'. $fld. '" validation failed. ' . $result->{reason}
                . '<script language="javascript"> document.onload=function () { ' . $result->{json} . '; field_flag("'.$fld.'", "0"); } </script>'
            );
            $self->logger->warn('Error in form data', 'Field ', $fld, ' validation failed (', $result->{reason}, '). Please retry.');
            # Exit with validation failed
            $status = 0;
            last;
        }

    }

    # Form validation final status
    $self->logger->notice('Form ', $form, ' validation ', ($status ? 'successful!' : '*FAILED*'));
    return($status);
}

#
# Basic validation routine for not-null fields
#
sub not_null
{
    my($self, $opt) = @_;
    my $val = $opt->{value};
    my %res = ( ok => 1 );

    # Trim value
    $val = Opera::Util::btrim($val);

    if(!$val)
    {
        $logger->warn('Empty value');
        $res{ok} = 0;
        $res{reason} = $self->locale->msg('Field "[_1]" is mandatory', $opt->{field});
    }

    return \%res;
}

1;

#
# End of class

=head1 NAME

Opera::FormValidator - Generic form validation mechanism

=head1 SYNOPSIS

    my $app = Opera::Application->new();
    my $vld = Opera::FormValidator->new();

    # Validate a single field
    my $result = $vld->validate({ form=>'f1', field=>'name', value=>'Cosimo' });
    if($result->{ok}) {
        print 'Validation successful!';
    } else {
        print 'Validation failed because ', $result->{reason}, "\n";
        # Optional
        print 'JS code to execute on client: ', $result->{json}, "\n";
    }

    # Validate a whole form. To be simple, stops at first error.
    my $form = 'NewUser';  # Name of form to validate
                           # Must exist as 'Opera/FormValidator/<Form>.pm'
    # Fetch CGI parameters
    my %vars = $app->query->Vars();
    if(!$vld->validate_form($app, 'NewUser', \%vars)) {
        print 'Validation failed!';
    } else {
        print 'Validation successful!';
    }

=head1 METHODS

=over -

=item validate(\%opt)

Validates a single field value. C<%opt> hashref must contain 'form',
'field' and 'value' keys. 'form' is the name of validator class to be loaded
inside the C<Opera::FormValidator> namespace.

If 'form' is 'NewUser', class C<Opera::FormValidator::NewUser> is tried loading.
'field' value is the name of the method called to validate given value.

Return value of C<validate()> is a hashref structured as follows:

    $result = {
         ok      => 0                          # or 1 if validation succeeds,
        ,reason  => 'Mandatory field empty'    # Reason of error
        ,json    => '...'                      # Javascript code to be executed at client end
    };

=item validate_form($app, $form_name, \%vars)

Same as validate() but validates a whole form at once instead of a single field.
This time, it takes as parameters:

=over *

=item $app

Opera::Application object reference (to directly set a user warning, if needed)

=item $form_name

Name of form validator class to load (in the form C<Opera::FormValidator::${form_name}>.

=item \%vars

Hashref with all CGI params and values to be checked.

=back

=head1 SEE ALSO

Form validation instances in the C<Opera::FormValidator::*> classes.

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
