{php}
    $group = $this->get_template_vars("group");

    $cnt = CRM_Core_DAO::singleValueQuery("
    select count(*)
    from civicrm_custom_field uf1
    where custom_group_id in (select id from civicrm_custom_group where title = '$group')
    and column_name like '%\_0_'
    and exists(select * from civicrm_custom_field uf2
    where uf2.id <> uf1.id
    and uf2.name like concat(uf1.name, '%\___')
    )
    ");

    $idsAndTitles = array();
    $sql = "
    select uf1.label, id
    from civicrm_custom_field uf1
    where custom_group_id in (select id from civicrm_custom_group where title = '$group')
    and column_name like '%\_0_'
    order by weight
    ";

    $dao = CRM_Core_DAO::executeQuery($sql);
    while ($dao->fetch()) {
    $idsAndTitles[$dao->id] = $dao->label;
    }
    $dao->free();

    $this->assign("idsAndTitles", $idsAndTitles);
    $this->assign("perRowCnt", $cnt);
    $this->assign("maxRowCnt", sizeof($idsAndTitles) / $cnt);
    $this->assign("safeGroup", preg_replace("/[^A-Za-z0-9]/", "_", $group));

    if (empty($GLOBALS['fieldsToRowScriptDefined'])) {
        $GLOBALS['fieldsToRowScriptDefined'] = 1;
    } else {
        $this->assign('scripts_defined', 'Yes Sir');
    }
{/php}
{if $perRowCnt > 1}
    <h3 class="multi_row_ta">{$group}</h3>
    <table>
        <thead>
        <tr>
            {assign var="cnt" value=0}
            {foreach from=$idsAndTitles key=id item=title}
                {assign var="cnt" value=$cnt+1}
                {if $cnt > $perRowCnt}
                    {continue} {* seriously!? no break!??? Fine, just do nothing then *}
                {/if}
                <th class="wiz-th">{$title}</th>
            {/foreach}
        </thead>
        <tbody>

        {assign var="cnt" value=0}
        <!-- Building fields for {$group} -->
        <tr id="{$safeGroup}_0">
            {* Go through all fields *}
            {foreach from=$idsAndTitles key=id item=title}
            <td>
                <!-- Including Field {$id} / {$title} -->
                {include  file="CRM/Contribute/Form/Contribution/BlockField.tpl" fieldName="custom_$id" profileFields=$profileFields noLabel=1}
            </td>
            {assign var="cnt" value=$cnt+1}

            {* Current count / 5 dividable by 0, next row *}
            {if $cnt % $perRowCnt == 0 && $cnt != $idsAndTitles|@count}
                {* include id on row, that is group_# *}
                </tr><tr id="{$safeGroup}_{math equation="floor(cnt/perRowCnt)" cnt=$cnt perRowCnt=$perRowCnt}">
            {/if}
            {/foreach}
        </tr>
        </tbody>
    </table>

    <script>
        {* Create global function (only once) that will add/remove row. *}
        {if empty($scripts_defined) }
            {php}
                $this->assign('global_function', 1);
            {/php}
            {literal}
                function getRowValue(groupName, rowAt) {
                    return getGroupTR(groupName, rowAt).first().find("input").val();
                }

                function changeOrAddRow(groupName, rowAt, maxRowCnt) {
                    var val = getRowValue(groupName, rowAt);
                    if (val == "") {
                        for (var i = rowAt; i < maxRowCnt - 1; i++) {
                            copyRowValues(groupName, i + 1, i);
                        }
                        clearRowValues(groupName, maxRowCnt - 1);
                    }
                    hideEmptyRows(groupName, maxRowCnt);
                }

                function copyValFromTo(fromRowEl, toRowEl) {
                    var srcFirst = fromRowEl.find('input');
                    var dstFirst = toRowEl.find('input');
                    dstFirst.val(srcFirst.val());

                    srcFirst = fromRowEl.find('select');
                    dstFirst = toRowEl.find('select');
                    dstFirst.val(srcFirst.val());

                    srcFirst = fromRowEl.find('span[class^=select][class$=-chosen]');
                    dstFirst = toRowEl.find('span[class^=select][class$=-chosen]');
                    dstFirst.text(srcFirst.text());
                }

                function copyRowValues(groupName, fromRow, toRow) {
                    var fromRowEls = getGroupTR(groupName, fromRow).children();
                    var toRowEls = getGroupTR(groupName, toRow).children();
                    for (var i = 0; i < fromRowEls.length; i++) {
                        copyValFromTo($(fromRowEls[i]), $(toRowEls[i]));
                    }
                }

                function clearRowValues(groupName, row)  {
                    var groupTr = getGroupTR(groupName, row);
                    groupTr.find('input').each(function() {
                        $(this).val("");
                    });
                    groupTr.find('select').each(function() {
                        $(this).val(-1);
                    });
                    groupTr.find('span[class^=select][class$=-chosen]').each(function() {
                        $(this).text("");
                    });
                }

                function hideEmptyRows(groupName, maxRowCnt) {
                    for (var i = 1; i < maxRowCnt; i++) {
                        var col1Val = getRowValue(groupName, i - 1);
                        if (col1Val == "") {
                            getGroupTR(groupName, i).hide();
                        } else {
                            getGroupTR(groupName, i).show();
                        }
                    }
                }

                function getGroupTR(groupName, rowNumber) {
                    return $('#' + groupName + '_' + rowNumber);
                }


                function addChangeHandlers(groupName, maxRowCnt) {
                    function createHandler(groupName, i, maxRowCnt) {
                        return function() {
                            changeOrAddRow(groupName, i, maxRowCnt);
                        };
                    }
                    for (var i = 0; i < maxRowCnt; i++) {
                        var triggerEl = getGroupTR(groupName, i).first().find("input").first();
                        triggerEl.change(createHandler(groupName, i, maxRowCnt));
                    }
                    hideEmptyRows(groupName, maxRowCnt);
                }
            {/literal}
        {/if}

        {* // add listeners to first box of rows, anytime they are empty, we clear our the row, and move "up" the other rows. *}
        $(function() {ldelim}
            addChangeHandlers('{$safeGroup}', {$maxRowCnt});
        {rdelim});
    </script>
{/if}
