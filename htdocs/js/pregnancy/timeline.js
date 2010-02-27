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
            "description": "Puoi eseguire in test-stick",
            "durationEvent" : false },
            { "start": plusWeeks(um,4), //"2010-02-09",
            "end": plusWeeks(um,7), //"2010-03-02",
            "title": "Controllo genetico",
            "description": "Controllo genetico",
            "color" : "#ffcc00",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,8), //"2010-03-09",
            "end": plusWeeks(um,12), //"2010-04-06",
            "title": "Primo appuntamento con il ginecologo",
            "description": "Visita completa con Pap-test",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,10), //"2010-03-23",
            "end": plusWeeks(um,12), //"2010-04-06",
            "title": "Villocentesi",
            "description": "Villocentesi (opzionale)",
            "color" : "#ff0000",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeksDays(um,11,4), //"2010-03-30",
            "end": plusWeeksDays(um,13,5), //"2010-04-13",
            "title": "Ecografia primo trimestre",
            "description": "Ecografia primo trimestre",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeksDays(um,11,4),
            "end": plusWeeksDays(um,13,5),
            "title": "Translucenza nucale",
            "description": "Translucenza nucale",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeksDays(um,11,4),
            "end": plusWeeksDays(um,13,5),
            "title": "Bi-test",
            "description": "Bi-test",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,13),
            "end": plusWeeks(um,13),
            "title": "Esami del sangue, urine e fattore RH",
            "description": "Termine entro cui eseguire gli esami gratis",
            "durationEvent" : false },
            { "start": plusWeeks(um,13), //"2010-04-13",
            "end": plusWeeks(um,18), //"2010-05-18",
            "title": "Secondo appuntamento con il ginecologo",
            "description": "Secondo appuntamento con il ginecologo",
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
            "description": "Amniocentesi (opzionale)",
            "color" : "#ff0000",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,16),
            "end": plusWeeks(um,18),
            "title": "Esami ematochimici (tri-test)",
            "description": "Esami per la diagnosi delle anomalie cromosomiche",
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
            "description": "Ecografia del secondo trimestre, gratuita",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,24),
            "end": plusWeeks(um,27),
            "title": "Glucosio (S/P/U/dU/La)",
            "description": "Esame gratuito",
            "color" : "#009900",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,24),
            "end": plusWeeks(um,27),
            "title": "Minicurva da carico glicemico",
            "description": "Minicurva da carico glicemico",
            "color" : "#009900",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,23), //"2010-06-22",
            "end": plusWeeks(um,28),     //"2010-07-27",
            "title": "Quarto appuntamento con il ginecologo",
            "description": "Quarto appuntamento con il ginecologo",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,24), //"2010-06-29",
            "end": plusWeeks(um,40),    //"2010-07-27",
            "title": "Corso di preparazione al parto",
            "description": "Corso di preparazione al parto",
            "color" : "#ffcc00",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,28),
            "end": plusWeeks(um,32),
            "title": "Emocromo: Hb,GR,GB,HCT,PLT; Ferritina; Urine",
            "description": "Emocromo, ferritina e urine sono gratuiti",
            "color" : "#ff6600",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,28),
            "end": plusWeeks(um,32),    
            "title": "Ecografia del terzo trimestre",
            "description": "Ecografia del terzo trimestre, gratuita",
            "color" : "#ff66cc",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,29), //"2010-08-03",
            "end": plusWeeks(um,32),     //"2010-08-24",
            "title": "Quinto appuntamento con il ginecologo",
            "description": "Quinto appuntamento con il ginecologo",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,35),
            "end": plusWeeks(um,37),    
            "title": "Tampone vaginale e rettale",
            "description": "Tampone vaginale e rettale per la ricerca dello Streptococco beta-emolitico di Gruppo B",
            "color" : "#ffcc00",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,33),
            "end": plusWeeks(um,37),    
            "title": "Esame del sangue",
            "description": "Virus epatite B (HBV), antigene HBsAg, Virus epatite C (HCV) anticorpi; emocromo: Hb,GR,GB,HCT,PLT; virus immunodeficienza acquisita HIV 1-2 anticorpi sono esami gratuiti",
            "color" : "#ff6600",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,33), //"2010-08-31",
            "end": plusWeeks(um,38),     //"2010-10-05",
            "title": "Sesto appuntamento con il ginecologo",
            "description": "Sesto appuntamento con il ginecologo",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,33),
            "end": plusWeeks(um,40),  
            "title": "Esame delle urine",
            "description": "Esame delle urine gratuito",
            "color" : "#ff6600",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,39),   //"2010-10-12",
            "end": plusWeeksDays(um,39,6), //"2010-10-12",
            "title": "Settimo appuntamento con il ginecologo",
            "description": "Settimo appuntamento con il ginecologo",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,40),   //"2010-10-19",
            "end": plusWeeksDays(um,40,6), //"2010-10-19",
            "title": "Ottavo appuntamento con il ginecologo",
            "description": "Ottavo appuntamento con il ginecologo",
            "color" : "#663300",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,40),   //"2010-10-26",
            "end": plusWeeks(um,42),       //"2010-10-26",
            "title": "Ecofalda",
            "description": "Ecofalda",
            "color" : "#ffcc00",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,41),   //"2010-10-26",
            "end": plusWeeks(um,42),       //"2010-10-26",
            "title": "Cardiotocografia",
            "description": "Monitoraggio del battito cardiaco fetale, gratuita",
            "color" : "#ffcc00",
            "textColor" : "#000000",
            "durationEvent" : true },
            { "start": plusWeeks(um,41),   //"2010-10-26",
            "end": plusWeeks(um,42),       //"2010-10-26",
            "title": "Nono appuntamento con il ginecologo",
            "description": "Nono appuntamento con il ginecologo",
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
    var tl_start_date;
    var tl_start_year = start_year + Math.floor((start_month + 9) / 12);
    var tl_start_month = (start_month + 9) % 12;
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

