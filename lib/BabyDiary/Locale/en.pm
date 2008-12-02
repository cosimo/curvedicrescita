# $Id$

package BabyDiary::Locale::en;

use strict;
use base q(BabyDiary::Locale);
use vars q(%Lexicon);

%Lexicon = (

    '__test__' => 'My Test Message',          # Used for testing, don't remove!

    _AUTO => 1,

    'schede'           => 'cards',
    'tags'             => 'tags',
    'domande'          => 'questions',
    'curve'            => 'curves',
    'ostetrica'        => 'midwife',
    'pediatra'         => 'pediatrician',
    'faq'              => 'faq',
    'scrivici'         => 'contact us',
    'accedi'           => 'login',
    'registrati'       => 'signup',
    'Registrazione del tuo profilo utente' => 'New user signup',
    'pubblica nuovo articolo' => 'publish new article',
    'esci'             => 'logout',
    'cerca'            => 'search',
    'argomento'        => 'topic',

    'tags popolari'    => 'popular tags',
    'Ancora nessun articolo...' => 'No article yet...',
    'ultimi articoli'  => 'latest articles',
    'archivio articoli'=> 'articles archive',

    'Elenco delle tag' => 'Browse tags',

    # Articles search
    'Risultati della ricerca per &quot;[_1]&quot;' => 'Search results for &quot;[_1]&quot;',
    'Nessun risultato trovato in base ai criteri'  => 'No results',

    'Username too short' => 'Username too short',
    'Username already taken' => 'Username already taken',
    'Field "[_1]" is mandatory' => 'Field "[_1]" is mandatory',

);

1;

#
# End of class

=pod

=head1 NAME

BabyDiary::Locale::en - Localized messages for english language

=head1 SYNOPSIS

This class should B<not> be used directly, but rather through L<BabyDiary::Locale> interface.

=head1 DESCRIPTION

Defines all localized messages for one language. All messages are inside a public
C<%Lexicon> hash, as required by Locale::Maketext.

=head1 SEE ALSO

=over -

=item L<Locale::Maketext>

=back

=head1 AUTHOR

Cosimo Streppone L<cosimo@streppone.it>

=cut
