<?php

require_once 'CRM/Core/Page.php';

class CRM_Tools_Page_UserCreate extends CRM_Core_Page {

public function run() {

  // Example: Set the page-title dynamically; alternatively, declare a static title in xml/Menu/*.xml
  CRM_Utils_System::setTitle(ts('Create User Accounts'));

  if (isset($_GET["smartGroupId"])) {
    $this->createUsersForContactsInGroup($_GET["smartGroupId"]);
  }

  $this->showForm();

  parent::run();


  }

  private function createUsersForContactsInGroup($smartGroupId) {

    $rows = CRM_Core_DAO::executeQuery("
select contact_id, email
from civicrm_contact
  inner join civicrm_email on contact_id = civicrm_contact.id
                              and civicrm_email.is_primary = 1
				and not email like 'lyndsayburman%'
                              and not exists(SELECT *
                                         FROM users u
                                         WHERE lower(u.name) = lower(civicrm_email.email) COLLATE utf8_general_ci)
                              and not exists(SELECT *
                                             FROM users u
                                             WHERE lower(u.mail) = lower(civicrm_email.email) COLLATE utf8_general_ci)
                              and not email like '%@%@%'
                              and not email like '%-%'
                              and email regexp '^[A-Za-z@0-9._]{1,}$'
 
                              and exists(select * from civicrm_membership mem where mem.end_date >= '2016-12-10'
                                                                                    and mem.contact_id = civicrm_contact.id
                                                                                    and mem.membership_type_id in (select id from civicrm_membership_type t where t.member_of_contact_id in (5,6,7))
                              )
                              and civicrm_contact.contact_type = 'Individual'


        ");



    $contacts = civicrm_api3('Contact', 'get', array(
      'sequential' => 1,
      'group' => $smartGroupId,
    ))['values'];

    $cnt = 0;

 while ( $rows->fetch()) {


      $contact_id = $rows->contact_id;
      $email = $rows->email;

Civi::log()->info(ts('Creating drupal user account for %1, e-mail == %2', [
      1 => $contact_id,
      2 => $email,
    ]));

      if (!$email) {
Civi::log()->info(ts('Skipping, no email'));
        CRM_Core_Session::setStatus("Contact $contact_id does not have an e-mail. No account created", "Warning");
        continue;
      }
      if (!preg_match("/^[A-Za-z@0-9._-]{1,}$/", $email)) {
Civi::log()->info(ts('Skipping, bad email: '  . $email));
        CRM_Core_Session::setStatus("Contact $contact_id's email ($email) is invalid. No account created", "Warning");
      }

      $params =  [ 1 => [$email, 'String']];
      $has = CRM_Core_DAO::singleValueQuery("select 1 from users u where u.name = %1", $params);
      if ($has) {
Civi::log()->info(ts('Skipping, exists '));
        CRM_Core_Session::setStatus("A drupal user already exists for contact $contact_id.  No account created", [ 'expire' => 10 ]);
        continue;
      }

      $params = [
        'name' => $email,
        'cms_name' => $email,
        'mail' => $email,
        'email' => $email,
        'cms_pass' => 'IAmTired',
        'contactID' => $contact_id
      ];

Civi::log()->info(ts('Creating'));
try {
      CRM_Core_BAO_CMSUser::create($params, 'email');
} catch (Exception $e) {
	Civi::log()->info("Skipped $email because of an error: " . $e->getMessage());
	continue;
}

Civi::log()->info(ts('Created'));

      $cnt++;
    }

    $this->assign('importCount', $cnt);
  }

  private function showForm() {
    $result = civicrm_api3('Group', 'get', array(
      'sequential' => 1,
    ))['values'];

    $this->assign('smartGroups', $result);
  }


}

