// Date utility functions, Cosimo, 30/01/2010
function daysInMonth(m, y) {
	return 32 - new Date(y, m, 32).getDate();
}

function plusDays(dt,days) {
    var t = new Date(dt);
    while (days >= 30) {
        var m = t.getMonth();
        days -= daysInMonth(m, t.getFullYear());
        t.setMonth(1 + m);
    }
    while (days >= 7) {
        days -= 7;
        t.setDate(t.getDate() + 7);
    }
    if (days > 0) {
        t.setDate(t.getDate()+days);
    }
    return t;
}

function plusWeeks(dt,weeks) {
    var t = new Date(dt);
    while (weeks >= 4) {
        weeks -= 4;
        t.setMonth(t.getMonth() + 1);
    }
    if (weeks > 0) {
        t.setDate(t.getDate() + weeks * 7);
    }
    return t;
}

function plusWeeksDays(dt,weeks,days) {
    var t = plusWeeks(dt,weeks);
    t = plusDays(t,days);
    return t;
}

function toIso(dt) {
    var year = dt.getFullYear();
    var month = dt.getMonth() + 1;
    if (month < 10) month = "0" + month;
    var day = dt.getDate();
    if (day < 10) day = "0" + day;
    var result = year + "-" + month + "-" + day;
    //ert('toIso(dt)='+result);
    return result;
}

