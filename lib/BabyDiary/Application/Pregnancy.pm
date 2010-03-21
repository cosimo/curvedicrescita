package BabyDiary::Application::Pregnancy;

use strict;
use warnings;
use base q(BabyDiary::Application);

use DateTime;
use Date::Pregnancy ();

our @CHECKS;

sub birthdate {
	my ($day, $month, $year) = @_;

	my $dt = DateTime->new(
		year  => $year,
		month => $month,
		day   => $day,
	);

	return Date::Pregnancy::calculate_birthday(first_day_of_last_period => $dt);
}

sub current_week {
	my ($day, $month, $year) = @_;

	my $dt = DateTime->new(
		year  => $year,
		month => $month,
		day   => $day,
	);
	my $week = Date::Pregnancy::calculate_week(
		first_day_of_last_period => $dt,
	);
	return $week;
}

sub week_at_date {
	my ($day_dlp, $month_dlp, $year_dlp, $day, $month, $year) = @_;

	my $date = DateTime->new(
		day => $day,
		month => $month,
		year => $year,
	);

	my $dlp = DateTime->new(
		day => $day_dlp,
		month => $month_dlp,
		year => $year_dlp,
	);

	my $week = Date::Pregnancy::calculate_week(
		first_day_of_last_period => $dlp,
		date => $date,
	);

	return $week;
}

sub all_checks {

	if (@CHECKS) {
		return @CHECKS;
	}

    { "start": plusWeeks(um,13),
    "end": plusWeeks(um,13),
    "title": "Esami del sangue, urine e fattore RH",
    "description": "Termine entro cui eseguire gli esami gratis. Dovrà essere eseguito un esame del sangue completo, il gruppo sanguigno AB0 e Rh (D) qualora non eseguito prima del concepimento, l'esame delle urine e del sangue completi e nello specifico: Emocromo: Hb,GR,GB,HCT,PLT,IND. Deriv.,F.L.\nAspartato aminotransferasi (AST) (GOT) (S).\nAlanina aminotransferasi (ALT) (GPT) (S/U).\nVirus rosolia anticorpi (nel caso di lgG negative, entro la 17° settimana).\nToxoplasma anticorpi (E.I.A.), (in caso di lgG negative, ripetere ogni 30-40 giorni fino al parto).\nTreponema pallidum anticorpi (TPHA), qualora non eseguite prima del concepimento esteso al partner.\nTreponema pallidum anticorpi anticardiolipina (Flocculazione) (VDRL) (RPR), qualora non eseguite in funzione preconcezionale esteso al partner.\nVirus immunodeficienza acquisita Hiv 1-2 anticorpi.\nGlucosio (S/P/U/dU/La).\nAnticorpi anti eritrociti (Test di Coombs indiretto); in caso di donna Rh negativo a rischio di immunizzazione il testo deve essere ripetuto ogni mese; in caso di incompatibilità AB0 il test deve essere ripetuto alla 34°-36° settimana.",
    "durationEvent" : false },
    { "start": plusWeeks(um,13), //"2010-04-13",
    "end": plusWeeks(um,18), //"2010-05-18",
    "title": "Secondo appuntamento con il ginecologo",
    "description": "Il ginecologo valuta lo stato di salute del feto.",
    "link" : "http://www.curvedicrescita.com/exec/article/2009/04/06/meravigliosi-nove-mesi-secondo-trimestre",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,14),
    "end": plusWeeks(um,23),
    "title": "Esame completo delle urine",
    "description": "Esame completo delle urine, gratuito",
    "color" : "#009900",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,16), //"2010-05-04",
    "end": plusWeeks(um,18),     //"2010-05-18",
    "title": "Amniocentesi",
    "description": "Come la villocentesi, l'amniocentesi è una tecnica invasiva di diagnosi prenatale che presenta il rischio di indurre aborto nell'1% dei casi. Consiste nel prelievo di liquido amniotico il cui esame servirà a valutare l'assetto cromosomico fetale al fine di valutarne la normalità o la presenza di anomalie.",
    "link" : "http://www.curvedicrescita.com/exec/article/2009/02/10/valutazione-translucenza-nucale",
    "color" : "#ff0000",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,16),
    "end": plusWeeks(um,18),
    "title": "Esami ematochimici (tri-test)",
    "description": "Esame chiamato anche Tri-test ed utilizzato per la diagnosi delle anomalie cromosomiche. Viene eseguito nei casi a rischio per età maggiore o uguale a 35 anni o per anamnesi familiare o per scelta personale.",
    "color" : "#009900",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,19), //"2010-05-25",
    "end": plusWeeks(um,22),     //"2010-06-15",
    "title": "Terzo appuntamento con il ginecologo",
    "description": "Terzo appuntamento con il ginecologo",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,19), //"2010-05-25",
    "end": plusWeeks(um,22),     //"2010-06-15",
    "title": "Ecografia del secondo trimestre (morfologica)",
    "description": "Ecografia eseguita gratuitamente nella quale vengono prese in considerazione tutte le misure del feto, la presenza dell'osso nasale, la plica nucale ed eventuali anomalie.",
    "link" : "http://www.curvedicrescita.com/exec/article/2009/09/16/screening-cromosomopatie",
    "color" : "#ff66cc",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,24),
    "end": plusWeeks(um,27),
    "title": "Glucosio",
    "description": "Esame gratuito per la misurazione della glicemia: S/P/U/dU/La",
    "color" : "#009900",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,24),
    "end": plusWeeks(um,27),
    "title": "Minicurva da carico glicemico",
    "description": "Questo test consiste in una somminstrazione di 50 grammi di glucosio per via orale allo scopo di diagnosticare il diabete mellito.\nVengono effettuati due prelievi uno a digiuno e uno dopo 60 minuti dalla somministrazione del glucosio.",
    "color" : "#009900",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,23), //"2010-06-22",
    "end": plusWeeks(um,28),     //"2010-07-27",
    "title": "Quarto appuntamento con il ginecologo",
    "description": "Il ginecologo stabilirà il benessere fetale.",
    "link" : "http://www.curvedicrescita.com/exec/article/2009/07/03/meravigliosi-nove-mesi-terzo-trimestre",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,24), //"2010-06-29",
    "end": plusWeeks(um,40),    //"2010-07-27",
    "title": "Corso di preparazione al parto",
    "description": "Il corso di preparazione al parto dovrebbe essere fatto non solo su base teorica, ma con esercizi pratici di Training Autogeno Respiratorio",
    "link" : "http://www.curvedicrescita.com/exec/article/2008/10/30/training-autogeno-respiratoriotr",
    "color" : "#ffcc00",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,28),
    "end": plusWeeks(um,32),
    "title": "Esami del sangue e delle urine",
    "description": "Emocromo (Hb,GR,GB,HCT,PLT), Ferritina e urine sono gratuiti",
    "color" : "#ff6600",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,28),
    "end": plusWeeks(um,32),    
    "title": "Ecografia del terzo trimestre",
    "description": "L'ecografia del terzo trimestre è gratuita e viene eseguita per stabilire il peso fetale, la quantità di liquido amniotico, valutare l'anatomia fetale e diagnosticare eventuali malformazioni non presenti nella precedente ecografia.",
    "color" : "#ff66cc",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,29), //"2010-08-03",
    "end": plusWeeks(um,32),     //"2010-08-24",
    "title": "Quinto appuntamento con il ginecologo",
    "description": "Appuntamento per stabilire il benessere fetale",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,35),
    "end": plusWeeks(um,37),    
    "title": "Tampone vaginale e rettale",
    "description": "Tampone vaginale e rettale per la ricerca dello Streptococco beta-emolitico di Gruppo B, un batterio che potrebbe infettare il bambino durante il parto. L'infezione può presentarsi alla nascita o comparire più tardi fino al terzo mese di vita. Si può manifestare come polmonite, meningite, morte endouterina del feto e, più raramente, aborto. Ricordiamo pero' l'incidenza di infezione è molto bassa. Nel caso il tampone risultasse positivo verrà avviata una terapia antibiotica.",
    "color" : "#ffcc00",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,33),
    "end": plusWeeks(um,37),    
    "title": "Esame del sangue",
    "description": "Durante questo esame saranno gratuiti: virus epatite B (HBV); antigene HBsAg; virus epatite C (HCV) anticorpi; emocromo: Hb,GR,GB,HCT,PLT; virus immunodeficienza acquisita HIV 1-2 anticorpi",
    "color" : "#ff6600",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,33), //"2010-08-31",
    "end": plusWeeks(um,38),     //"2010-10-05",
    "title": "Sesto appuntamento con il ginecologo",
    "description": "Appuntamento per stabilire il benessere fetale",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,33),
    "end": plusWeeks(um,40),  
    "title": "Esame delle urine",
    "description": "Esame delle urine gratuito dalla settimana 33° alla 40°",
    "color" : "#ff6600",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,39),   //"2010-10-12",
    "end": plusWeeksDays(um,39,6), //"2010-10-12",
    "title": "Settimo appuntamento con il ginecologo",
    "description": "Appuntamento per stabilire il benessere fetale",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,40),   //"2010-10-19",
    "end": plusWeeksDays(um,40,6), //"2010-10-19",
    "title": "Ottavo appuntamento con il ginecologo",
    "description": "Appuntamento per stabilire il benessere fetale",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,40),   //"2010-10-26",
    "end": plusWeeks(um,42),       //"2010-10-26",
    "title": "Ecofalda",
    "description": "Si tratta di valutare la quantità e la qualità del liquido amniotico, poiché la sua diminuzione è il più importante segnale di una sofferenza fetale.",
    "color" : "#ffcc00",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,41),   //"2010-10-26",
    "end": plusWeeks(um,42),       //"2010-10-26",
    "title": "Cardiotocografia",
    "description": "Monitoraggio del battito cardiaco fetale. Visita gratuita",
    "color" : "#ffcc00",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,41),   //"2010-10-26",
    "end": plusWeeks(um,42),       //"2010-10-26",
    "title": "Nono appuntamento con il ginecologo",
    "description": "Se ancora non è nato, ultimo appuntamento per stabilire il benessere fetale",
    "color" : "#663300",
    "textColor" : "#000000",
    "durationEvent" : true },
    { "start": plusWeeks(um,40),//"2010-10-19T00:00:00",
    "end": plusWeeks(um,40),
    "title": "Data presunta del parto",
    "description": "Data presunta del parto, stimata in base alla data dell'ultima mestruazione",
    "textColor": "red",
    "classname": "timeline-important-event",
    "durationEvent" : false },
    { "start": now,
    "end": now,
    "title": "Oggi",
    "description": "Voi siete qui :)",
    "textColor": "red",
    "classname": "timeline-important-event",
    "durationEvent" : false }

}

	@CHECKS = (

		# --- Trimester 1 ---

		{
			name_it => 'Controllo genetico',
		    description_it => 'Questi controlli sono consigliati nei casi di familiarità a cromosomopatie o nel caso di genitori a stretto contatto con agenti chimici',
            week_start => 4,
			week_end => 7,
			mandatory => 0,
			trimester => 1,
		},

		{
			name_it => 'Primo appuntamento con il ginecologo',
            description_it => "Visita completa con Pap-test detto anche test di Papanicolaou dal nome del medico che sviluppò questo test per la diagnosi precoce dei tumori del collo dell'utero. Può dare anche utili indicazioni sull'equilibrio ormonale e permette di riconoscere la presenza di infezioni batteriche, virali o micotiche",
            url => 'http://www.curvedicrescita.com/exec/article/2009/09/14/prevenire-tumore-cervice-pap-test',
			week_start => 8,
			week_end => 12,
			mandatory => 1,
			trimester => 1,
		},

		{
			name_it => 'Villocentesi',
            description_it => "La villocentesi (opzionale) è una tecnica invasiva di diagnosi prenatale che presenta il rischio di indurre aborto nell'1% dei casi. Consiste nell'aspirazione di una piccola quantità di tessuto coriale (10-15 mg)",
            url => 'http://www.curvedicrescita.com/exec/article/2009/02/10/valutazione-translucenza-nucale',
			week_start => 10,
			week_end => 12,
			mandatory => 0,
			trimester => 1,
		},

		{
			name_it => 'Ecografia primo trimestre',
            description_it => "Con questa ecografia è possibile misurare la lunghezza del feto, valutare se il suo sviluppo corrisponde all'epoca di gravidanza valutata in base alla data dell'ultima mestruazione. Dalla fine del secondo mese si visualizza l'attività pulsatile del cuore, i movimenti fetali ed il numero dei feti",
            url => 'http://www.curvedicrescita.com/exec/article/2009/02/09/ecografia-gravidanza',
			week_start => '11w4d',
			week_end => '13w5d',
			mandatory => 1,
			trimester => 1,
		},

		{
			name_it => 'Translucenza nucale',
            description_it => "Durante l'ecografia del primo trimestre viene valutata la translucenza nucale, una raccolta di fluido compresa fra la cute e la colonna cervicale del feto. Maggiore è la misura di questo spazio, maggiore è il rischio di cromosomopatie",
            url => 'http://www.curvedicrescita.com/exec/article/2009/07/27/come-leggere-esame-translucenza-nucale',
			week_start => '11w4d',
			week_end => '13w5d',
			mandatory => 0,
			trimester => 1,
		},

		{
			name_it => 'Bi-test',
            description_it => "Si tratta di un test biochimico che viene combinato con quello dell'esame ecografico per formulare il rischio specifico per la Sindrome di Down e per la Trisomia 18. Nel campione di sangue di dosano due sostanze denominate free Beta HCG e PAPP-A(plasma proteina A associata alla gravidanza), che sono presenti in tutte le gravidanze. Nella maggioranza dei casi anomali queste sostanze sono presenti in quantità alterata",
            url => 'http://www.curvedicrescita.com/exec/article/2009/07/27/come-leggere-esame-translucenza-nucale',
			week_start => '11w4d',
			week_end => '13w5d',
			mandatory => 0,
			trimester => 1,
		},

		# --- Trimester 2 ---

		{
			name_it => 'Secondo appuntamento con il ginecologo',
			trimester => 2,
			week_start => 13,
			week_end => 18,
			mandatory => 1,
		},

		{
			name_it => 'Amniocentesi',
			trimester => 2,
			week_start => 16,
			week_end => 18,
			mandatory => 0,
		},

		{
			name_it => 'Terzo appuntamento con il ginecologo',
			trimester => 2,
			week_start => 19,
			week_end => 22,
			mandatory => 1,
		},

		{
			name_it => 'Ecografia del secondo trimestre',
			trimester => 2,
			week_start => 19,
			week_end => 22,
			mandatory => 1,
		},

		# --- Trimester 3 ---

		{
			name_it => 'Quarto appuntamento con il ginecologo',
			trimester => 3,
			week_start => 23,
			week_end => 28,
			mandatory => 1,
		},

		{
			name_it => 'Corso di preparazione al parto',
			trimester => 3,
			week_start => 24,
			week_end => 28,
			mandatory => 0,
		},

		{
			name_it => 'Quinto appuntamento con il ginecologo',
			trimester => 3,
			week_start => 29,
			week_end => 32,
			mandatory => 1,
		},

		{
			name_it => 'Ecografia del terzo trimestre',
			trimester => 3,
			week_start => 30,
			week_end => 32,
			mandatory => 1,
		},

		{
			name_it => 'Sesto appuntamento con il ginecologo',
			trimester => 3,
			week_start => 33,
			week_end => 38,
			mandatory => 1,
		},

		{
			name_it => 'Tampone vaginale e rettale',
			trimester => 3,
			week_start => 35,
			week_end => 37,
			mandatory => 1,
		},

		{
			name_it => 'Settimo appuntamento con il ginecologo',
			trimester => 3,
			week_start => 39,
			week_end => 39,
			mandatory => 1,
		},

		{
			name_it => 'Ottavo appuntamento con il ginecologo',
			trimester => 3,
			week_start => 40,
			week_end => 40,
			mandatory => 1,
		},

		{
			name_it => 'Ecofalda',
			trimester => 3,
			week_start => 41,
			week_end => 41,
			mandatory => 1,
		},

		{
			name_it => 'Cardiotocografia',
			trimester => 3,
			week_start => 41,
			week_end => 41,
			mandatory => 1,
		},

		{
			name_it => 'Nono appuntamento con il ginecologo',
			trimester => 3,
			week_start => 41,
			week_end => 41,
			mandatory => 1,
		}

	);

	return @CHECKS;

}

sub checks_at_week {

	my ($week) = @_;

	my @checks = all_checks();
	my @todo;

	for my $check (@checks) {

		my $week_start = $check->{week_start};
		my $week_end   = $check->{week_end};

		# Round to start of week for start date
		if ($week_start =~ m{^(\d+)w(\d+)d$}) {
			#$week_start = $1 + $2 * 1/7;
			$week_start = $1;
		}

		# Round to next week for end date
		if ($week_end =~ m{^(\d+)w(\d+)d$}) {
			#$week_end = $1 + $2 * 1/7;
			$week_end = $1 + 1;
		}

		if ($week >= $week_start && $week <= $week_end) {
			push @todo, $check;
		}

	}

	return @todo;

}

sub ical {
    my ($self) = @_;

    require Data::ICal;
    require Data::ICal::Entry::Event;
    require Date::ICal;

    my $year = $self->param('year');
    my $month = $self->param('month');
    my $day = $self->param('day');

    my $start_date = DateTime->new(
        year => $year,
        month => $month,
        day => $day
    );

    if (! $year || ! $month || ! $day || ! $start_date) {
        return
            "Content-type: text/plain\r\n\r\n"
            . "Data non valida\n";
    }

    $start_date = $start_date->epoch;

    my @checks = all_checks();
    my $calendar = Data::ICal->new();
    my $main_url = 'http://www.curvedicrescita.com/exec/article/2010/01/02/appuntamenti-visite-gravidanza';

    while (my $next_event = shift @checks) {
        my $ical_event = Data::ICal::Entry::Event->new();
        $next_event->{url} ||= '/pregnancy/week/' . $next_event->{week_start};
        $ical_event->add_properties(
            status   => 'INCOMPLETE',
            summary  => $next_event->{name_it},
            priority => $next_event->{mandatory} ? 4 : 5,
            dtstart  => ical_date($start_date, $next_event->{week_start}),
            dtend    => ical_date($start_date, $next_event->{week_end}, 1),
            url      => $main_url,
        );
        $calendar->add_entry($ical_event);
    }

    my $ics_content = $calendar->as_string();

    $self->header_props(
        '-type' => 'text/calendar',
        '-content-disposition' => 'attachment;filename=gravidanza.ics',
        '-content-length' => length($ics_content),
    );

    return $ics_content;
}

sub ical_date {
    my ($start, $plus_weeks, $end_of_week) = @_;

    my $start_secs = $start + 0;

    # Weeks/days (4w3d)
    if ($plus_weeks =~ m{^(\d+)w(\d+)d$}) {
        $plus_weeks = $2 + 7 * $1;
    }
    else { # Plain weeks number
        $plus_weeks *= 7;
    }

    $plus_weeks *= 86400;

    if ($end_of_week) {
        $plus_weeks += 86400 * 7 - 1;
    }

    $start_secs += $plus_weeks;

    my $ical_date = Date::ICal->new(epoch => $start_secs)->ical;
    return $ical_date;

}

1;

# vim: set ts=4 sw=4 tw=0 et
