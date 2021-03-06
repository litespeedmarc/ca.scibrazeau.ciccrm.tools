{assign var=field value=$profileFields.$fieldName}
    {if $field.skipDisplay}
        {continue}
    {/if}

    {assign var=n value=$field.name}

    {if $field.field_type eq "Formatting"}
        {if $action neq 4 && $action neq 1028}
            {$field.help_pre}
        {/if}
    {elseif $n}
        {* Show explanatory text for field if not in 'view' or 'preview' modes *}
        {if $field.help_pre && $action neq 4 && $action neq 1028}
            <div class="crm-section helprow-{$n}-section helprow-pre" id="helprow-{$n}">
                <div class="wiz_content description">{$field.help_pre}</div>
            </div>
        {/if}
        {if $field.options_per_line != 0}
            <div class="crm-section editrow_{$n}-section form-item" id="editrow-{$n}">
                {if $noLabel}
                {else}
                    <div class="wiz_label option-label">{if $prefix}{$form.$prefix.$n.label}{else}{$form.$n.label}{/if}</div>
                {/if}
                <div class="wiz_content 3">
                    {assign var="count" value="1"}
                    {strip}
                        <table class="form-layout-compressed">
                            <tr>
                                {* sort by fails for option per line. Added a variable to iterate through the element array*}
                                {assign var="index" value="1"}
                                {if $prefix}
                                    {assign var="formElement" value=$form.$prefix.$n}
                                {else}
                                    {assign var="formElement" value=$form.$n}
                                {/if}
                                {foreach name=outer key=key item=item from=$formElement}
                                {if $index < 10}
                                {assign var="index" value=`$index+1`}
                                {else}
                                <td class="labels font-light">{$formElement.$key.html}</td>
                                {if $count == $field.options_per_line}
                            </tr>
                            <tr>
                                {assign var="count" value="1"}
                                {else}
                                {assign var="count" value=`$count+1`}
                                {/if}
                                {/if}
                                {/foreach}
                            </tr>
                        </table>
                    {/strip}
                </div>
                <div class="clear"></div>
            </div>
        {else}
            <div class="crm-section editrow_{$n}-section form-item" id="editrow-{$n}">
                {if $noLabel}
                {else}
                    <div class="wiz_label">
                        {if $prefix}{$form.$prefix.$n.label}{else}{$form.$n.label}{/if}
                        {if $required}
                            <span class="crm-marker" title="This field is required.">*</span>
                        {/if}
                    </div>
                {/if}
                <div class="wiz_content">
                    {if $n|substr:0:3 eq 'im-'}
                        {assign var="provider" value=$n|cat:"-provider_id"}
                        {$form.$provider.html}&nbsp;
                    {/if}

                    {if $n eq 'email_greeting' or  $n eq 'postal_greeting' or $n eq 'addressee'}
                        {include file="CRM/Profile/Form/GreetingType.tpl"}
                    {elseif ($n eq 'group' && $form.group) || ($n eq 'tag' && $form.tag)}
                        {include file="CRM/Contact/Form/Edit/TagsAndGroups.tpl" type=$n title=null context="profile"}
                    {elseif $n|substr:0:5 eq 'phone'}
                        {assign var="phone_ext_field" value=$n|replace:'phone':'phone_ext'}
                        {if $prefix}{$form.$prefix.$n.html}{else}{$form.$n.html}{/if}
                        {if $form.$phone_ext_field.html}
                            &nbsp;{$form.$phone_ext_field.html}
                        {/if}
                    {else}
                        {if $prefix}
                            {if $n eq 'organization_name' && !empty($form.onbehalfof_id)}
                                {$form.onbehalfof_id.html}
                            {/if}
                            {if $field.html_type eq 'File' && $viewOnlyPrefixFileValues}
                                {$viewOnlyPrefixFileValues.$prefix.$n}
                            {else}
                                {$form.$prefix.$n.html}
                            {/if}
                        {elseif $field.html_type eq 'File' && $viewOnlyFileValues}
                            {$viewOnlyFileValues.$n}
                        {else}
                            {$form.$n.html}
                        {/if}
                    {/if}

                    {*CRM-4564*}
                    {if $field.html_type eq 'Autocomplete-Select'}
                        {if $field.data_type eq 'ContactReference'}
                            {include file="CRM/Custom/Form/ContactReference.tpl" element_name = $n}
                        {/if}
                    {/if}
                </div>
                <div class="clear"></div>
            </div>
        {/if}
        {* Show explanatory text for field if not in 'view' or 'preview' modes *}
        {if $field.help_post && $action neq 4 && $action neq 1028}
            <div class="crm-section helprow-{$n}-section helprow-post" id="helprow-{$n}">
                <div class="wiz_content description">{$field.help_post}</div>
            </div>
        {/if}
    {/if}
