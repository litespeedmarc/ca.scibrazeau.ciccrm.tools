<?php

require_once 'CRM/Core/Page.php';

class CRM_Tools_Page_UserCreate extends CRM_Core_Page {

public function run() {
    $rows = CRM_Core_DAO::executeQuery("
select contact_id, email
  from civicrm_email 
 where is_primary
   and exists(select * from civicrm_membership mem where mem.contact_id = civicrm_email.contact_id and mem.end_date >= '2014-12-31')
   and email is not null and length(email) > 0
   and email regexp '^[A-Za-z@0-9._-]{1,}$'
   and not exists(select * from users u where u.name = email COLLATE utf8_unicode_ci )
group by email having count(*) = 1
   ");


$cnt = 0;
    while ($rows->fetch()) {
      $email = $rows->email;
      $contact_id = $rows->contact_id;

      $params = [
        'name' => $email,
        'cms_name' => $email,
        'mail' => $email,
        'email' => $email,
        'cms_pass' => 'IAmTired',
        'contactID' => $contact_id
      ];

      CRM_Core_BAO_CMSUser::create($params, 'email');
      $cnt++;
    }

  $this->assign('importCount', $cnt);

  parent::run();
  }


}

