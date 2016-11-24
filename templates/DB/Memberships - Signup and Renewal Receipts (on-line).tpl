<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title></title>
</head>
<body style='font-family: Verdana,Geneva,sans-serif;'>
{capture assign=font}font-family: Verdana,Geneva,sans-serif; font-size:10pt;{/capture}
{capture assign=headerStyle1}style="text-align: left; padding: 4px; border-bottom: 1px solid #999; background-color: #eee; {$font}"{/capture}
{capture assign=headerStyle3}colspan="3" {$headerStyle1}{/capture}
{capture assign=headerStyle4}colspan="4" {$headerStyle1}{/capture}
{capture assign=labelStyle1 }style="padding: 4px; border-bottom: 1px solid #999; background-color: #f7f7f7; text-align:right; {$font}"{/capture}
{capture assign=valueStyle1 }style="padding: 4px; border-bottom: 1px solid #999; {$font}"{/capture}
{capture assign=valueStyle3 }colspan=3 {$valueStyle1}{/capture}
{assign var='address1' value='Street Address'}
{assign var='address2' value='Supplemental Address 1'}
{assign var='address3' value='Supplemental Address 2'}
{assign var='city'     value='City'}
{assign var='prov'     value='Province/State'}
{assign var='postal'   value='Postal/Zip Code'}
{assign var='prim_div' value='Primary Division'}
{assign var='addi_div' value='Additional Divisions'}
{capture assign=full_address}
    {$customPre.$address1}
    {if !empty($customPre.$address2)}<br/>{$customPre.$address2}{/if}
    {if !empty($customPre.$address3)}<br/>{$customPre.$address3}{/if}
    <br/>{$customPre.City}, {$customPre.$prov}
    {if $customPre.Country ne "Canada"}<br/>{$customPre.$Country}{/if}
{/capture}




{assign var='join_date' value=""}
{foreach from=$lineItem item=value key=priceset}
    {foreach from=$value item=line}
        {if !empty($line.join_date)}
            {assign var='join_date' value=$line.join_date}
        {/if}
    {/foreach}
{/foreach}

<div>
    <img alt="" src="https://cividev.cheminst.ca/sites/cividev.cheminst.ca/files/civicrm/persist/contribute/images/2016_MembershipReceipt_Header.jpg" style="width: 650px; height: 145px;" /></td>
</div>

<br/>

<table style='width: 650px'>
    <!-- Member Details -->
    <tr>
        <th {$headerStyle4}>{ts}Member Details{/ts}</th>
    </tr>
    <tr>
        <td {$labelStyle1} width=25%>{ts}Name{/ts} : </td>
        <td {$valueStyle3}>{$displayName}</td>
    </tr>
    <tr>
        <td {$labelStyle1}>{ts}Email Address{/ts} : </td>
        <td {$valueStyle3}>{$email}</td>
    </tr>
    <tr>
        <td {$labelStyle1}>{ts}Mailing Address{/ts} : </td>
        <td {$valueStyle3}>{$full_address}</td>
    </tr>
    <tr>
        <td {$labelStyle1}>{ts}Member #{/ts} : </td>
        <td {$valueStyle3}>CIV_{$contactID}</td>
    </tr>
    <tr>
        <td {$labelStyle1}>{ts}Member Since{/ts} : </td>
        <td {$valueStyle3}>{$join_date}</td>
    </tr>
    <tr>
        <td {$labelStyle1}>{ts}Primary Division{/ts} : </td>
        <td {$valueStyle3}>{$customPre.$prim_div}</td>
    </tr>
    <tr>
        <td {$labelStyle1}>{ts}Additional Divisions{/ts} : </td>
        <td {$valueStyle3}>{$customPre.$addi_div}</td>
    </tr>
</table>

<br/>


<table style='width: 650px'>
    <!-- Membership Details -->
    <tr>
        <th {$headerStyle4}>{ts}Payment Summary{/ts}</th>
    </tr>

    <tr>
        <td {$labelStyle1} width=25%>{ts}Total Amount{/ts} : </td>
        <td {$valueStyle3}>{$amount|crmMoney}</td>
    </tr>

    <!-- Date Received -->
    {if $receive_date}
        <tr>
            <td {$labelStyle1}>{ts}Date Received{/ts} : </td>
            <td {$valueStyle3}>{$receive_date|truncate:10:''|crmDate}</td>
        </tr>
    {/if}

    <!-- Paid By (e.g., Cheque, Credit Card, etc... -->
    {if $formValues.paidBy}
        <tr>
            <td {$labelStyle1}>{ts}Paid By{/ts} : </td>
            <td {$valueStyle3}>{$formValues.paidBy}</td>
        </tr>

        <!-- Check Number (when paid by check) -->
        {if $formValues.check_number}
            <tr>
                <td {$labelStyle1}>{ts}Check Number{/ts} : </td>
                <td {$valueStyle3}>{$formValues.check_number}</td>
            </tr>
        {/if}
    {/if}
</table>

<br/>

<table style='width: 650px'>
    <!-- Membership Fees -->
    <tr>
        <th {$headerStyle3}>{ts}Payment Details{/ts}</th>
    </tr>

    <!-- Item / Fee / Membership Start Date / Membership End Date -->
    <tr>
        <th style='text-align: left; padding-left: 25px; width:60%; {$font}'>{ts}Item{/ts}</th>
        <th style='width: 25%; text-align: center; {$font}'>{ts}End Date{/ts}</th>
        <th style='text-align: right; width: 15%; {$font}'>{ts}Fee{/ts}</th>
    </tr>

    {foreach from=$lineItem item=value key=priceset}
        {foreach from=$value item=line}
            <tr>
                <td style='text-align: left; padding-left: 25px; {$font}'>
                    {if $line.html_type eq 'Text'}
                        {if $line.label eq 'hidden_taxes'}
                            {if $line.line_total ne "0.00"}
                                {if $customPre.$prov eq "NB" ||  $customPre.$prov eq "NL" || $customPre.$prov eq "NS" || $customPre.$prov eq "ON"|| $customPre.$prov eq "PEI"}
                                    HST
                                {else}
                                    GST
                                {/if}
                            {/if}
                        {else}
                            $line.label
                        {/if}
                    {else}
                        {$line.field_title} - {$line.label}
                    {/if}
                </td>
                <td style='text-align: center; {$font}'>{if empty($line.end_date)}N/A{else}{$line.end_date}{/if}</td>
                <td style='text-align: right; {$font}'>{$line.line_total|crmMoney}</td>
            </tr>
        {/foreach}
    {/foreach}

    <!-- Total Amount -->
    <tr>
        <td colspan=2></td>
        <td style="padding: 4px; border-top: double; border-bottom: 2px solid; text-align: right; {$font}">{$amount|crmMoney}</td>
    </tr>




</table>

<br/><br/>
{if $formValues.receipt_text_signup}
    <p>{$formValues.receipt_text_signup|htmlize}</p>

{elseif $formValues.receipt_text_renewal}
    <p>{$formValues.receipt_text_renewal|htmlize}</p>

{else}
    <p style='font-family: Verdana,Geneva,sans-serif; font-size:10pt;'>{ts}GST/HST # 108076431.{/ts}</p>
    <p></p>

{/if}
<p style='font-family: Verdana,Geneva,sans-serif; font-size:10pt;'>{ts}Thank you for your support.{/ts}</p>
<p></p>
{if ! $cancelled}
    <p style='font-family: Verdana,Geneva,sans-serif; font-size:10pt;'>{ts}Please print this receipt for your records.{/ts}</p>
{/if}

</body>
</html>