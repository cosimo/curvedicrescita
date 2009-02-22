/*
	Charting library - http://www.curvedicrescita.com
	(c) 2008-2009 Cosimo Streppone, cosimo@streppone.it
    $Id$
*/

if (Chart == undefined) var Chart = function(div, type, width, height) {
    if (typeof div == "string") div = document.getElementById(div);
    this.div = div;

    // Create graphics context
    this.gc = new jsGraphics (div);
    if (! this.gc) return;
    this._init_graphics();

    // Get chart div origin
    this.origin = this._element_position(div);
	this.type = type;
    this.div.className = type;

	// Width and height, useful for title centering
	if (! width)  width = 600;
	if (! height) height = 400;
	this.width  = width;
	this.height = height;

    return this;
}

Chart.VERSION = 1.00;

Chart.prototype = {

    // Get an arbitrary html element position on screen
    _element_position: function (el) {
        var posx = 0, posy = 0;
        if (typeof el == "string") el = document.getElementById(el);
        if (el.offsetParent) {
            while (el.offsetParent) {
                posx += el.offsetLeft;
                posy += el.offsetTop;
                el = el.offsetParent;
            }
        }
        else if (el.x || el.y) {
            posx += el.x;
            posy += el.y;
        }

        // Return a position object (with x, y members)
        var p = new Object;
        p.x = posx;
        p.y = posy;
        return(p);
    },

    //
    // Public methods
    //

    clear: function () {
        this.gc.clear();
    },

    draw: function () {
        this.get_chart_data('/test/chart.json');
		return;
	},

	draw_chart_data: function (points) {

        var gc = this.gc;
        var origin = this.origin;
        gc.setStroke(2.4);

		var point_t0 = points[0];

		// TODO remove
		//this.draw_line( {age:0, weight:2}, {age:24, weight:15} );
		//this.draw_line( {age:0, weight:2}, {age:24, weight:16} );

        for (var i = 0; i < points.length; i++) {
            gc.setColor('#048');
            this.draw_line( point_t0, points[i] );
            point_t0 = points[i];
        }

        for (var i = 0; i < points.length; i++) {
			this.draw_box(points[i], 6);
        }

		gc.setFont('Tahoma','8px'); 
		gc.setColor('#000');
		//gc.drawString(this.type,this._to_chart_x(400),this._to_chart_y(50));

		this.draw_scale();

        gc.paint();
        return;
    },

    draw_box: function (center,size) {
		var gc = this.gc;
		var half_size = size / 2;
		var x = this._to_chart_x(center);
		var y = this._to_chart_y(center);
		x -= half_size;
		y -= half_size;
		gc.setColor('#fff');
		gc.fillRect(x, y, size, size);
		gc.setColor('#48f');
		gc.setStroke(1);
		gc.drawRect(x, y, size, size);
		//gc.drawEllipse(
		//    this._to_chart_x(points[i]) - 2,
		//    this._to_chart_y(points[i]) - 2,
		//    4, 4
		//);
	},

    draw_line: function (p1, p2) {
        // Find out positions on the chart
        var x1 = this._to_chart_x(p1);
        var y1 = this._to_chart_y(p1);
        var x2 = this._to_chart_x(p2);
        var y2 = this._to_chart_y(p2);
        this.gc.drawLine(x1, y1, x2, y2);
        return;
    },

	draw_scale: function () {
		var gc = this.gc;

		// X scale position
		var scale_pos = this._to_chart_y({weight: 1.2});
		for (var i = 0; i <= 24; i++) {
			gc.drawString(i, this._to_chart_x({age:i}) - 2, scale_pos);
		}
		gc.drawString('Mesi', this._to_chart_x({age:25}) - 6, scale_pos);

		// Y scale position
		scale_pos = this._to_chart_x({age:0}) - 12;
		for (var i = 2; i <= 15; i++) {
			gc.drawStringRect(i, scale_pos, this._to_chart_y({weight:i}) - 4, 10, 'right');
		}
		gc.drawString('Kg', scale_pos, this._to_chart_y({weight:16}) - 4);
		return;
	},

    // Get a chart data
    get_chart_data: function (url) {

        // Call the server and get the ajax data
        // about this chart
		var chart = this;
		call(url, function (text) {
			text += '; chart.draw_chart_data(points);';
			eval(text);
			//var code = 'var points = new Array(); points.push(';
			//code += text;
			//code += '); chart.draw_chart_data(points);';
			//eval(code);
		});
    },

	set_type: function (new_type) {
		switch (new_type) {
			case 'boys-wfa-0-2':
				this.offset_x = 15;
				this.scale_x  = 21.1;
				this.offset_y = 327;
				this.scale_y  = 21.4;
				break;
			case 'girls-wfa-0-2':
				this.offset_x = 15;
				this.scale_x  = 21.1;
				this.offset_y = 327;
				this.scale_y  = 22.9;
				break;
		}
		this.clear();
		this.type = new_type;
		this.div.className = new_type;
		this.draw();
    },

	set_title: function (text, color, x, y) {
		var gc = this.gc;
		if (! color) color = '#000';
		if (! x) x = this.origin.x;
		if (! y) y = this.origin.y;
		gc.setFont('Tahoma','14px', Font.BOLD); 
		gc.setColor(color);
		gc.drawStringRect(text, x, y, this.width, 'center');
		return;
	},

    //
    // Private members
    //
    _init_graphics: function () {
        // The resulting chart should be printable
        this.gc.setPrintable(true);
    },

    _to_chart_x : function (point) {
        var age = point.age;
		var x = this.offset_x;
		x += age * this.scale_x;
		x += this.origin.x;
        return x;
    },

    _to_chart_y : function (point) {
        var weight = point.weight;
		var y = this.offset_y - ((weight - 2.0) * this.scale_y);
		y += this.origin.y;
        return y;
    }

};
