# $Id$

package Opera::Locale::it;
use strict;
use base q(Opera::Locale);
use vars q(%Lexicon);

%Lexicon = (

    '__test__' => 'Il mio messaggio di test', # Used for testing, don't remove!

    # Menu bar
    'msg_menu_home'                       => 'Casa',
    'msg_menu_users'                      => 'Utenti',
    'msg_menu_articles'                   => 'Articoli',
    'msg_menu_help'                       => 'Aiuto',
    
    # Homepage
    'msg_home_title'                      => 'Questa &egrave; My Opera Test!',
    'msg_home_intro'                      => 'S&igrave;! Questa &egrave; l\'applicazione di test fatta da Cosimo. Se sei un utente registrato, esegui il login. Se non lo sei, puoi comunque cercare gli articoli, ma dovrai convincere qualche amico a crearti un utente ...',
    'msg_home_logged_title'               => 'Bentornato in MyOperaTest!',
    'msg_home_logged_intro'               => q(Ora puoi provare le sezioni <a href="<!-- tmpl_var mycgi_path -->/articles">articoli</a> e <a href="<!-- tmpl_var mycgi_path -->/users">utenti</a>, che permettono di <b>creare</b>, <b>modificare</b> e <b>rimuovere</b> articoli e utenti. Puoi anche cercare articoli per titoli e contenuti tramite la casella di ricerca sotto la barra del titolo. Se hai bisogno di un aiuto veloce, prova a consultare la <a href="<!-- tmpl_var mycgi_path -->/help">guida utente</a>.), 

    # Top bar
    'msg_topbar_logged'                   => 'Accedi come <b><!-- tmpl_var user --></b><!-- tmpl_if admin --> (<b>Amministratore</b>)<!-- /tmpl_if -->',
    'msg_topbar_mypage'                   => 'La mia pagina',
    'msg_topbar_myaccount'                => 'Il mio account',
    'msg_topbar_inbox'                    => 'La mia posta',
    'msg_topbar_mygroups'                 => 'I miei gruppi',
    'msg_topbar_logout'                   => 'Esci',
    
    # Title bar
    'msg_title_members'                   => 'utenti',

    # Articles section
    'msg_articles_title'                  => 'Archivio degli articoli',
    'msg_articles_intro'                  => 'Ricerca o crea nuovi articoli da questa pagina. Per modificare o cancellare un tuo articolo, ricercalo prima. Se hai bisogno di aiuto su queste funzionalit&agrave;, puoi guardare la fantastica <a href="<!-- tmpl_var mycgi_path -->/help">guida utente</a>.',

    # Articles search
    'Search results for &quot;[_1]&quot;' => 'Risultati della ricerca per &quot;[_1]&quot;',
    'No results'                          => 'Nessun risultato trovato in base ai criteri',
    
    # Articles sidebox
    'msg_articles_sb_title'               => 'Ricerca articoli',
    'msg_articles_sb_intro'               => 'Digita i termini di ricerca per trovare articoli nell\'archivio. Se non trovi nulla, puoi creare tu un nuovo articolo!',
    'msg_articles_sb_tags'                => 'Tag pi&ugrave; popolari',
    'msg_articles_sb_notags'              => 'Nessuna tag popolare...',
    'msg_articles_sb_latest'              => 'Articoli pi&ugrave; recenti',
    'msg_articles_sb_best'                => 'Articoli pi&ugrave; visti',
    'msg_articles_sb_nolatest'            => 'Nessun articolo in archivio...',

    # Users section
    'msg_users_title'                     => 'Gestione degli utenti',
    'msg_users_intro'                     => 'Da questa pagina &egrave; possibile cercare, modificare o creare profili utente. Se hai bisogno di aiuto su queste funzionalit&agrave;, puoi guardare la fantastica <a href="<!-- tmpl_var mycgi_path -->/help">guida utente</a>.',
    'msg_users_anon_title'                => 'Non puoi modificare o creare nessun profilo utente',
    'msg_users_anon_intro'                => 'Per modificare o creare profili devi prima effettuare l\' <!-- tmpl_var mycgi_path -->accesso all\'applicazione</a>',
    'msg_users_createnew'                 => 'Crea un nuovo profilo utente',

    # Users sidebox
    'msg_users_sb_title'                  => 'Ricerca utenti',
    'msg_users_sb_intro'                  => 'Digita il nome o parte di esso per cercare gli utenti nel database. Se non trovi nulla, puoi creare tu un nuovo profilo utente!',
    'msg_users_sb_inactive'               => 'Utenti pi&ugrave; inattivi',
    'msg_users_sb_inactive_explain'       => 'Tutti gli utenti sono attivissimi!',
   
    # Users form
    'msg_users_fld_username'              => 'Nome del nuovo profilo utente <small>(ex.: vrossi)</small>',
    'msg_users_fld_realname'              => 'Nome completo dell\'utente <small>(ex.: Valentino Rossi)</small>',
    'msg_users_fld_password'              => 'Parola chiave <small>(scegli qualcosa di segreto!)</small>',
    'msg_users_fld_password2'             => 'Ripeti password per conferma',
    'msg_users_fld_isadmin'               => 'Dare privilegi di amministratore? <small>(grande potere, grande responsabilit&agrave;!)</small>',
    'msg_users_fld_language'              => 'Lingua di localizzazione <small>(i messaggi dell\'applicazione cambieranno in base alla lingua)</small>',
    'msg_users_review'                    => 'Rivedi le informazioni prima della conferma',
    'msg_users_user'                      => 'Utente: ',
    'msg_users_username'                  => 'Nome utente <small>(non &egrave; possibile modificarlo)</small>',

    # Messaggi generici
    'msg_yes'                             => 'S&igrave;',
    'msg_no'                              => 'No',
    'msg_submit'                          => 'Ok, conferma',

    'Username too short'                  => 'Il nome utente &egrave; troppo corto. Dev\'essere almeno lungo 5 caratteri',
    'Username already taken'              => 'Il nome utente scelto &egrave; gi&agrave; utilizzato.',
    'Field "[_1]" is mandatory'           => 'Il campo "[_1]" &egrave; obbligatorio!',
    'Passwords don\'t match'              => 'Le password inserite non sono identiche',
);

1;

#
# End of class

=pod

=head1 NAME

Opera::Locale::it - Localized messages for italian language

=head1 SYNOPSIS

This class should B<not> be used directly, but rather through L<Opera::Locale> interface.

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
