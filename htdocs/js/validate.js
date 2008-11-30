// Form Validation Code - $Id$

// One shared object to rule them all... :-)
var val_xmlHttpReq = false;
var val_timer      = 0;

// Ajax call interface
// Is there a simpler AJAX code? I don't think so
function call(url, callback)
{
    // Terminate pending requests
    var req = xmlHttpReqHandle();
    if(!req) return;
    req.abort();
    // Open prepare new request
    req.open('GET', url, true);
    req.onreadystatechange = function()
    {
        if(!callback)
            return;
        if(req.readyState == 4 && req.status == 200)
            callback(req.responseText);
    }
    req.send(null);
}

// Flag a field as validation passed or failed
function field_flag(name, pass)
{
    // Change "<elem>_flag" image
    name += '_flag';
    var flag = document.getElementById(name);
    if(!flag) return;
    var newsrc = '/MyOperaTest/graphics/validate/';
    if     (pass=='0') newsrc += 'ko.gif'
    else if(pass=='1') newsrc += 'ok.gif';
    flag.src = newsrc;
    flag.hspace = 3;
    return;
}

// When user types anything, clear the field flag
// We should re-validate from the start
function clear_flag(elem)
{
    if(event.keyCode == 9) return;  // Tabs don't clear flag
    if(!elem) return;
    var name = elem.name + '_flag';
    var img = document.getElementById(name);
    if(!img) return;
    img.src = '/MyOperaTest/graphics/validate/blank.gif';
    return;
}

// Validate function
// form, field and value are used by 'validate' CGI
// html_id is the name of the div to be filled by response text
function validate (form, field, value, html_id)
{
    var url = '/cgi-bin/MyOperaTest/validate?form=' + escape(form) + '&field=' + escape(field) + '&value=' + escape(value);
    var replace_div = function (t)
    {
        var res    = t.split(';');
        var ok     = res[0];
        var reason = res[1];
        var json   = res[2];

        // If there's javascript code, eval it
        if(json) eval(json);

        // Check status and set element text and flag type (ok, ko)
        var elem = document.getElementById(html_id);
        if(!elem) alert('Element does not exist!')

        // Update flag image with a check(ok=1) or an error(ok=0)
        field_flag(field, ok);

        // Replace text in external div
        elem.innerHTML = reason;

        if(reason && ok=='0') {
            elem.style.background = '#fed';
            elem.style.border = '1px solid #fc8';
        } else {
            elem.style.background = '#fff';
            elem.style.border = '0px solid';
        }

    }

    // If already a timeout running, cancel it
    if(val_timer) clearTimeout(val_timer);

    // Run validation after 0.5 seconds
    val_timer = setTimeout( function () { call(url,replace_div) }, 500);

    return;
}

// Removes content from form_message div
function clearDiv (html_id)
{
    var elem = document.getElementById(html_id);
    if(elem) elem.innerHTML = '';
    return;
}

// Get handle to xmlHttpRequest object
function xmlHttpReqHandle ()
{
    if(val_xmlHttpReq) return val_xmlHttpReq;

    // For Explorer
    if(navigator.appName == "Microsoft Internet Explorer")
    {
        val_xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    else // For other browsers
    {
        val_xmlHttpReq = new XMLHttpRequest();
    }
    return(val_xmlHttpReq);
}
