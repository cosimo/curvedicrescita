// Cross browser event handling
function add_event (evt, cb, el) {
    if (! el) el = document;
    if (typeof el == 'string') el = document.getElementById(el);
    if (el.attachEvent) {
        evt = 'on' + evt;
        el.attachEvent(evt, cb);
    }
    else if (el.addEventListener) {
        el.addEventListener(evt, cb, false);
    }
}

