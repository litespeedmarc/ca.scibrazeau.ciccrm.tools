{literal}
    
<script>
    var stateProvinceId = [0];
    var taxCalculator;
    var lastPriceSet = 0;
  
    function updateTaxes() {
        if (typeof taxCalculator === "undefined") {
            return;
        } else {
            taxCalculator.updateTotal();
        }
    }
    
    var contactIdChangeFunction = function() {
        var contactId = CRM.$("#contact_id").val();
        
        if (typeof contactId === "undefined" || contactId < 1) {
            return;
        }
        
        if (contactId > 0) {
            CRM.api3('Contact', 'getsingle', {id: contactId})
                .done(function (data) {
                    stateProvinceId[0] = data.state_province_id;
                    console.log("Member's province is " + stateProvinceId[0]);
                    updateTaxes();
                });
        } else {
            stateProvinceId[0] = 0;
            updateTaxes();
        }
                
    };
    
    
    
    // when contact changes, load the province from CiviCRM, and update variable, above
    CRM.$('#contact_id').change(contactIdChangeFunction);

    CRM.$(document).ready( function() {
        
        contactIdChangeFunction();
        
        // When price set changes, CiviCRM reloads the entire page.  So we call "ready" again.
        var priceSetId = CRM.$('#price_set_id').val();
        var contactId = CRM.$('#contact_id').val();
        console.log("Document ready. PriceSetId==" + priceSetId + ", stateProvinceId==" + stateProvinceId + ", contactId==" + contactId);
                
        
        taxCalculator = new TaxCalculator();
        taxCalculator.install( function() { 
            return stateProvinceId[0]; 
        });

        CRM.$('#mem_type_id').hide();
        CRM.$('#totalAmountORPriceSet').hide();
        CRM.$('#priceset').next().next().hide();
        CRM.$('#priceset').next().hide();
    });

</script>
{/literal}

<script src="/sites/default/files/civicrm/ext/ca.scibrazeau.ciccrm.tools/js/cic_tax_hack.js"/>


