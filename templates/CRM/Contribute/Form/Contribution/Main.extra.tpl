{* not sure why, but this script MUST be before script below, otherwise it doesn't work *}
<script>
    // Custom CIC JavaScript for polishing layout of new membership application form
    // and for Handling taxes
    console.log("On on-line contribution page {$contributionPageID}");
    
    {literal}
    // Move Pre billing form fields, *BEFORE* membership fields
    CRM.$(".custom_pre_profile-group").insertAfter("#intro_text");
    
    // install the tax calculator
    CRM.$(document).ready(function () {
        new TaxCalculator().install('#state_province-Primary');
    });
    {/literal}
</script>


<script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_tax_hack.js"/>
<script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_edu_hack.js"/>

