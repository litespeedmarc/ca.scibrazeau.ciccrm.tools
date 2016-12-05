{*

    This copied from template/CRM/Contribute/Form/Contribution/Main.tpl, specifically for CIC.

    Alterantively could have used web forms, but this would have complicated price set usage, and
    a lot of configuration from users.

    Very specific, if we need to use original, then would create big "if" statement... Though I think
    it may also be possible to create template based on contribution page id.

*}
{* Callback snippet: On-behalf profile *}
<script type="application/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.1/jquery.js"></script>
<script type="application/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.15.0/jquery.validate.js"></script>
<script type="application/javascript" src="http://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.15.0/additional-methods.js"></script>

{assign var=eduRows value=5}

{crmScript ext=ca.scibrazeau.ciccrm.tools file=js/jquery.formtowizard.js}
{crmStyle ext=ca.scibrazeau.ciccrm.tools file=css/ciccrm.tools.css weight=1000000 region=html-header}

{if $action & 1024}
    {include file="CRM/Contribute/Form/Contribution/PreviewHeader.tpl"}
{/if}


{include file="CRM/common/TrackingFields.tpl"}

<div class="crm-contribution-page-id-{$contributionPageID} crm-block crm-contribution-main-form-block">

    {if $contact_id && !$ccid}
        <div class="messages status no-popup crm-not-you-message">
            {ts 1=$display_name}Welcome %1{/ts}. (<a
                    href="{crmURL p='civicrm/contribute/transact' q="cid=0&reset=1&id=`$contributionPageID`"}"
                    title="{ts}Click here to do this for a different person.{/ts}">{ts 1=$display_name}Not %1, or want to do this for a different person{/ts}</a>?)
        </div>
    {/if}

    <div id="intro_text" class="crm-public-form-item crm-section intro_text-section">
        {$intro_text}
    </div>
    {include file="CRM/common/cidzero.tpl"}
    {if $islifetime or $ispricelifetime }
        <div class="help">{ts}You have a current Lifetime Membership which does not need to be renewed.{/ts}</div>
    {/if}

    <div id='progress'><div id='progress-complete'></div></div>



    <fieldset class="wiz">

        <legend>Member Personal Data</legend>

        <table class="wiz">
            <tbody>

            <tr>
                <td colspan="2">
                    {assign var=n value=email-$bltID}
                    <div class="crm-public-form-item crm-section {$form.$n.name}-section">
                        <div class="wiz_label">{$form.$n.label}</div>
                        <div class="wiz_content">
                            {$form.$n.html}
                        </div>
                        <div class="clear"></div>
                    </div>
                </td>
                <td>
                {include fieldyyName='preferred_language'      file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre required=true}
                </td>
            </tr>

            <tr>
            <td>
            {include fieldName='prefix_id'                   file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre}
                </td><td>
            {include fieldName='first_name'                  file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre }
                    </td><td>
            {include fieldName='last_name'                   file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre }
                </td>
            </tr>


            <tr>
                <td colspan="2">
                    {include fieldName='gender_id'                   file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre required=true}
                </td>
                <td>
                    {include fieldName='birth_date'                  file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre}
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    {include fieldName='phone-Primary-1'             file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre}
                </td>
                <td colspan="1">
                    {include fieldName='url-2'                       file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre}
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div class="wiz_label">
                        Primary Address
                    </div>
                    <table class="wiz address"><tr><td colspan="2">
                        {include fieldName='street_address-Primary'      file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre }
                        {include fieldName='supplemental_address_1-Primary'     file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre noLabel=1}
                        {include fieldName='supplemental_address_2-Primary'     file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre noLabel=1}
                    </td></tr>
                    <td>
                        {include fieldName='city-Primary'                file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre }
                    </td>
                    <td>
                        {include fieldName='country-Primary'             file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre }
                    </td></tr><tr>
                    <td>
                        {include fieldName='state_province-Primary'      file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre}
                    </td>
                    <td>
                        {include fieldName='postal_code-Primary'         file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre}
                     </td></tr></table>
                </td>
            </tr>
            </tbody>
        </table>
        </fieldset>

    <fieldset class="wiz">
        <legend>Education and Professional Experience</legend>
        {include file="CRM/Contribute/Form/Contribution/FieldsToRows.tpl" group="Education" profileFields=$customPre}
        {include file="CRM/Contribute/Form/Contribution/FieldsToRows.tpl" group="Professional Experience" profileFields=$customPre}
    </fieldset>

    <fieldset class="wiz">
        <legend>Divisions</legend>
        <div class="crm-public-form-item crm-section">
            <h3 for="custom_13">Primary Division</h3>
            {include fieldName='custom_13'         file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre noLabel=1}
            <h3 for="custom_13">Additional Divisions</h3>
            {include fieldName='custom_15'         file="CRM/Contribute/Form/Contribution/BlockField.tpl" profileFields=$customPre noLabel=1}
        </div>
    </fieldset>

    <fieldset class="wiz">
            <legend>Membership Selection</legend>
            <div class="crm-public-form-item crm-section">
                {include file="CRM/Contribute/Form/Contribution/MembershipBlock.tpl" context="makeContribution"}
            </div>
        </fieldset>

        <fieldset class="wiz">
        <legend>Billing Details</legend>

            <div class="crm-public-form-item crm-section cms_user-section">
                {include file="CRM/common/CMSUser.tpl"}
            </div>

            <div id="billing-payment-block">
                {include file="CRM/Financial/Form/Payment.tpl" snippet=4}
            </div>
            {include file="CRM/common/paymentBlock.tpl"}
            {if $form.payment_processor_id.label}
                {* PP selection only works with JS enabled, so we hide it initially *}
                <fieldset class="crm-public-form-item crm-group payment_options-group" style="display:none;">
                    <legend>{ts}Payment Options{/ts}</legend>
                    <div class="crm-public-form-item crm-section payment_processor-section">
                        <div class="label">{$form.payment_processor_id.label}</div>
                        <div class="content">{$form.payment_processor_id.html}</div>
                        <div class="clear"></div>
                    </div>
                </fieldset>
            {/if}

            {if $is_pay_later}
                <fieldset class="crm-public-form-item crm-group pay_later-group">
                    <legend>{ts}Payment Options{/ts}</legend>
                    <div class="crm-public-form-item crm-section pay_later_receipt-section">
                        <div class="label">&nbsp;</div>
                        <div class="content">
                            [x] {$pay_later_text}
                        </div>
                        <div class="clear"></div>
                    </div>
                </fieldset>
            {/if}

            {if $is_monetary and $form.bank_account_number}
                <div id="payment_notice">
                    <fieldset class="crm-public-form-item crm-group payment_notice-group">
                        <legend>{ts}Agreement{/ts}</legend>
                        {ts}Your account data will be used to charge your bank account via direct debit. While submitting this form you agree to the charging of your bank account via direct debit.{/ts}
                    </fieldset>
                </div>
            {/if}

            {if $isCaptcha}
                {include file='CRM/common/ReCAPTCHA.tpl'}
            {/if}


            <div id="crm-submit-buttons" class="crm-submit-buttons">
                {include file="CRM/common/formButtons.tpl" location="bottom"}
            </div>
    </fieldset>


    {if $footer_text}
        <div id="footer_text" class="crm-public-form-item crm-section contribution_footer_text-section">
            <p>{$footer_text}</p>
        </div>
    {/if}

</div>

{literal}
<script>

    $( function() {


        var $signupForm = $( '#Main' );

        $.validator.addMethod("select_idx_gt_0", function(value, element) {
            return value != "" && value > 0;
        }, "This field is required.");

        $.validator.addMethod("can_us_required", function(value, element) {
            var countryId = $('#country-Primary').val();
            return value != "" || (countryId != 1228 && countryId != 1039);
        }, "This field is required.");

        $.validator.addMethod("valid_for_country", function(value, element) {
            var countryId = $('#country-Primary').val();
            if (countryId == 1228) {
                return /(^\d{5}$)|(^\d{5}-\d{4}$)/.test(value);
            } else if (countryId == 1039) {
                return /^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$/.test(value);
            } else {
                return false;
            }
        }, "This postal code is not valid.");


        $signupForm.validate(
                {
                    ignore: [],
                    rules: {

                        // TAB 1 Fields
                        'first_name': 'required',
                        'last_name': 'required',
                        'custom_13': 'required',
                        'credit_card_exp_date_M' : 'select_idx_gt_0',
                        'credit_card_exp_date_Y' : 'select_idx_gt_0',
                        'credit_card_number' : 'required',
                        'cvv2' : 'required',
                        'billing_first_name' : 'required',
                        'billing_last_name' : 'required',
                        'billing_street_address-5' : 'required',
                        'billing_city-5' : 'required',
                        'billing_country_id-5' : 'required',
                        'billing_state_province_id-5' : 'required',
                        'billing_postal_code-5' : 'required',
                        'preferred_language': 'required',
                        'gender_id': 'required',
                        'street_address-Primary': 'required',
                        'city-Primary': 'required',
                        'country-Primary': 'required',
                        'postal_code-Primary' : {
                            'can_us_required' : true,
                            'valid_for_country' : true
                        },
                        'state_province-Primary': 'can_us_required',


                        // TAB 2 Fields
                        {/literal}
                        {foreach from=$priceSet.fields key=fieldId item=field}
                        {if ($field.is_required == 1)}
                                'price_{$fieldId}' : 'required',
                        {/if}
                        {/foreach}
                        {literal}
                    },
                    messages: {
                        'country-Primary' : 'This field is required.',
                        'state_province-Primary' : 'This field is required.'
                    },
                    errorPlacement : function(error, element) {
                        var elName = element[0].name;
                        {/literal}

                        {* Where to put price set "errors", use smarty to find right spot *}
                        {foreach from=$priceSet.fields key=fieldId item=field}
                        {if ($field.is_required == 1)}
                            if (elName == 'price_{$fieldId}') {ldelim}
                                error.insertAfter(element.parent().parent().parent().prev().children().last());
                                return;
                            {rdelim}
                        {/if}
                        {/foreach}
                        {literal}

                        // look for anything "for", typically a label, but could be H3
                        var label = $('[for="'+elName+'"]');
                        if(label.length <= 0) {
                            // find parent label
                            var parentEle = element.parent();
                            if (parentEle.attr("class") == "wiz_content") {
                               var prev = parentEle.prev();
                                if (prev.attr("class") == "wiz_label") {
                                    label = prev;
                                }
                            }
                        }
                        var insertAfter = label;
                        if (label.children().last().attr("class")== "crm-marker") {
                            insertAfter = label.children().last();
                        } else if (label.next().attr("class") == "crm-marker") {
                            insertAfter = label.next();
                        }
                        error.insertAfter(insertAfter);
                    },
                    errorElement: 'em'
                }
        ) ;

        var validator = function(form, step) {
                var stepIsValid = true;
                var validator = form.validate();
                $(':input', step).each( function(index) {
                        var xy = validator.element(this);
                        stepIsValid = stepIsValid && (typeof xy == 'undefined' || xy);
                });
                return stepIsValid;
        };

        $signupForm.formToWizard({
            element:      'fieldset.wiz',
            submitButton: 'rm-submit-buttons',
            nextBtnClass: 'crm-form-submit next',
            prevBtnClass: 'crm-form-submit prev',
            buttonTag:    'button',
            validateBeforeNext: validator,
            progress: function (i, count) {
                $('#progress-complete').width(''+(i/count*100)+'%');
            }
        });

        $signupForm.on('submit', function(e){
            var steps = $(this).find( "fieldset.wiz" ).length
            if (!validator($('#Main'), $('#step' + (steps - 1))) ) {
                alert("Please review and correct errors before continuing");
                e.preventDefault();
            }
        });

    });

</script>
{/literal}

