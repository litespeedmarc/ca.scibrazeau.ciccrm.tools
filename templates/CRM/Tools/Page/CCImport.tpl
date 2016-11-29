{* Example: Display a variable directly *}
<html>
<body>
<p>Imported {$importCount} CCs From Amsoft</p>
<p>Don't forget to run the following SQL.  I would do it for you automatically, but as you can see, there is a DELETE statement, and I sooner there'd be some intelligence / verfications be done before running these</p>
<pre style='font-size:small; border: 1px dotted gray; border-radius:25px; padding:10px'>

delete from civicrm_value_membership_extras_7;

-- make sure everyone gets a row (only do for primary societies)
insert into civicrm_value_membership_extras_7 (entity_id, renew_membership_52)
select mem.id, 0
  from civicrm_membership mem 
 where mem.membership_type_id in  (select id from civicrm_membership_type t where t.member_of_contact_id in (5, 6, 7))
   and not mem.membership_type_id in (5, 6, 7)
   and not exists(select * from civicrm_value_membership_extras_7 extra where extra.entity_id = mem.id);

-- delete anyone that shouldn't have one
delete from civicrm_value_membership_extras_7
      where not exists(select * from civicrm_membership mem where mem.id = entity_id)
        OR not entity_id IN (select id from civicrm_membership mem where mem.membership_type_id in  (select id from civicrm_membership_type t where t.member_of_contact_id in (5, 6, 7))
  											 and not mem.membership_type_id in (160, 161, 162) );

-- no NULLs      				      
update civicrm_value_membership_extras_7
   set renew_membership_52 = 0
 where renew_membership_52 is null;
   
-- we just imported CCs, set the imported ones to auto renew.
-- note that since we only have 'primary society' memberships, don't need to complicate where
update civicrm_value_membership_extras_7
   set renew_membership_52 = 1
 where entity_id in (select id from civicrm_membership where contact_id in (select contact_id from civicrm_cardvault where invoice_id IS NULL) and end_date >= '2016-10-01');
   
   

-- for testing / verification
-- select contact_id from civicrm_value_membership_extras_7, civicrm_membership where renew_membership_52 = 1 and civicrm_membership.id = entity_id order by 1 desc

</pre>
</body>
</html>
