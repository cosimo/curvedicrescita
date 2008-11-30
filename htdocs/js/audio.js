// $Id$
function audio_play (url, is_loop)
{
    var el_name = '_my_sound';
    if (is_loop == undefined) is_loop = false;
    var emb;
    if (! (emb = document.getElementById(el_name))) {
        emb = document.createElement('embed');
    }
    emb.id = el_name;
    emb.src = url;
    emb.setAttribute('loop', is_loop);
    emb.setAttribute('autostart', true);
    emb.style.position = 'absolute';
    emb.style.left = -1000;
    document.body.appendChild(emb);
    return;
}
