// Simple ajax function call - Cosimo 12/7/2008
// $Id: ajax.js 46 2008-11-08 11:04:04Z Cosimo $

var val_xmlHttpReq = false;
var val_timer      = 0;

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
        if(!callback) return;
        if(req.readyState == 4 && req.status == 200)
            callback(req.responseText);
    }
    req.send(null);
}

// Get handle to xmlHttpRequest object
function xmlHttpReqHandle ()
{
    //if(val_xmlHttpReq) return val_xmlHttpReq;
    if(navigator.appName == "Microsoft Internet Explorer")
        val_xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
    else
        val_xmlHttpReq = new XMLHttpRequest();
    return(val_xmlHttpReq);
}

