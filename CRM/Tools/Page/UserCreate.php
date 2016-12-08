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

    $contacts = CRM_Contact_BAO_Group::getGroupContacts($smartGroupId);

    $cnt = 0;
    foreach ($contacts as $contact_id=>$ignored) {
      $email = CRM_Contact_BAO_Contact::getPrimaryEmail($contact_id);
      if (!$email) {
        CRM_Core_Session::setStatus("Contact $contact_id does not have an e-mail. No account created", "Warning", 'error');
        continue;
      }
      if (preg_match("^[A-Za-z@0-9._-]{1,}$", $email)) {
        CRM_Core_Session::setStatus("Contact $contact_id's email ($email) is invalid. No account created");
        continue;
      }

      $params =  [ 1 => [$email, 'String']];
      $has = CRM_Core_DAO::singleValueQuery("select 1 from users u where u.name = %1", $params);
      if ($has) {
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

      CRM_Core_BAO_CMSUser::create($params, 'email');
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

