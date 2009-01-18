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

function draw_chart (gc, x, y) {
    gc.setColor('#f00');
    gc.setStroke(5);
    gc.drawLine(x, y, x+50, y+80);
    gc.paint();
    return;
}

function trigger_draw () {
    var gc = init_graphics('chart');
    var pos = element_position('chart');
    //opera.postError('x='+pos.x+' y='+pos.y);
    draw_chart(gc, pos.x, pos.y);
}

// Get a chart data
function get_baby_chart (baby_id, type) {
    // Call the server and get the ajax data
    // about this chart
    //var c = new BabyDiaryChart();
    //return c;
}

