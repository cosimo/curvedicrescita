// Cross browser event handling
// $Id: event-handler.js 186 2009-03-08 16:35:47Z cosimo $
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

