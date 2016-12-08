{if $importCount}
    <div>
    {$importCount} user records created.
    </div>

    <br/>
    <br/>
    <br/>
{/if}

<form method='get' id=""smart_group">

    <label for="smartGroupId">Please select smart group to create users for:</label>
    <select id="smartGroupId" name="smartGroupId">
        {foreach from=$smartGroups item=group}
            <option value="{$group.id}">{$group.title}</option>
        {/foreach}
    </select>

    <input type="submit" value="Submit">

</form>



