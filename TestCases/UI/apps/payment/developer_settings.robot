*** Settings ***
Documentation    Creating an API Key, Editing and Deleting an API Key

Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary                                                             locale=en_US
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
Test Teardown     Test Ui Teardown
Suite Teardown    Teardown Test Suite

*** Variables ***


*** Keywords ***

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV005
    Select Account Location
     
Select Account Location
    Wait Until Keyword Succeeds    60s  15ms   Select Combobox Value JS  \#paymentsettingspanel > #accountlocationcombobox    Downtown
    
Check Uncheck Chekbox
    [Arguments]    ${rowKey}    ${rowVal}    ${columnLocator}    ${checkVal}
    Execute Javascript    var chkcol = Ext.ComponentQuery.query('${columnLocator}')[0];
            ...               Ext.ComponentQuery.query('${columnLocator}')[0].up('grid').getStore().findRecord('${rowKey}', '${rowVal}').set('isenabled', ${checkVal});     
            ...               chkcol.fireEvent('checkchange', chkcol, chkcol.up('grid').getStore().find('${rowKey}', '${rowVal}'), ${checkVal});
        
*** Test Cases ***
Generate New API Key
    [Tags]    Smoke    Regression
    Execute Javascript    var tabPanel = Ext.ComponentQuery.query('#tier2settingstabpanel')[0],
            ...               developerSettingsTab = Ext.ComponentQuery.query('#developersettingspanel')[0];
            ...               tabPanel.setActiveTab(developerSettingsTab);
    Select Account Location
    Sleep    15s
    ${api_key}=  Generate Random String  length=8   chars=[LETTERS]
    Set Textfield Value JS    \#additemcontainer > #name    ${api_key}
    Set Suite Variable        \${api_key}  ${api_key}
    ${genBtn}    Set Variable    Ext.ComponentQuery.query("#addbutton")[2]
    Execute Javascript    ${genBtn}.fireEvent('click',${genBtn});
    Wait Until Page Contains    API Key Generated  
    Click Ext button JS    \#ok  
    

Edit(Enable/Disable) API Key    
    [Tags]    Smoke    Regression    
    Execute Javascript    var tabPanel = Ext.ComponentQuery.query('#tier2settingstabpanel')[0],
            ...               developerSettingsTab = Ext.ComponentQuery.query('#developersettingspanel')[0];
            ...               tabPanel.setActiveTab(developerSettingsTab);
    Select Account Location
    Sleep    10s
    Check Uncheck Chekbox    name    ${api_key}   \#apikeyspanel gridpanel checkcolumn    false
    Wait Until Page Contains    Item edited successfully.    
    Click Ext button JS    \#ok
    
Remove API Key Record    
    [Tags]    Smoke    Regression   
   Execute Javascript    var tabPanel = Ext.ComponentQuery.query('#tier2settingstabpanel')[0],
            ...               developerSettingsTab = Ext.ComponentQuery.query('#developersettingspanel')[0];
            ...               tabPanel.setActiveTab(developerSettingsTab);
    Select Account Location
    Sleep    10s    
    Click Grid Row           \#savedapikeysgridpanel    name    ${api_key}
    Execute Javascript         grid = Ext.ComponentQuery.query('#savedapikeysgridpanel')[0];
             ...               removebtn = Ext.getCmp(grid.getView().getCell(grid.getStore().findRecord('name','${api_key}'), grid.columns[3]).down('.adjusted').id);
             ...               removebtn.fireEvent('click',removebtn);            
    Wait Until Page Contains    Are you sure that you want to delete this item?  
    Click Ext Button JS    \#ok  
    sleep    2s  
    Page Should Not Contain    ${api_key}      
    

