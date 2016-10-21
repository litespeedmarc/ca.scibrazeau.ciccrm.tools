{crmAPI var="contactInfo" entity="contact" action="get" version="3" id=$contactId sequential=1}
    
{if $context eq "membership"}
<script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_tax_hack.js"/>
{/if}

<script>
    {if $contactInfo.values[0].state_province_id}
    var stateProvinceId = [ "{$contactInfo.values[0].state_province_id}" ];
    {else}
    var stateProvinceId = [ 0 ];
    {/if}
        var taxCalculator;

    {if $context ne "membership"}
    {literal}
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
        {/literal}
    {/if}
        
    {* DO THIS regardless *}
    
        // When price set changes, CiviCRM reloads the entire page.  So we call "ready" again.
        var priceSetId = CRM.$('#price_set_id').val();
        var contactId = CRM.$('#contact_id').val();
        console.log("Document ready. PriceSetId==" + priceSetId + ", stateProvinceId==" + stateProvinceId + ", contactId==" + contactId);
        
        taxCalculator = new TaxCalculator();
        {literal}
        taxCalculator.install( function() { 
            console.log("Getting taxes from the right function: " + stateProvinceId[0]);
            return stateProvinceId[0]; 
        });
        {/literal}

        CRM.$('#mem_type_id').hide();
        CRM.$('#totalAmountORPriceSet').hide();
        CRM.$('#priceset').next().next().hide();
        CRM.$('#priceset').next().hide();
        
    {if $context ne "membership"}
    {literal}
    });
    {/literal}
    {/if}


</script>


{if $context ne "membership"}
    <script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_tax_hack.js"/>
{/if}