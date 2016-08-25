// Custom CIC JavaScript for polishing layout of new membership application form
// and for Handling taxes

// Move Pre billing form fields, *BEFORE* membership fields
CRM.$(".custom_pre_profile-group").insertAfter("#intro_text");

//// Hide "mandatory tax contribution field"
//CRM.$(".Taxes-section").hide();

// Remove (taxable) from labels, and use " + tax" after amount instead
CRM.$(".crm-price-amount-label").each( function (index ) {
    var labelElement = CRM.$(this);
    var label = labelElement.text();
    if (label.indexOf(" (taxable)") !== -1) {
        var amountElement = CRM.$(this).next();
        amountElement.append(" + tax");
        labelElement.text(label.replace(" (taxable)", ""));
    }
});
        
//CRM.$(document).bind('DOMSubtreeModified', function () {
//    // CRM.$('.Taxes-section').hide();
//    CRM.$('#price_311').prop("readonly", true);
//});


/**
 * The following creates a TaxCalculator object that you can call wherever
 */

var TaxCalculator = new Object();

TaxCalculator.ensureTotalWithTaxesArea = function()
{
    var fullTotal = document.getElementById("priceWithTaxesSetTotal");
    if (fullTotal == null) {
      var subTotal = document.getElementById("pricesetTotal");
      fullTotal = document.createElement('div');
      fullTotal.setAttribute("id", "priceWithTaxesSetTotal");
      fullTotal.innerHTML = '\
        <div class="label" id="pricelabel"> \
          <label><span id="amount_sum_with_taxes_label">Total + Taxes amount</span></label> \
        </div> \
        <div class="content calc-value" id="pricewithtaxesvalue"><b>$</b> 0.00</div>';
      subTotal.parentNode.insertBefore(fullTotal, subTotal.nextSibling);
    }
}

TaxCalculator.updateTotal = function()
{
    var fullTotal = document.getElementById("pricewithtaxesvalue");
    fullTotal.innerHTML = "<b>$</b> " + TaxCalculator.total();
}

TaxCalculator.total = function()
{
    var rawTotal = TaxCalculator.subTotal() * (1 + TaxCalculator.taxRate());
    return parseFloat(Math.round(rawTotal * 100) / 100).toFixed(2);
}

TaxCalculator.subTotal = function()
{
    var rawValue = document.getElementById("pricevalue").innerText;
    var cleanValue = rawValue.replace(/[^\d.-]/g, '');
    return parseFloat(cleanValue);
}

// http://www.calculconversion.com/sales-tax-calculator-hst-gst.html
TaxCalculator.taxRate = function(provinceId)
{
    if (typeof(provinceId) == "undefined") {
      var lookupId = document.getElementById("state_province-Primary").value;
      return TaxCalculator.taxRate(lookupId);
    } else {
      switch(provinceId) {
        case "1100": return 0.05; // Alberta
        case "1101": return 0.12; // British Columbia
        case "1102": return 0.13; // Manitoba
        case "1103": return 0.15; // New-Brunswick
        case "1104": return 0.13; // Newfoundland and Labrador
        case "1105": return 0.05; // Northwest Territories
        case "1106": return 0.15; // Nova Scotia
        case "1107": return 0.05; // Nunavut
        case "1108": return 0.13; // Ontario
        case "1109": return 0.14; // Prince Edward Island
        case "1110": return 0.14975; // Quebec
        case "1111": return 0.10; // Saskatchewan
        case "1112": return 0.05; // Yukon Territory
        default: return 0.00;
      }
    }
}

TaxCalculator.addEvents = function() {
  TaxCalculator.addOnChange(document.getElementsByTagName('select'));
  TaxCalculator.addOnChange(document.getElementsByTagName('input'));
  TaxCalculator.addOnChange(document.getElementsByTagName('textarea'));
}

TaxCalculator.addOnChange = function(inputs) {
  for (index = 0; index < inputs.length; ++index) {
    inputs[index].onchange = function() { TaxCalculator.updateTotal(); }
  }
}


/**
 * This code needs to be called after the page has loaded;  I did not rely on the existing JS
 * as I didn't know how much would be available, and the actual JS needs are pretty low anyway
 */
TaxCalculator.ensureTotalWithTaxesArea();
TaxCalculator.addEvents();

