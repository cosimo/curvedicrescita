// Timeline widget
var tl;
function onLoad() {
	var tl_el = document.getElementById("tl");
	var eventSource1 = new Timeline.DefaultEventSource();
	
	var theme1 = Timeline.ClassicTheme.create();
	theme1.autoWidth = true; // Set the Timeline's "width" automatically.
							 // Set autoWidth on the Timeline's first band's theme,
							 // will affect all bands.
	theme1.timeline_start = new Date(Date.UTC(2006, 0, 1));
	theme1.timeline_stop  = new Date(Date.UTC(2006, 11, 18));

	var d = Timeline.DateTime.parseGregorianDateTime("2006-01-12")
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
											   // timeline_data variable.
	tl.layout(); // display the Timeline
}

var resizeTimerID = null;
function onResize() {
	if (resizeTimerID == null) {
		resizeTimerID = window.setTimeout(function() {
			resizeTimerID = null;
			tl.layout();
		}, 500);
	}
}

