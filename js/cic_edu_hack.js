
// Convert a BUNCH of fields into a table.

// XXX TODO: move this server side!  And drive from DB!
var ids = [16,22,28,29,30,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51];
var maxRows = 5;
var arrayLength = ids.length;
var itemsPerRow = arrayLength / maxRows;

function createShowFunction(i) {
	return function (e) {
                var nextRow = i + 1;
                if (e.target.value.length > 0) {
                    CRM.$('#td_row_' + nextRow).show();
                } else {
                    CRM.$('#td_row_' + nextRow).hide();
                }
            }
}


CRM.$(document).ready(function () {


function hideEduConfirm() {
    for (var i = itemsPerRow; i < ids.length; i++) {
        CRM.$('#editrow-custom_' + i).hide();
    }

}

CRM.$(document).ready(function () {

    // Convert a BUNCH of fields into a table.


    var tableHtml =
        "<table border='1'>" +
        "<tr>" +
            "<th>School Name</th><th>Academic Level</th><th>Specialization</th><th>Start Date (Year)</th><th>(Expected) Year of Graduation</th>";
        "</tr>";

    var at = 0;
    for (var i = 0; i < maxRows; i++) {
        tableHtml += "<tr id='td_row_" + i + "'";
        if (i > 0 && CRM.$('#custom_' + ids[at]).val().length == 0) {
            tableHtml += " style='display:none'";
        }
        tableHtml += ">";

        for (var j = 0; j < itemsPerRow; j++) {
            CRM.$('#custom_' + ids[at]).change(createShowFunction(i));
            tableHtml += "<td id='td_custom_" + ids[at++] + "'></td>";
        }
        tableHtml += "</tr>";
    }

    tableHtml += "</table>";

    CRM.$(tableHtml).insertBefore('#editrow-custom_' + ids[0]);

    for (var i = 0; i < arrayLength; i++) {
        var el = CRM.$("#custom_" + ids[i])[0];
        while (el && el.className != 'content') {
            el = el.parentElement;
        }
        var to = CRM.$('#td_custom_' + ids[i])[0];
        el = CRM.$(el).detach();
        el.appendTo(to);
        console.log("moved #custom_" + ids[i] + "(" + el + ") to " + to);

        CRM.$('#editrow-custom_' + ids[i]).remove();
    }

    // XXX TODO: Add Java script to hide next row if previous row is empty


});
