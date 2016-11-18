<?php

require_once 'tools.civix.php';

/**
 * Implements hook_civicrm_config().
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_config
 */
function tools_civicrm_config(&$config) {
  _tools_civix_civicrm_config($config);
}

/**
 * Implements hook_civicrm_xmlMenu().
 *
 * @param array $files
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_xmlMenu
 */
function tools_civicrm_xmlMenu(&$files) {
  _tools_civix_civicrm_xmlMenu($files);
}

/**
 * Implements hook_civicrm_install().
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_install
 */
function tools_civicrm_install() {
  _tools_civix_civicrm_install();
}

/**
 * Implements hook_civicrm_uninstall().
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_uninstall
 */
function tools_civicrm_uninstall() {
  _tools_civix_civicrm_uninstall();
}

/**
 * Implements hook_civicrm_enable().
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_enable
 */
function tools_civicrm_enable() {
  _tools_civix_civicrm_enable();
}

/**
 * Implements hook_civicrm_disable().
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_disable
 */
function tools_civicrm_disable() {
  _tools_civix_civicrm_disable();
}

/**
 * Implements hook_civicrm_upgrade().
 *
 * @param $op string, the type of operation being performed; 'check' or 'enqueue'
 * @param $queue CRM_Queue_Queue, (for 'enqueue') the modifiable list of pending up upgrade tasks
 *
 * @return mixed
 *   Based on op. for 'check', returns array(boolean) (TRUE if upgrades are pending)
 *                for 'enqueue', returns void
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_upgrade
 */
function tools_civicrm_upgrade($op, CRM_Queue_Queue $queue = NULL) {
  return _tools_civix_civicrm_upgrade($op, $queue);
}

/**
 * Implements hook_civicrm_managed().
 *
 * Generate a list of entities to create/deactivate/delete when this module
 * is installed, disabled, uninstalled.
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_managed
 */
function tools_civicrm_managed(&$entities) {
  _tools_civix_civicrm_managed($entities);
}

/**
 * Implements hook_civicrm_caseTypes().
 *
 * Generate a list of case-types.
 *
 * @param array $caseTypes
 *
 * Note: This hook only runs in CiviCRM 4.4+.
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_caseTypes
 */
function tools_civicrm_caseTypes(&$caseTypes) {
  _tools_civix_civicrm_caseTypes($caseTypes);
}

/**
 * Implements hook_civicrm_angularModules().
 *
 * Generate a list of Angular modules.
 *
 * Note: This hook only runs in CiviCRM 4.5+. It may
 * use features only available in v4.6+.
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_caseTypes
 */
function tools_civicrm_angularModules(&$angularModules) {
_tools_civix_civicrm_angularModules($angularModules);
}

/**
 * Implements hook_civicrm_alterSettingsFolders().
 *
 * @link http://wiki.civicrm.org/confluence/display/CRMDOC/hook_civicrm_alterSettingsFolders
 */
function tools_civicrm_alterSettingsFolders(&$metaDataFolders = NULL) {
  _tools_civix_civicrm_alterSettingsFolders($metaDataFolders);
}

function tools_civicrm_validateForm($formName, &$submitValues, &$submittedFiles, &$form, &$hookErrors) {
  if ($formName == 'CRM_Contribute_Form_Contribution_Main') {
    if (isTooCurrent('email', $submitValues['email-5'])) {
      $hookErrors['_qf_default'] = 'Your membership is already up-to-date.  It is too early to renew';
    }

    if (isTooCurrent('id', $submitValues['select_contact_id'])) {
      $hookErrors['_qf_default'] = 'Your membership is already up-to-date.  It is too early to renew';
    }
  }

}

function isTooCurrent($field, $value) {
  $contact= civicrm_api3('Contact', 'get', array(
    'sequential' => 1,
    $field => $value,
  ));
  if (empty($contact['values'])) {
    return FALSE;
  }

  $result = civicrm_api3('Membership', 'get', array(
    'sequential' => 1,
    'contact_id' => $contact['values'][0]['contact_id'],
    'status_id' => 1
  ));

  if (!empty($result['values'])) {
    return TRUE;
  }

  $result = civicrm_api3('Membership', 'get', array(
    'sequential' => 1,
    'contact_id' => $contact['values'][0]['contact_id'],
    'status_id' => 2
  ));

  if (!empty($result)) {
    return TRUE;
  }
}


function tools_civicrm_buildForm($formName, &$form) {
  // This is a cheap replacement of "hidden_taxes", special contribution element
  // it replaces "hidden_taxes", the label used to trigger the tax logic into
  // something more user friendly (i.e., 'Taxes').  It is done only on
  // Contribution Confirmation & Contribution Thank you pages
  if ($formName == 'CRM_Contribute_Form_Contribution_Confirm' ||
        $formName == 'CRM_Contribute_Form_Contribution_ThankYou'
  ) {
    $priceSets = $form->get_template_vars('lineItem');
    if (empty($priceSets)) {
      return;
    }
    foreach ($priceSets as $priceSetId => &$priceFields) {
      foreach ($priceFields as $priceFieldId => &$priceFieldFields) {
        if ($priceFieldFields['label'] == 'hidden_taxes') {
          $priceFieldFields['label'] = 'Taxes';
        }
        if ($priceFieldFields['description'] == 'hidden_taxes') {
          $priceFieldFields['description'] = 'Taxes';
        }
      }
    }
    $form->assign('lineItem', $priceSets);
  }
}


function hook_civicrm_pageRun( &$page ) {
    $page -> assign('Name', 'John Doe');    
}
