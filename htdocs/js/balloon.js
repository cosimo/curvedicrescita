// $Id$
function display_balloon (link,div,x,y,url) {
    if (!div) div='balloon';
    var d=document.getElementById(div);
    if (!d) return;
    var l=document.getElementById(link);
    var dt=document.getElementById(div+'_content');
    if (!dt) return;
    d.style.left = x + 'px';
    d.style.top  = y + 'px';
    var hide_func = function () { hide_balloon(div) };
    if (l) l.addEventListener('click', hide_func, false);
    call(url, function (response_text) {
        dt.innerHTML = response_text;
        d.style.visibility='visible';
        d.style.zIndex=100;
    });
}

function hide_balloon (div) {
    if (!div) div='balloon';
    var d=document.getElementById(div);
    if (!d) return;
    d.style.visibility='hidden';
}

function toggle_balloon (link,div,x,y,url) {
    if (!div) div='balloon';
    var d=document.getElementById(div);
    if (!d) return;
    if (d.style.visibility=='visible')
        hide_balloon(div);
    else
        display_balloon(link,div,x,y,url);
}

