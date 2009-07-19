// Helper functions to get chart data from the form
// $Id$
function get_gender() {
	var e = document.getElementById('gender_f');
	if (!e) { return }
	return (e.checked ? 'f' : 'm');
}

function get_name() {
	var e = document.getElementById('name');
	if (!e) { return }
	return e.value;
}

function get_type() {
	var e = document.getElementById('chart_type');
	if (!e) { return }
	var type = e.options[e.selectedIndex].value;
	if (!type || (type != 'wfa' || type != 'hfa')) {
		e.selectedIndex = 0;
		type = 'wfa';
	}
	return type;
}

function date_from_text(text) {
	var date = new Date(text);
	return date;
}

function get_birthdate() {
	var e = document.getElementById('birthdate');
	if (!e) { return }
	var this_date = date_from_text(e.value);
	return this_date;
}

function months_diff (date1, date2) {
	if (! date1 || ! date2) {
		return;
	}		
	var t1 = date1.getTime();
	var t2 = date2.getTime();
	var diff = t2 - t1;
	diff = diff / 86400000;    // in days
	diff = diff / 30;          // in months
	return diff;
}

function get_points() {
	var form_el = document.getElementById('chart_form');
	// Fetch measures from form
	var birth = get_birthdate();
	var points = new Array();
	for (var i = 1; i <= 9; i++) {

		var date_el = document.getElementById('date_' + i);
		var meas_el = document.getElementById('measure_' + i);

		// Skip empty dates (missing fields)
		if (! date_el || date_el.value=='') {
			continue;
		}

		// Convert to a date object
		date_el = date_from_text(date_el.value);
		meas_el = meas_el.value;

		// Append a new point to the chart
		var new_point = {
			"age": months_diff(birth, date_el),
			"weight": meas_el
		};
		points.push(new_point);
	}
	return points;
}

function redraw_chart(chart) {
	if (! chart) {
		chart = cht;
	}
	// Chart not yet initialized
	if (chart) {
		chart.clear();
	}

	// Set type of chart and gender
	var chart_name = get_gender() == 'f' ? 'girls' : 'boys';
	chart_name = chart_name + '-' + get_type() + '-0-2';
	if (! cht) {
		cht = new Chart ('chart', chart_name, 557, 356);
	}

	cht.set_type(chart_name);
	cht.set_title('Curva di crescita di ' + get_name());

	// Get measure data from form and plot it
	var points = get_points();
	cht.draw_chart_data(points);
	return cht;
}

