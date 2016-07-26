<?php

require_once 'CRM/Core/Page.php';

class CRM_Tools_Page_ImportPriceSet extends CRM_Core_Page {
    
  public function run() {
    // Example: Set the page-title dynamically; alternatively, declare a static title in xml/Menu/*.xml
    CRM_Utils_System::setTitle(ts('ImportPriceSet'));
    
    if (isset($_FILES["csvFile"])) {
        $this->handleIncomingFile($_FILES["csvFile"]);
    } else {
        $this->showForm();
    }

    parent::run();
  }
  

  
  public function handleIncomingFile($csvFile) {
      $importer = new CRM_Tools_PriceSetImporter($csvFile);
      $importer->import();

  }
  
  
  public function showForm() {
  }
  
  public static function guessSociety($name) {
      if (strpos(strtolower($name), "csche") !== FALSE) {
          return "CSChE";
      }
      if (strpos(strtolower($name), "csct") !== FALSE) {
          return "CSCT";
      }
      if (strpos(strtolower($name), "csc_") !== FALSE) {
          return "CSC";
      } else {
          return "Non Member";
      }

      
  }
}