

/* global CRM, parseFloat, calculateText */

console.log("Defining TaxCalculator");

function TaxCalculator() {
    this.taxableElements = [];
    this.monitoredFields = [];
    var that = this;
    this.updateTotalFunction = function () {
        that.updateTotal();
    };
}
;

TaxCalculator.prototype.getProvinceId = function () {
    console.log("Undefined getProvinceId function");
    return "0";
};

TaxCalculator.prototype.getTaxRate = function () {
    switch (this.getProvinceId()) {
        case "1100":
            return 0.05; // Alberta
        case "1101":
            return 0.05; // 0.12; // British Columbia
        case "1102":
            return 0.05; // 0.13; // Manitoba
        case "1103":
            return 0.15; // New-Brunswick
        case "1104":
            return 0.15; // Newfoundland and Labrador
        case "1105":
            return 0.05; // Northwest Territories
        case "1106":
            return 0.15; // Nova Scotia
        case "1107":
            return 0.05; // Nunavut
        case "1108":
            return 0.13; // Ontario
        case "1109":
            return 0.14; // Prince Edward Island
        case "1110":
            return 0.05; // 0.14975; // Quebec
        case "1111":
            return 0.05; // 0.10; // Saskatchewan
        case "1112":
            return 0.05; // Yukon Territory
        default:
            return 0.00;
    }
};

TaxCalculator.prototype.getTaxTerm = function () {
    var provId = this.getProvinceId();
    switch (provId) {
        case "1100":
            return "GST"; // Alberta
        case "1101":
            return "GST"; // British Columbia
        case "1102":
            return "GST"; // Manitoba
        case "1103":
            return "HST"; // New-Brunswick
        case "1104":
            return "HST"; // Newfoundland and Labrador
        case "1105":
            return "GST"; // Northwest Territories
        case "1106":
            return "HST"; // Nova Scotia
        case "1107":
            return "GST"; // Nunavut
        case "1108":
            return "HST"; // Ontario
        case "1109":
            return "HST"; // Prince Edward Island
        case "1110":
            return "GST"; // Quebec
        case "1111":
            return "GST"; // Saskatchewan
        case "1112":
            return "GST"; // Yukon Territory
        default:
            return "Taxes";
    }
};

TaxCalculator.prototype.getTaxableTotal = function () {
    var ln = this.taxableElements.length;
    var taxableTotal = 0;

    for (var i = 0; i < ln; i++) {
        var selector = this.taxableElements[i];
        var inputElement = CRM.$(selector);
        if (inputElement.attr("type") === "text") {
            taxableTotal += Number(inputElement.val());
        } else if (inputElement.is(":checked")) {
            taxableTotal += Number(inputElement.attr("data-amount"));
        }
    }
    return taxableTotal;
};

TaxCalculator.prototype.getTaxAmount = function () {
    var taxRate = this.getTaxRate();
    var taxesTotal = taxRate ? this.getTaxableTotal() * taxRate : 0;
    return parseFloat(Math.round(taxesTotal * 100) / 100).toFixed(2);
};


TaxCalculator.prototype.addOnChange = function (inputField) {
    if (this.monitoredFields.indexOf(inputField.attr("id")) >= 0) {
        // already being monitored.
        return;
    }
    if (inputField.attr("id") === CRM.$(".Taxes-section div input").attr("id")) {
        // we just can't monitor that field.  THat would create an infinite loop.
        return;
    }

    inputField.on('change', this.updateTotalFunction);
    inputField.on('input', this.updateTotalFunction);

    this.monitoredFields.push(inputField.attr("id"));
    console.log("Field " + inputField.attr("id") + " now being monitored for changes and tax updates");
};


/**
 * 
 * @param {type} provinceFieldId_or_provinceIdGetter        Either a function that retrieves the province id
 *                                                          or a string that is the id (including the '#') of
 *                                                          the field that is the province.  If specifying an
 *                                                          id, then event handlers will be added to the province
 *                                                          so that if it changes, taxes are updated.
 *                                                          
 *                                                          
 * @returns {undefined}
 */
TaxCalculator.prototype.install = function (provinceFieldId_or_provinceIdGetter) {
    var that = this;
    that.createTaxesReadOnlySection();

    // get list of fields to which taxes apply.
    that.refreshFields();

    if (typeof provinceFieldId_or_provinceIdGetter === "string") {
        var provinceField = CRM.$(provinceFieldId_or_provinceIdGetter);
        that.addOnChange(provinceField);
        that.getProvinceId = function () {
            return provinceField.val();
        };
    } else {
        that.getProvinceId = provinceFieldId_or_provinceIdGetter;
    }

    this.updateTotal();
};

TaxCalculator.prototype.uninstall = function () {
    var ln = this.monitoredFields.length;
    for (var i = 0; i < ln; i++) {
        var toUnbind = CRM.$('#' + this.monitoredFields[i]);
        toUnbind.unbind('change', this.updateTotal);
        toUnbind.unbind('input', this.updateTotal);
    }
};

TaxCalculator.prototype.refreshFields = function () {
    var that = this;

    // clear
    that.taxableElements = [];

    // get list of taxable fields
    CRM.$(".crm-section div input[type=text]").each(function () {
        var label = CRM.$(this).parent().prev().children().first();
        var labelText = label.text();
        if (labelText.indexOf(" (taxable)") !== -1) {
            console.log("Including text " + label.attr("for") + " in tax calculation");
            that.taxableElements.push('#' + label.attr("for"));
        }
    });

    // Remove (taxable) from labels, and use " + tax" after amount instead
    CRM.$(".crm-price-amount-label").each(function ( ) {
        var labelSpan = CRM.$(this);
        var labelSpanText = labelSpan.text();
        if (labelSpanText.indexOf(" (taxable)") !== -1) {
            var amountElement = CRM.$(this).next();
            if (amountElement.length > 0) {
                amountElement.append(" + tax");
                labelSpan.text(labelSpanText.replace(" (taxable)", ""));
                var label = labelSpan.parent();
                that.taxableElements.push('#' + label.attr("for"));
            } else {
                var oldText = CRM.$(this).parent().html();
                var newText = oldText.replace(" (taxable)", "");
                newText = newText + " + tax";
                var parent = CRM.$(this).parent();
                var forInputField = parent.attr("for");
                parent.html(newText);
                that.taxableElements.push('#' + forInputField);
            }
        }
    });

    var ln = that.taxableElements.length;
    for (var i = 0; i < ln; i++) {
        that.addOnChange(CRM.$(that.taxableElements[i]));
    }

    CRM.$("input[price]").each(function () {
        that.addOnChange(CRM.$(this));
    });

    // Hide "mandatory tax contribution field"
    CRM.$(".Taxes-section").hide();

};



TaxCalculator.prototype.createTaxesReadOnlySection = function () {
    var taxesReadOnlySection = CRM.$("#taxesReadOnlySection");
    if (taxesReadOnlySection.length === 0) {
        var priceSetTotalSection = CRM.$("#pricesetTotal");
        var html =
                "<div id='#taxesReadOnlySection' class='crm-section'>" +
                "<div class='label'>" +
                "<label for='taxesReadOnly' id='taxesReadOnlyLabel'>Taxes</label>" +
                "</div>" +
                "<div class='content calc-value' id='taxesReadOnlyAmount'>" +
                "<b>$</b> 0.00" +
                "</div>" +
                "</div>";
        CRM.$(html).insertBefore(priceSetTotalSection);
    }
};


TaxCalculator.prototype.updateTotal = function () {
    console.log("Updating taxes");
    var readOnlyTaxes = CRM.$("#taxesReadOnlyAmount");
    var taxAmount = this.getTaxAmount();
    readOnlyTaxes.html("<b>$</b> " + taxAmount);

    var taxLabel = CRM.$("#taxesReadOnlyLabel");
    taxLabel.html(this.getTaxTerm());

    var hiddenTaxes = CRM.$(".Taxes-section div input");
    hiddenTaxes.val(taxAmount);
    hiddenTaxes.change();

    // this is a CiviCRM function available on form.
    if (typeof calculateText !== 'undefined') {
        try {
            calculateText(hiddenTaxes);
        } catch (e) {
            console.log("Failed to calculate taxes: " + e);
        }
    }


};

console.log("TaxCalculator defined");