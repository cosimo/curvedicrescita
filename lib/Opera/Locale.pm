# $Id$

# Localization package
package Opera::Locale;

use strict;
use base q(Locale::Maketext);

sub init
{
    my($class, @lng) = @_;
    $class = ref($class) || $class;

    # Default languages in order (en, no, it)
    @lng = qw(en no it) unless @lng;

    return $class->get_handle(@lng);
}

# Get all message ids.
# This is useful to fill a template for example.
sub all_messages
{
    my $self = $_[0];
    require Opera::Locale::en;
    return keys %Opera::Locale::en::Lexicon;
}

#
# Alias for maketext call
#
sub msg
{
    my($self, @args) = @_;
    $self->maketext(@args);
}

1;

#
# End of class

=pod

=head1 NAME

Opera::Locale - Language messages localization class

=head1 SYNOPSIS

    my $locale = Opera::Locale->init('it', 'en');
    print $locale->msg('Welcome dear [_1]', $user), "\n";
    print $locale->msg('Thank you'), "\n";

=head1 DESCRIPTION

Allows application to access localized messages in a quick and practical way.
Uses L<Locale::Maketext> under the cover.

Motivation for this "interface" class is B<loose coupling>. This class offers an
interface to Locale::Maketext so that should L::M change, it doesn't break
every application in the Opera::* namespace. You only have to modify Opera::Locale
code to make everything work again.

=head1 METHODS

Brief explanation of main methods for this class

=over -

=item init(@languages)

Constructor. Initializes Locale::Maketext object with a list of "preferred" languages.
Returns a L<Locale::Maketext> object reference.

=item all_messages()

Returns all message IDs contained in the english localization class.

=item msg($msg_id [,@params])

Returns the localized message identified by C<$msg_id>. If that has parameters, they should be supplied
in C<@params> array. See also the language specific classes (ex.: C<Opera::Locale::it>)

It is basically a wrapper around the Locale::Maketext->maketext() call.

=back

=head1 SEE ALSO

=over -

=item L<Locale::Maketext>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
