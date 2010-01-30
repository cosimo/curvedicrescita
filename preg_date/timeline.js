// Timeline widget, cosimo, 30/01/2010
(function(){
var tl;
var resizeTimerID = null;

function showTimeline(form) {
	var tl_el = document.getElementById("tl");
	var eventSource1 = new Timeline.DefaultEventSource();

	var theme1 = Timeline.ClassicTheme.create();
	theme1.autoWidth = true; // Set the Timeline's "width" automatically.
							 // Set autoWidth on the Timeline's first band's theme,
							 // will affect all bands.

    var start_year = parseInt(form.umy.value);
    var start_month = parseInt(form.umm.value);
    var start_day = parseInt(form.umd.value);

	theme1.timeline_start = new Date(Date.UTC(start_year, start_month - 1, start_day));
	theme1.timeline_stop  = new Date(Date.UTC(start_year + 1, start_month - 1, start_day));

	var d = Timeline.DateTime.parseGregorianDateTime(form.umy.value + '-' + form.umm.value + '-' . form.umd.value);

	var bandInfos = [
		Timeline.createBandInfo({
			width:          45,
			intervalUnit:   Timeline.DateTime.WEEK,
			intervalPixels: 50,
			eventSource:    eventSource1,
			date:           d,
			theme:          theme1,
			timeZone:       +1,
			layout:         'original'  // original, overview, detailed
		})
	];

	// create the Timeline
	tl = Timeline.create(tl_el, bandInfos, Timeline.HORIZONTAL);

	var url = '.'; // The base url for image, icon and background image
				   // references in the data
	eventSource1.loadJSON(timeline_data, url); // The data was stored into the 

	tl.layout(); // display the Timeline
}

function resizeTimeline() {
	if (resizeTimerID == null) {
		resizeTimerID = window.setTimeout(function() {
			resizeTimerID = null;
			if (tl) tl.layout();
		}, 500);
	}
}
);

