// www.curvedicrescita.com - js chart code
// $Id$

// Based on wz_jsgraphics - www.walterzorn.com
function init_graphics (div) {
    var el = document.getElementById(div);
    var gc = new jsGraphics(el);
    if (! gc) return;
    return gc;
}

// Get an arbitrary html element position on screen
function element_position(el) {
    var posx = 0, posy = 0;
    if (typeof el == "string")
        el = document.getElementById(el);
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
}

function draw_chart (gc, origin) {
    gc.setStroke(3);
    var points = get_baby_chart(0, 0);
    var point_t0 = points[0];
    for (var i = 0; i < points.length; i++) {
        gc.setColor('#048');
        draw_line(
            gc, origin, point_t0, points[i]
        );
        point_t0 = points[i];
    }
    for (var i = 0; i < points.length; i++) {
        gc.setColor('#fff');
        gc.fillRect(
            origin.x + to_chart_x(points[i]) - 3,
            origin.y + to_chart_y(points[i]) - 3,
            6, 6
        );
        gc.setColor('#48f');
        gc.setStroke(2);
        gc.drawRect(
            origin.x + to_chart_x(points[i]) - 3,
            origin.y + to_chart_y(points[i]) - 3,
            6, 6
        );
        //gc.drawEllipse(
        //    origin.x + to_chart_x(points[i]) - 2,
        //    origin.y + to_chart_y(points[i]) - 2,
        //    4, 4
        //);
    }
    gc.paint();
    return;
}

function to_chart_x(point) {
    var age = point.age;
    var x = 44.5 + age * 22.5;
    return x;
}

function to_chart_y(point) {
    var weight = point.weight;
    var y = 342 - ((weight - 2.0) * 22.5);
    return y;
}

function draw_line (gc, origin, p1, p2) {
    // Find out positions on the chart
    var x1 = to_chart_x(p1);
    var y1 = to_chart_y(p1);
    var x2 = to_chart_x(p2);
    var y2 = to_chart_y(p2);
    x1 += origin.x;
    x2 += origin.x;
    y1 += origin.y;
    y2 += origin.y;
    gc.drawLine(x1, y1, x2, y2);
    return;
}

function trigger_draw () {
    var gc = init_graphics('chart');
    var pos = element_position('chart');
    //opera.postError('x='+pos.x+' y='+pos.y);
    draw_chart(gc, pos);
}

// Get a chart data
function get_baby_chart (baby_id, type) {
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

