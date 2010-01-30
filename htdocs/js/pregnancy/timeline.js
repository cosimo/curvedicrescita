// Timeline widget, cosimo, 30/01/2010
var tl;
var resizeTimerID = null;

function getTimelineData(f) {
    var umy = parseInt(f.umy.value);
    var umm = parseInt(f.umm.value);
    var umd = parseInt(f.umd.value);
	var um = new Date(Date.UTC(umy, umm-1, umd));
    var timeline_data = {
        "dateTimeFormat": "iso8601",
        "url": "http://www.curvedicrescita.com/",
        "title": "Pregnancy check-ups",
        "events" : [
            { "start": um,
            "end": "",
            "title": "Data ultima mestruazione",
            "description": "Data dell'ultima mestruazione",
            "classname": "timeline-important-event",
            "durationEvent" : "false" },
            { "start": plusWeeks(um,4), //"2010-02-09",
            "end": plusWeeks(um,7), //"2010-03-02",
            "title": "Controllo genetico",
            "description": "Controllo genetico",
            "color" : "#0055ff",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,8), //"2010-03-09",
            "end": plusWeeks(um,12), //"2010-04-06",
            "title": "Primo appuntamento con il ginecologo",
            "description": "Primo appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,10), //"2010-03-23",
            "end": plusWeeks(um,12), //"2010-04-06",
            "title": "Villocentesi",
            "description": "Villocentesi",
            "color" : "#0055ff",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeksDays(um,11,4), //"2010-03-30",
            "end": plusWeeksDays(um,13,5), //"2010-04-13",
            "title": "Ecografia primo trimestre",
            "description": "Ecografia primo trimestre",
            "color" : "#0055ff",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeksDays(um,11,4),
            "end": plusWeeksDays(um,13,5),
            "title": "Translucenza nucale",
            "description": "Translucenza nucale",
            "color" : "#0055ff",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeksDays(um,11,4),
            "end": plusWeeksDays(um,13,5),
            "title": "Bi-test",
            "description": "Bi-test",
            "color" : "#0055ff",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,13), //"2010-04-13",
            "end": plusWeeks(um,18), //"2010-05-18",
            "title": "Secondo appuntamento con il ginecologo",
            "description": "Secondo appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,16), //"2010-05-04",
            "end": plusWeeks(um,18),     //"2010-05-18",
            "title": "Amniocentesi",
            "description": "Amniocentesi",
            "color" : "#008800",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,19), //"2010-05-25",
            "end": plusWeeks(um,22),     //"2010-06-15",
            "title": "Terzo appuntamento con il ginecologo",
            "description": "Terzo appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,19), //"2010-05-25",
            "end": plusWeeks(um,22),     //"2010-06-15",
            "title": "Ecografia del secondo trimestre",
            "description": "Ecografia del secondo trimestre",
            "color" : "#008800",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,23), //"2010-06-22",
            "end": plusWeeks(um,28),     //"2010-07-27",
            "title": "Quarto appuntamento con il ginecologo",
            "description": "Quarto appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,24), //"2010-06-29",
            "end": plusWeeks(um,28),     //"2010-07-27",
            "title": "Corso di preparazione al parto",
            "description": "Corso di preparazione al parto",
            "color" : "#aa5500",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,29), //"2010-08-03",
            "end": plusWeeks(um,32),     //"2010-08-24",
            "title": "Quinto appuntamento con il ginecologo",
            "description": "Quinto appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,30), //"2010-08-10",
            "end": plusWeeks(um,32),     //"2010-08-24",
            "title": "Ecografia del terzo trimestre",
            "description": "Ecografia del terzo trimestre",
            "color" : "#aa5500",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,33), //"2010-08-31",
            "end": plusWeeks(um,38),     //"2010-10-05",
            "title": "Sesto appuntamento con il ginecologo",
            "description": "Sesto appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,35), //"2010-09-14",
            "end": plusWeeks(um,37),     //"2010-09-28",
            "title": "Tampone vaginale e rettale",
            "description": "Tampone vaginale e rettale",
            "color" : "#aa5500",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,39),   //"2010-10-12",
            "end": plusWeeksDays(um,39,6), //"2010-10-12",
            "title": "Settimo appuntamento con il ginecologo",
            "description": "Settimo appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,40),   //"2010-10-19",
            "end": plusWeeksDays(um,40,6), //"2010-10-19",
            "title": "Ottavo appuntamento con il ginecologo",
            "description": "Ottavo appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,41),   //"2010-10-26",
            "end": plusWeeks(um,42),       //"2010-10-26",
            "title": "Ecofalda",
            "description": "Ecofalda",
            "color" : "#aa5500",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,41),   //"2010-10-26",
            "end": plusWeeks(um,42),       //"2010-10-26",
            "title": "Cardiotocografia",
            "description": "Cardiotocografia",
            "color" : "#aa5500",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeks(um,42),   //"2010-10-26",
            "end": plusWeeks(um,43),       //"2010-10-26",
            "title": "Nono appuntamento con il ginecologo",
            "description": "Nono appuntamento con il ginecologo",
            "color" : "#ff80cc",
            "textColor" : "#000000",
            "durationEvent" : "true" },
            { "start": plusWeeksDays(um,38,5), //"2010-10-19T00:00:00",
            "end": "",
            "title": "Data presunta del parto",
            "description": "Data presunta del parto, stimata in base alla data dell'ultima mestruazione",
            "textColor": "red",
            "classname": "timeline-important-event",
            "durationEvent" : "false" }
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
        var d = e.start;
        if (d instanceof Date) {
            e.start = toIso(d);
        }
        d = e.end;
        if (d instanceof Date) {
            e.end = toIso(d);
        }
    }

    return timeline_data;
}

function showTimeline(form) {
	var tl_el = document.getElementById("tl");
	var eventSource1 = new Timeline.DefaultEventSource();
	var theme1 = Timeline.ClassicTheme.create();
	theme1.autoWidth = true;
    var start_year = parseInt(form.umy.value);
    var start_month = parseInt(form.umm.value);
    var start_day = parseInt(form.umd.value);
    var start_date = form.umy.value + '-' + form.umm.value + '-' + form.umd.value;
	theme1.timeline_start = new Date(Date.UTC(start_year, start_month - 1, start_day));
	theme1.timeline_stop  = new Date(Date.UTC(start_year + 1, start_month - 1, start_day));
	var d = Timeline.DateTime.parseGregorianDateTime(start_date);
	var bandInfos = [
		Timeline.createBandInfo({
			width:          50,
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
    var timeline_data = getTimelineData(form);
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

