<script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_edu_hack.js"/>

<script>
    {assign var=stateProvKey value="state_province-Primary"}
    

    {literal}
    CRM.$(document).ready( function() {

	hideEduConfirm();
        
        var taxCalculator = new TaxCalculator();
        taxCalculator.getProvinceId = function() { return "{/literal}{$form.$stateProvKey.value[0]}{literal}"; };
        var taxTerm = taxCalculator.getTaxTerm();
        
        CRM.$("td:contains('hidden_taxes')").each(function() {
            var oldText = CRM.$(this).html();
            var newText = oldText.replace(/hidden_taxes/g, taxTerm);
            CRM.$(this).html(newText);
        });
        
        CRM.$("td div.description").each(function () {
            var parent = CRM.$(this).parent();
            var divDescText = CRM.$(this).text();
            if (parent[0].childNodes[0].nodeValue.indexOf(divDescText) >= 0) {
                CRM.$(this).hide();
            }
            console.log(parent.text());
            
        });
    });
    {/literal}
</script>


<script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_tax_hack.js"/>
