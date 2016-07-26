



<form enctype="multipart/form-data" method='post'>

    {*<!-- ------------------------- -->
    <!-- list price sets to import -->
    <!-- ------------------------- -->
    <p>Price set to import:</p>
    <table><tbody>
{foreach from=$priceSets item=priceSet}
    <tr><td>
    {if $priceSet.fieldCnt gt 0}
        <input type="radio" name="priceSet" value="{$priceSet.name}" disabled>
        &nbsp;{$priceSet.title} - {$priceSet.society} (price set not empty)
            <a href="index.php?q=civicrm/admin/price/field&reset=1&action=browse&sid={$priceSet.id}">View and Edit Price Fields</a>
        </input>
    {else}
        <input type="radio" name="priceSet" value="{$priceSet.name}">
        &nbsp;{$priceSet.title} - {$priceSet.society}
        </input>
    {/if}
    </td></tr>
{/foreach}
    </tbody></table>*}
    
    <!-- ------------------------- -->
    <!-- Prompt for CSV File -->
    <!-- ------------------------- -->
    Price Sets CSV File: 
    <input type="file" name="csvFile">
    
    <br/>
    
    <input type="submit" value="Submit">
    


</form>

{* Example: Display a variable directly *}
<p>Hello {$Name} The current time is {$currentTime}</p>


{* Example: Display a translated string -- which happens to include a variable *}
<p>{ts 1=$currentTime}(In your native language) The current time is %1.{/ts}</p>

</script>