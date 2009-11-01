# $Id$

package BabyDiary::Locale::it;

use strict;
use base q(BabyDiary::Locale);
use vars q(%Lexicon);

# This is the base lexicon
%Lexicon = (

    _AUTO => 1,

    '__test__' => 'Il mio messaggio di test', # Used for testing, don't remove!
 
    map { $_ => $_ }

    'schede'
    ,'tags'
    ,'domande'
    ,'articoli'
    ,'curve'
    ,'ostetrica'
    ,'pediatra'
    ,'faq'
    ,'accedi'
    ,'registrati'
    ,'Registrazione del tuo profilo utente',
    ,'pubblica nuovo articolo'
    ,'esci'
    ,'scrivici',
    ,'cerca'
    ,'argomento'

    ,'tags popolari'
    ,'Ancora nessun articolo...'
    ,'Ancora nessuna domanda...',
    ,'i piu\' letti'
    ,'le piu\' lette',
    ,'ultimi articoli'
    ,'ultime domande',
    ,'archivio articoli'

    ,'Elenco delle tag'

    ,'Risultati della ricerca per &quot;[_1]&quot;'
    ,'Nessun risultato trovato in base ai criteri'

    ,'Username too short'
    ,'Username already taken'
    ,'Field "[_1]" is mandatory'
    ,'fai una domanda'
	,'Domande piu\' recenti'
);

1;

#
# End of class

=pod

=head1 NAME

BabyDiary::Locale::it - Localized messages for italian language

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
