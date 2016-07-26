<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 * 
 * 
 */

class CRM_Tools_PriceSetImporter {

    private $_fileData;
    private $_societies = array();
    private $_tax_account_id;

    public function __construct($csvFile) {
        $rows = file($csvFile['tmp_name']);
        $csv = array_map('str_getcsv', $rows);
        array_walk($csv, function(&$a) use ($csv) {
            $a = array_combine($csv[0], $a);
        });
        array_shift($csv); # remove column header
        $this->_fileData = $csv;

        // remove $ from amount
        foreach ($this->_fileData as &$row) {
            $row['Amount'] = str_replace('$', '', $row['Amount']);
        }
    }

    public function import() {

        $this->createOrgs();
        $this->createAccounts();

        $this->createMembershipTypes("CIC");
        $this->createMembershipTypes("CSCT");
        $this->createMembershipTypes("CSChE");
        $this->createMembershipTypes("CSC");

        $this->createPriceSets(TRUE, TRUE, "CIC", 'Current');
        $this->createPriceSets(TRUE, TRUE, "CIC", 'Next');
        $this->createPriceSets(TRUE, FALSE, "CSCT", 'Current');
        $this->createPriceSets(TRUE, FALSE, "CSCT", 'Next');
        $this->createPriceSets(TRUE, FALSE, "CSChE", 'Current');
        $this->createPriceSets(TRUE, FALSE, "CSChE", 'Next');
        $this->createPriceSets(TRUE, FALSE, "CSC", 'Current');
        $this->createPriceSets(TRUE, FALSE, "CSC", 'Next');
    }

    private function createPriceSets($isMem, $isContrib, $society, $year) {
        $cnt = 0;
        foreach ($this->_fileData as $row) {
            $cnt += 10;
            $priceSet = $row['Price Set'];
            if ($this->isEmpty($priceSet)) {
                continue;
            }
            $account = $row["Account $society/$year Year"];
            if ($this->isEmpty($account)) {
                continue;
            }
            $priceSet = $this->parse($priceSet, $society, $year);


            $priceSetId = CRM_Price_BAO_PriceSet::getFieldValue('CRM_Price_BAO_PriceSet', $priceSet, 'id', 'name', TRUE);
            if ($priceSetId) {
                continue;
            }

            $financeTypeId = CRM_Financial_DAO_FinancialType::getFieldValue('CRM_Financial_DAO_FinancialType', 'Member Dues', 'id', 'name', TRUE);
            if (!$financeTypeId) {
                throw new Exception("Did not find 'Member Dues' for membershiptype $priceSet");
            }



            $bao = new CRM_Price_BAO_PriceSet();
            $bao->name = $priceSet;
            $bao->extends = 3;
            $bao->is_active = TRUE;
            $bao->financial_type_id = $financeTypeId;
            $bao->title = $priceSet;
            $priceSetId = $bao->insert();

            $this->createPriceSetFieldsAndOptions($society, $year, $priceSet, $priceSetId);
        }
    }

    private function createMembershipTypes($society) {
        $cnt = 0;
        foreach ($this->_fileData as $row) {
            $cnt += 10;
            $memType = $row['Membership Type'];
            if ($this->isEmpty($memType)) {
                continue;
            }
            $account = $row["Account $society/Current Year"];
            if ($this->isEmpty($account)) {
                continue;
            }
            $memType = str_replace('${Society}', $society, $memType);
            $exempt = ("yes" == strtolower($row["Exempt"]));
            $financeType = $this->getFinanceType($account, $exempt, $society, "Current Year", $row);

            $memTypeId = CRM_Member_BAO_MembershipType::getFieldValue("CRM_Member_BAO_MembershipType", $memType, 'id', 'name', TRUE);
            if ($memTypeId) {
                continue;
            }

            $financeTypeId = CRM_Financial_DAO_FinancialType::getFieldValue('CRM_Financial_DAO_FinancialType', $account, 'id', 'name', TRUE);
            if (!$financeTypeId) {
                throw new Exception("Did not find $financeType for membershiptype $memType");
            }

            $bao = new CRM_Member_BAO_MembershipType();
            $bao->domain_id = 1;
            $bao->name = $memType;
            $bao->financial_type_id = $financeTypeId;
            $memSociety = $row['Membership Org'];
            $memSociety = str_replace('${Society}', $society, $memSociety);

            if (!$memSociety) {
                throw new Exception("Unknown society: $memSociety");
            }

            if (!$this->_societies[$memSociety]) {
                throw new Exception("Could not find society's $memSociety id");
            }

            $bao->member_of_contact_id = $this->_societies[$memSociety];
            $amount = $row['Amount'];
            $amount = str_replace('$', '', $amount);
            $bao->minimum_fee = $amount;
            $bao->weight = $cnt;
            $bao->auto_renew = FALSE;
            $bao->is_active = TRUE;
            $bao->duration_unit = "year";
            $bao->duration_interval = 1;
            $bao->period_type = "fixed";
            $bao->fixed_period_start_day = 101;
            $bao->fixed_period_rollover_day = 1231;
            $bao->visibility = "Public";
            $bao->description = $memType;

            $bao->insert();
        }
    }

    private function createOrgs() {
        $this->createOrg("CIC", "The Canadian Institue of Chemistry");
        $this->createOrg("CSC", "Canadian Society for Chemistry");
        $this->createOrg("CSChE", "Canadian Society for Chemical Engineering");
        $this->createOrg("CSCT", "Canadian Society for Chemical Technology");
        foreach ($this->_fileData as $row) {
            $org = $row['Membership Org'];
            if ("N/A" == $org || empty($org)) {
                continue;
            }
            if ('${Society}' == $org) {
                continue;
            }
            $this->createOrg($org, $org);
        }
    }

    private function createOrg($shortName, $longName) {
        if (array_key_exists($shortName, $this->_societies)) {
            return;
        }
        $id = CRM_Contact_DAO_Contact::getFieldValue("CRM_Contact_DAO_Contact", $shortName, "id", "organization_name", true);
        if ($id) {
            $this->_societies[$shortName] = $id;
            return;
        }
        $conDAO = new CRM_Contact_DAO_Contact();
        $conDAO->organization_name = $shortName;
        $conDAO->legal_name = $longName;
        $conDAO->contact_type = 'Organization';
        $conDAO->sort_name = $shortName;
        $conDAO->display_name = $shortName;
        $conDAO->preferred_communication_method = '';
        $conDAO->preferred_language = 'en_US';
        $conDAO->communication_style_id = 1;
        $conDAO->addressee_id = 3;
        $conDAO->addressee_display = $shortName;
        $id = $conDAO->insert();
        $this->_societies[$shortName] = $id;
    }

    private function createAccounts() {
        $accountingCode = "2005";
        $financialAccountId = CRM_Financial_DAO_FinancialAccount::getFieldValue('CRM_Financial_DAO_FinancialAccount', $accountingCode, 'id', 'accounting_code', TRUE);
        if (!$financialAccountId) {
            $params = array(
                'name' => $accountingCode,
                'description' => $accountingCode,
                'contact_id' => 1,
                'financial_account_type' => 2,
                'accounting_code' => $accountingCode,
                'is_reserved' => 0,
                'is_tax' => 1,
                'tax_rate' => 8,
                'is_active' => TRUE
            );
            $financialAccountId = CRM_Financial_BAO_FinancialAccount::add($params)->id;
        }
        $this->_tax_account_id = $financialAccountId;



        foreach ($this->_fileData as $row) {
            $this->createAccount("CSC", "Current Year", $row);
            $this->createAccount("CSChE", "Current Year", $row);
            $this->createAccount("CSCT", "Current Year", $row);
            $this->createAccount("CIC", "Current Year", $row);
            $this->createAccount("CSC", "Next Year", $row);
            $this->createAccount("CSChE", "Next Year", $row);
            $this->createAccount("CSCT", "Next Year", $row);
            $this->createAccount("CIC", "Next Year", $row);
        }
    }

    private function createAccount($society, $year, $row) {
        $accountNum = $row["Account $society/$year"];
        if (!$accountNum) {
            return;
        }
        if ($this->isEmpty($accountNum)) {
            return;
        }
        $exempt = ("yes" == strtolower($row["Exempt"]));
        $financeType = $this->getFinanceType($accountNum, $exempt, $society, $year, $row);

        $amount = $row['Amount'];

        $this->createFinancialAccountIfMissing($accountNum);
        $this->createFinancialTypeIfMissing($financeType, $accountNum, $exempt, $amount);
    }

    private function parse($inputString, $society, $year) {
        $toReturn = $inputString;
        $toReturn = str_replace('${Society}', $society, $toReturn);
        $toReturn = str_replace('${Year}', "$year Year", $toReturn);
        if ("$year" == "Current") {
            $toReturn = str_replace('${YearNC}', "", $toReturn);
        } else {
            $toReturn = str_replace('${YearNC}', "Future - ", $toReturn);
        }
        return $toReturn;
    }

    private function getFinanceType($accountNum, $exempt, $society, $year, $row) {
        $yearShort = ("Current Year" == $year) ? "CY" : "FY";
        $ftName = $row['Financial Type'];
        if (!$ftName) {
            $ftName = $row['Field Value'];
        }
        $ftName = $this->parse($ftName, $society, $year);

        $ftTax = $exempt ? " (exempt)" : "";

        if ($this->allRowAccountsSame($row)) {
            // everything is same account, don't include society or year.
            $financeType = "$ftName $accountNum$ftTax";
        } else if ($this->allRowAccountsSameRegardlessOfSociety($row)) {
            // same for all societies, but different accoutns for cur/prev
            $financeType = "$ftName $accountNum $yearShort$ftTax";
        } else if (strpos($ftName, $society) === FALSE) {
            // everything is different.  Soceity name not present, make sure to included it.
            $financeType = "$society $ftName $accountNum $yearShort$ftTax";
        } else {
            // everything is different.  Make sure society name is present. (was already in ftName)
            $financeType = "$ftName $accountNum $yearShort$ftTax";
        }
        return $financeType;
    }

    private function allRowAccountsSame($row) {
        $base;
        foreach ($row as $key => $value) {
            if (!(substr($key, 0, 7) == "Account")) {
                continue;
            }
            if ($this->isEmpty($value)) {
                continue;
            }
            if (!isset($base)) {
                $base = $value;
                continue;
            }
            if ($value != $base) {
                return false;
            }
        }
        return true;
    }

    private function allRowAccountsSameRegardlessOfSociety($row) {
        $baseCY;
        $baseFY;
        foreach ($row as $key => $value) {
            if (!(substr($key, 0, 7) == "Account")) {
                continue;
            }
            if ($this->isEmpty($value)) {
                continue;
            }
            if (strpos($key, "Current")) {
                if (!isset($baseCY)) {
                    $baseCY = $value;
                    continue;
                }
                if ($baseCY != $value) {
                    return false;
                }
            } else {
                if (!isset($baseFY)) {
                    $baseFY = $value;
                    continue;
                }
                if ($baseFY != $value) {
                    return false;
                }
            }
        }
        return true;
    }

    private function createFinancialTypeIfMissing($financeType, $accountingCode, $exempt, $amount) {
        $financialAccountId = CRM_Financial_DAO_FinancialAccount::getFieldValue('CRM_Financial_DAO_FinancialAccount', $accountingCode, 'id', 'accounting_code', TRUE);
        if ($financialAccountId == FALSE) {
            throw new Exception("Missing account '" . $accountingCode . ".'");
        }
        $financeTypeId = CRM_Financial_DAO_FinancialType::getFieldValue('CRM_Financial_DAO_FinancialType', $accountingCode, 'id', 'name', TRUE);
        $incomeAccountRelType = key(CRM_Core_PseudoConstant::accountOptionValues('account_relationship', NULL, " AND v.name LIKE 'Income Account is' "));

        if ($financeTypeId == FALSE) {

            // Create FInancial Type
            $params = array(
                'name' => $financeType,
            );
            $ftDAO = new CRM_Financial_DAO_FinancialType();
            $ftDAO->name = $accountingCode;
            $ftDAO->description = $financeType;
            $ftDAO->is_active = 1;
            $ftDAO->is_reserved = 0;
            $ftDAO->is_deductible = 0;
            $financeTypeId = $ftDAO->insert();

            // Create Other Types using 'Member Dues' as an example, exclude 'income account is.
            // we'll do that one manually.
            $sql = "insert into civicrm_entity_financial_account(entity_table, entity_id, account_relationship, financial_account_id) " .
                    "select entity_table, $financeTypeId, account_relationship, financial_account_id " .
                    "  from civicrm_entity_financial_account a, civicrm_option_group g, civicrm_option_value v " .
                    " where entity_table = 'civicrm_financial_type' " .
                    "   and entity_id = (select id from civicrm_financial_type ft where ft.name = 'Member Dues') " .
                    "   and g.name = 'account_relationship' " .
                    "   and v.option_group_id = g.id " .
                    "   and a.account_relationship = v.value " .
                    "   and not v.name like 'Income Account is' ";
            CRM_Financial_DAO_FinancialType::executeQuery($sql);

            $dao = new CRM_Financial_DAO_EntityFinancialAccount();
            $dao->entity_table = 'civicrm_financial_type';
            $dao->entity_id = $financeTypeId;
            $dao->account_relationship = $incomeAccountRelType;
            $dao->financial_account_id = $financialAccountId;
            $dao->insert();

            if (!$exempt && $amount != 0) {
                $dao = new CRM_Financial_DAO_EntityFinancialAccount();
                $dao->entity_table = 'civicrm_financial_type';
                $dao->entity_id = $financeTypeId;
                $dao->account_relationship = 10;
                $dao->financial_account_id = $this->_tax_account_id;
                $dao->insert();
            }
        }
    }

    private function createFinancialAccountIfMissing($accountingCode) {
        $financialAccountId = CRM_Financial_DAO_FinancialAccount::getFieldValue('CRM_Financial_DAO_FinancialAccount', $accountingCode, 'id', 'accounting_code', TRUE);
        if (!$financialAccountId) {
            $params = array(
                'name' => $accountingCode,
                'description' => $accountingCode,
                'contact_id' => 1,
                'financial_account_type' => 3,
                'accounting_code' => $accountingCode,
                'is_reserved' => 0,
                'is_active' => TRUE
            );
            CRM_Financial_BAO_FinancialAccount::add($params);
        }
    }

    private function openCsv() {
        $handle = fopen($this->priceSetFile['tmp_name'], "r");
        if ($handle == FALSE) {
            throw new Exception("Unable to open " + $this->priceSetFile['name']);
        }
        $this->row = 0;
        if (!isset($this->headers)) {
            $this->loadHeaders($handle);
        } else {
            // skip row
            fgetcsv($handle);
        }


        return $handle;
    }

    private function importFinancialTypes() {
        
    }

    private function importPriceSets() {
        $handle = $this->openCsv();
        $this->processData($handle);
        fclose($handle);

        $this->save();
    }

    private function save() {
        foreach ($this->fields as $options) {
            CRM_Price_BAO_PriceField::create($options);
        }
    }

    private function addOption(&$fieldDef, $fee, $desc, $memTypeName, $financialTypeId) {
        array_push($fieldDef['option_label'], $desc);
        array_push($fieldDef['option_description'], $desc);
        if ("User" == $fee) {
            array_push($fieldDef['option_amount'], 1);
        } else {
            array_push($fieldDef['option_amount'], $fee);
        }

        array_push($fieldDef['option_financial_type_id'], $financialTypeId);
        $weight = count($fieldDef['option_weight']);
        array_push($fieldDef['option_weight'], $weight);


        if (!$this->isEmpty($memTypeName)) {
            $memTypeId = CRM_Member_DAO_MembershipType::getFieldValue("CRM_Member_DAO_MembershipType", $memTypeName, "id", "name", TRUE);
            if (empty($memTypeId)) {
                throw new Exception("Membership type '" . $desc . "' does not exist as a membership type");
            }
            array_push($fieldDef['membership_num_terms'], 1);
            $membershipType = $memTypeId;
        } else {
            $membershipType = null;
            array_push($fieldDef['membership_num_terms'], null);
        }
        array_push($fieldDef['membership_type_id'], $membershipType);
    }

    private function createNewField($priceSetId, $weight, $fieldName, $typeIn, $desc, $required, $fee) {
        $type = $this->getType($typeIn);

        $fieldDef = array();
        $fieldDef['name'] = $fieldName;
        $fieldDef['price_set_id'] = $priceSetId;
        $fieldDef['html_type'] = $type;
        $fieldDef['Type'] = $typeIn;
        $fieldDef['label'] = $desc;
        $fieldDef['is_required'] = $required;
        $fieldDef['weight'] = $weight;
        if ("User" == $fee) {
            $fieldDef['is_display_amounts'] = 0;
            $fieldDef['is_enter_qty'] = 1;
        } else {
            $fieldDef['is_display_amounts'] = 1;
            $fieldDef['is_enter_qty'] = 0;
        }


        // WTF... First row is always empty, because of a bug in PriceField.php
        $fieldDef['option_label'] = array('');
        $fieldDef['option_description'] = array('');
        $fieldDef['option_amount'] = array('');
        $fieldDef['membership_type_id'] = array('');
        $fieldDef['membership_num_terms'] = array('');
        $fieldDef['option_financial_type_id'] = array('');
        $fieldDef['option_weight'] = array('');

        return $fieldDef;
    }

    private function createPriceSetFieldsAndOptions($society, $year, $priceSetIn, $priceSetId) {
        $priceSetFields = array();

        $cnt = 0;
        foreach ($this->_fileData as $row) {
            $field = $row['Field'];
            if ($this->isEmpty($field)) {
                continue;
            }
            $fieldOption = $row['Field Value'];
            if ($this->isEmpty($fieldOption)) {
                continue;
            }
            $account = $row["Account $society/$year Year"];
            if ($this->isEmpty($account)) {
                continue;
            }

            $exempt = ("yes" == strtolower($row["Exempt"]));
            $required = ("yes" == strtolower($row["Mandatory"]));

            $financeType = $this->getFinanceType($account, $exempt, $society, "$year Year", $row);
            $financeTypeId = CRM_Financial_DAO_FinancialType::getFieldValue('CRM_Financial_DAO_FinancialType', $account, 'id', 'name', TRUE);
            if (!$financeTypeId) {
                throw new Exception("Unable to determine finance type for $financeType / $society / $year / $field / $fieldOption");
            }

            $field = $this->parse($field, $society, $year);

            $priceSet = $this->parse($row['Price Set'], $society, $year);
            $type = $this->getType($row['Type']);

            if ($priceSet != $priceSetIn) {
                continue;
            }
            $cnt++;

            $fee = $row['Amount'];
            if (!array_key_exists($field, $priceSetFields)) {
                $priceSetFields[$field] = $this->createNewField($priceSetId, $cnt, $field, $type, $field, $required, $fee);
            }

            $memTypeName = $this->parse($row['Membership Type'], $society, $year);
            $fee = $row['Amount'];
            $desc = $this->parse($row['Field Value'], $society, $year);

            $this->addOption($priceSetFields[$field], $fee, $desc, $memTypeName, $financeTypeId);
        }

        foreach ($priceSetFields as $key => $options) {
            CRM_Price_BAO_PriceField::create($options);
        }
    }

    private function getType($typeIn) {
        $validTypes = CRM_Price_BAO_PriceField::htmlTypes();
        if (isset($validTypes[$typeIn])) {
            return $typeIn;
        }
        $lowerTypeIn = strtolower($typeIn);
        foreach ($validTypes as $key => $value) {
            $lowerKey = strtolower($key);
            $lowerValue = strtolower($value);
            if (strcmp($lowerKey, $lowerTypeIn) == 0 || strcmp($lowerValue, $lowerTypeIn) == 0) {
                return $value;
            }
        }
        throw new Exception("Type " . $typeIn . " is not valid on row #" . $this->row);
    }

    private function get($data, $column, $mandatory) {
        $value = trim(
                $data[$this->columnIndexes[$column]]
        );
        if ($mandatory && empty($value)) {
            throw new Exception("Column '" . $column . "' is missing in row #" . $this->row);
        }
        if (!empty($value)) {
            return str_replace('${Society}', $this->society, $value);
        } else {
            return $value;
        }
    }

    private function isEmpty($str) {
        if (!$str) {
            return true;
        }
        if (strtolower($str) == 'n/a') {
            return true;
        }
        if (trim($str) === '') {
            return true;
        } else {
            return false;
        }
    }

}
