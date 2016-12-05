{* not sure why, but this script MUST be before script below, otherwise it doesn't work *}
<script>

    {literal}
    // install the tax calculator
    CRM.$(document).ready(function () {
        new TaxCalculator().install('#state_province-Primary');
    });
    {/literal}
</script>


<script src="{$config->extensionsURL}ca.scibrazeau.ciccrm.tools/js/cic_tax_hack.js"></script>

