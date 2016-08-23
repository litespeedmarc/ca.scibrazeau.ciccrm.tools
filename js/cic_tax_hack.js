/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


CRM.$(document).bind('DOMSubtreeModified', function () {
    // CRM.$('.Taxes-section').hide();
    CRM.$('#price_311').prop("readonly", true);
});