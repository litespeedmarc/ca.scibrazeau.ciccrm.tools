<?php

require_once 'CRM/Core/Page.php';

class CRM_Tools_Page_CCImport extends CRM_Core_Page {

  const TRIM_CHARS = " \t\n\r\0\x0B,:-";

  public function run() {
    // Example: Set the page-title dynamically; alternatively, declare a static title in xml/Menu/*.xml
    CRM_Utils_System::setTitle(ts('ImportPriceSet'));

    $rows = CRM_Core_DAO::executeQuery("
select distinct con.id, cc_type_id, trim(cc_card_no) as cc_card_no, cc_card_expiry, cc_card_ccv_no, cc_name_on_card, ac.last_name, ac.first_name
    from amsoft.p_memf_preauthorization as amsoft_pap
    		inner join civicrm_contact con on con.external_identifier = amsoft_pap.constit_id
    		inner join amsoft.p_constit ac on ac.constit_id = amsoft_pap.constit_id
    		where not exists(select * from civicrm_cardvault cv where cv.contact_id = con.id)
                  and cc_card_no is not null
                  and length(trim(cc_card_no)) > 0
	");

    $cnt = 0;
    while ( $rows->fetch()) {
      $combinedName = $rows->cc_name_on_card;
      $firstName = $rows->first_name;
      $lastName = $rows->last_name;
      $this->cleanNames($combinedName, $firstName, $lastName);
      switch ($rows->cc_type_id) {
        case 1: $ccType = 'Visa'; break;
        case 2: $ccType = 'MasterCard'; break;
        case 3: $ccType = 'Amex'; break;
        default:
          continue;
      }

      $year = substr($rows->cc_card_expiry, 0, 4);
      $month = substr($rows->cc_card_expiry, 5, 2);

      $params = [
        'contact_id' => $rows->id,
        'contribution_id' => NULL,
        'invoice_id' => NULL,
        'billing_first_name' => $firstName,
        'billing_last_name' => $lastName,
        'credit_card_type' => $ccType,
        'credit_card_number' => $rows->cc_card_no,
        'cvv2' => $rows->cc_card_ccv_no,
        'credit_card_expire_month' => $month,
        'credit_card_expire_year' => $year,
        'currency' => 'CAD',
      ];

      CRM_Cardvault_BAO_Cardvault::create($params);
      $cnt++;
    }

    $this->assign('importCount', $cnt);

    parent::run();
  }

  private function cleanNames($combinedName, &$firstName, &$lastName) {
    $combinedName = trim($combinedName, self::TRIM_CHARS);

    if ($this->keptLast($combinedName, $firstName, $lastName)) {
      return;
    }

    if ($this->keptLast($combinedName, $lastName, $firstName)) {
      return;
    }

    $lastSpacePos = strrpos($combinedName, ' ');
    if ($lastSpacePos === FALSE) {
      $firstName = "";
      $lastName = $combinedName;
      return;
    }

    $lastName = trim(substr($combinedName, $lastSpacePos), SELF::TRIM_CHARS);
    if (mb_strtoupper($lastName, 'utf-8') == $lastName) {
      // e.g., CIC... Go back one.
      $lastSpacePos2 = strrpos($combinedName, ' ', $lastSpacePos - 1);
      if ($lastSpacePos2 !== FALSE) {
        $lastName = trim(substr($combinedName, $lastSpacePos2), SELF::TRIM_CHARS);
        $firstName = trim(substr($combinedName, 0, $lastSpacePos2), SELF::TRIM_CHARS);
        return;
      }
    }

    $firstName = trim(substr($combinedName, $lastSpacePos), SELF::TRIM_CHARS);

  }

  private function keptLast($combinedName, &$firstName, &$lastName) {
    $lastNamePos = stripos($combinedName, $lastName);
    if ($lastNamePos) { // NOT NULL and NOT FIRST CHARACTER
      $lastName = trim(substr($combinedName, $lastNamePos), SELF::TRIM_CHARS);
      $firstName = trim(substr($combinedName, 0, $lastNamePos), SELF::TRIM_CHARS);
      return true;
    }

    if ($lastNamePos !== FALSE) {
      $lastName = trim(substr($combinedName, 0, strlen($lastName)), SELF::TRIM_CHARS);
      $firstName = trim(substr($combinedName, strlen($lastName)), SELF::TRIM_CHARS);
      return true;
    }

    return false;
  }


}
