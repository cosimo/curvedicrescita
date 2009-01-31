/* www.curvedicrescita.com */

if (Chart == undefined) var Chart = function(div, cht_type) {
    if (typeof div == "string") div = document.getElementById(div);
    this.div = div;
    // Create graphics context
    this.gc = new jsGraphics (div);
    if (! this.gc) return;
    this._init_graphics();
    // Get chart div origin
    this.origin = this._element_position(div);
    this.div.className = cht_type;
    return this;
}

Chart.VERSION = 0.01;

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

    // Private methods
    _init_graphics: function () {
        // The resulting chart should be printable
        this.gc.setPrintable(true);
    },
   
    _to_chart_x : function (point) {
        var age = point.age;
        //var x = 44.5 + age * 22.5;
        var x = 84 + age * 39;
        return x;
    },

    _to_chart_y : function (point) {
        var weight = point.weight;
        //var y = 342 - ((weight - 2.0) * 22.5);
        var y = 420 - ((weight - 2.0) * 39);
        return y;
    },

    //
    // Public methods
    //

    clear: function () {
        this.gc.clear();
    },

    change_type: function (event) {
        var cls = this.div.className;
        if (cls == 'girls-wfa-0-2') cls = 'boys-wfa-0-2'
        else cls = 'girls-wfa-0-2';
        this.div.className = cls;
    },

    draw: function () {
        var gc = this.gc;
        var origin = this.origin;
        gc.setStroke(3);
        var points = this.get_baby_chart(0, 0);
        var point_t0 = points[0];

        for (var i = 0; i < points.length; i++) {
            gc.setColor('#048');
            this.draw_line( point_t0, points[i] );
            point_t0 = points[i];
        }

        for (var i = 0; i < points.length; i++) {
            gc.setColor('#fff');
            gc.fillRect(
                origin.x + this._to_chart_x(points[i]) - 3,
                origin.y + this._to_chart_y(points[i]) - 3,
                6, 6
            );
            gc.setColor('#48f');
            gc.setStroke(2);
            gc.drawRect(
                origin.x + this._to_chart_x(points[i]) - 3,
                origin.y + this._to_chart_y(points[i]) - 3,
                6, 6
            );
            //gc.drawEllipse(
            //    origin.x + this._to_chart_x(points[i]) - 2,
            //    origin.y + this._to_chart_y(points[i]) - 2,
            //    4, 4
            //);
        }
        gc.paint();
        return;
    },

    draw_line: function (p1, p2) {
        // Find out positions on the chart
        var x1 = this._to_chart_x(p1);
        var y1 = this._to_chart_y(p1);
        var x2 = this._to_chart_x(p2);
        var y2 = this._to_chart_y(p2);
        x1 += this.origin.x;
        x2 += this.origin.x;
        y1 += this.origin.y;
        y2 += this.origin.y;
        this.gc.drawLine(x1, y1, x2, y2);
        return;
    },

    // Get a chart data
    get_baby_chart: function (baby_id, type) {
        // Call the server and get the ajax data
        // about this chart
        //var c = new BabyDiaryChart();
        //return c;
        var points = new Array ();

        var point0 = new Object;
        point0.age = 0;
        point0.weight = 3.110;
        points.push(point0);

        var point = new Object;
        point.age = 1;
        point.weight = 4.4;
        points.push(point);

        var point2 = new Object;
        point2.age = 2;
        point2.weight = 5.4;
        points.push(point2);

        var point3 = new Object;
        point3.age = 3;
        point3.weight = 6.3;
        points.push(point3);

        return points;
    }

};
