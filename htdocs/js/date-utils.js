// Date utility functions, Cosimo, 30/01/2010
function daysInMonth(m, y) {
	return 32 - new Date(y, m, 32).getDate();
}

function plusDays(dt,days) {
    var t = new Date(dt);
    t.setDate(t.getDate() + days);
    return t;
}

function plusWeeks(dt,weeks) {
    return plusDays(dt, 7*weeks);
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

