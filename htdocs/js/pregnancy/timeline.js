// Timeline widget, cosimo, 30/01/2010
var tl;
var resizeTimerID = null;

function getTimelineData(f) {
    var umy = parseInt(f.umy.value);
    var umm = parseInt(f.umm.value);
    var umd = parseInt(f.umd.value);
    var um = getTheDamnDate(umy,umm,umd);
    var now = new Date();
    var timeline_data = {
        "dateTimeFormat": "iso8601",
        "url": "http://www.curvedicrescita.com/",
        "title": "Pregnancy check-ups",
        "events" : [
            { "start": um,
            "end": um,
            "title": "Data ultima mestruazione",
            "description": "Data dell'ultima mestruazione",
            "classname": "timeline-important-event",
            "durationEvent" : false },
            { "start": plusWeeks(um,4),
            "end": plusWeeks(um,4),
            "title": "Test di gravidanza",
            "description": "Puoi eseguire un test-stick acquistabile generalmente in farmacia. Dopo 12 giorni dal concepimento o 4 settimane dall'ultima mestruazione il test di gravidanza è in grado di rilevare l'HCG o la gonadotropina corionica umana, l'ormone il cui scopo è quello di creare l'ambiente ideale allo sviluppo dell'embrione e di bloccare le mestruazioni. Il test si esegue a casa immergendo il tampone assorbente nella prima urina del mattino.",
            "link" : "http://www.curvedicrescita.com/exec/article/2009/03/12/meravigliosi-nove-mesi-primo-trimestre",
            "durationEvent" : false },
            { "start": plusWeeks(um,4), //"2010-02-09",
            "end": plusWeeks(um,7), //"2010-03-02",
            "title": "Controllo genetico",
            "description": "Questi controlli sono consigliati nei casi di familiarità a cromosomopatie o nel caso di genitori a stretto contatto con agenti chimici.",
            "color" : "#ffcc00",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,8), //"2010-03-09",
            "end": plusWeeks(um,12), //"2010-04-06",
            "title": "Primo appuntamento con il ginecologo",
            "description": "Visita completa con Pap-test detto anche test di Papanicolaou dal nome del medico che sviluppò questo test per la diagnosi precoce dei tumori del collo dell'utero. Può dare anche utili indicazioni sull'equilibrio ormonale e permette di riconoscere la presenza di infezioni batteriche, virali o micotiche.",
            "link" : "http://www.curvedicrescita.com/exec/article/2009/09/14/prevenire-tumore-cervice-pap-test",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,10), //"2010-03-23",
            "end": plusWeeks(um,12), //"2010-04-06",
            "title": "Villocentesi",
            "description": "La villocentesi (opzionale) è una tecnica invasiva di diagnosi prenatale che presenta il rischio di indurre aborto nell'1% dei casi. Consiste nell'aspirazione di una piccola quantità di tessuto coriale (10-15 mg).",
            "link" : "http://www.curvedicrescita.com/exec/article/2009/02/10/valutazione-translucenza-nucale",
            "color" : "#ff0000",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeksDays(um,11,4), //"2010-03-30",
            "end": plusWeeksDays(um,13,5), //"2010-04-13",
            "title": "Ecografia primo trimestre",
            "description": "Con questa ecografia è possibile misurare la lunghezza del feto, valutare se il suo sviluppo corrisponde all'epoca di gravidanza valutata in base alla data dell'ultima mestruazione. Dalla fine del secondo mese si visualizza l'attività pulsatile del cuore, i movimenti fetali ed il numero dei feti.",
            "link" : "http://www.curvedicrescita.com/exec/article/2009/02/09/ecografia-gravidanza",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeksDays(um,11,4),
            "end": plusWeeksDays(um,13,5),
            "title": "Translucenza nucale",
            "description": "Durante l'ecografia del primo trimestre viene valutata la translucenza nucale, una raccolta di fluido compresa fra la cute e la colonna cervicale del feto. Maggiore è la misura di questo spazio, maggiore è il rischio di cromosomopatie.",
            "link" : "http://www.curvedicrescita.com/exec/article/2009/07/27/come-leggere-esame-translucenza-nucale",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeksDays(um,11,4),
            "end": plusWeeksDays(um,13,5),
            "title": "Bi-test",
            "description": "Si tratta di un test biochimico che viene combinato con quello dell'esame ecografico per formulare il rischio specifico per la Sindrome di Down e per la Trisomia 18. Nel campione di sangue di dosano due sostanze denominate free Beta HCG e PAPP-A(plasma proteina A associata alla gravidanza), che sono presenti in tutte le gravidanze. Nella maggioranza dei casi anomali queste sostanze sono presenti in quantità alterata.",
            "link" : "http://www.curvedicrescita.com/exec/article/2009/07/27/come-leggere-esame-translucenza-nucale",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
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
            "description": "Esame chiamato anche Tri-test ed utilizzato per la diagnosi delle anomalie cromosomiche. Viene eseguito nei casi a rischio per et� maggiore o uguale a 35 anni o per anamnesi familiare o per scelta personale.",
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
        ]
    };

    // Timeline only understands strings
    var events = timeline_data.events;
    var events_len = events.length;
    for (var i = 0; i < events_len; i++) {
        var e = events[i];
        // Assign a default classname if not present already
        // XXX disables colored events in the bottom band
        //if (! e.classname) e.classname = "timeline-normal-event";
        // Convert date objects to string
        //alert('i='+i+' e='+e+' e.title='+e.title+' e.start='+e.start);
        var d = e.start;
        if (d instanceof Date) { e.start = toIso(d); }
        d = e.end;
        if (d instanceof Date) { e.end = toIso(d); }
    }
    return timeline_data;
}

function getTheDamnDate(y,m,d) {
    var dt = y;
    dt += '/' + (m<10 ? '0' : '') + m;
    dt += '/' + (d<10 ? '0' : '') + d;
    var dt_obj = Timeline.DateTime.parseGregorianDateTime(dt);
    //alert('ymd='+y+','+m+',d='+d+' dt=['+dt+'] d_obj=['+dt_obj+']');
    return dt_obj;
}

function showTimeline(form) {
    var tl_el = document.getElementById("tl");
    var eventSource1 = new Timeline.DefaultEventSource();
    var theme1 = Timeline.ClassicTheme.create();
    theme1.autoWidth = true;
    var start_year = parseInt(form.umy.value);
    var start_month = parseInt(form.umm.value);
    var start_day = parseInt(form.umd.value);

    // IE needs the padding zeroes
    var start_date = getTheDamnDate(form.umy.value, form.umm.value, form.umd.value);
    theme1.timeline_start = getTheDamnDate(start_year, start_month, start_day);
    theme1.timeline_stop  = getTheDamnDate(start_year+1, start_month, start_day);
    theme1.mouseWheel = 'scroll';

    var timeline_data = getTimelineData(form);

    // Start 8 months from the last period date
    var n_months_after = 9;
    var tl_start_date;
    var tl_start_year = start_year + Math.floor((start_month + n_months_after) / 12);
    var tl_start_month = (start_month + n_months_after) % 12;
    tl_start_date = tl_start_year + '/' + tl_start_month + '/' + start_day;

    var d = Timeline.DateTime.parseGregorianDateTime(tl_start_date);

    var bandInfos = [
        Timeline.createBandInfo({
            width:          "50",   // as string, or IE chokes
            intervalUnit:   Timeline.DateTime.WEEK,
            intervalPixels: 80,
            trackHeight:    3,
            eventSource:    eventSource1,
            date:           d,
            theme:          theme1,
            timeZone:       +1,
            layout:         "original",
            syncWith:       1
        }),
        Timeline.createBandInfo({
            width:          "50",
            showEventText:  false,
            trackHeight:    1,
            intervalUnit:   Timeline.DateTime.MONTH,
            intervalPixels: 40,
            eventSource:    eventSource1,
            date:           d,
            theme:          theme1,
            timeZone:       +1,
            layout:         "overview"
        })
    ];
    bandInfos[1].syncWith = 0;
    bandInfos[1].highlight = true;
    tl = Timeline.create(tl_el, bandInfos, Timeline.HORIZONTAL);
    var url = '.';
    eventSource1.loadJSON(timeline_data, url);
    tl.layout();
}

function resizeTimeline() {
    if (resizeTimerID == null) {
        resizeTimerID = window.setTimeout(function() {
            resizeTimerID = null;
            if (tl) tl.layout();
        }, 500);
    }
}

function exportICal(form) {
    var start_year = parseInt(form.umy.value);
    var start_month = parseInt(form.umm.value);
    var start_day = parseInt(form.umd.value);
    var ical_url = '/exec/pregnancy/ical/' + start_year + '/' + start_month + '/' + start_day;
    return window.open(ical_url, 'pregnancy_calendar');
}

add_event("load",function () {
    var f = document.forms['pregdates'];
    showTimeline(f);
} );

