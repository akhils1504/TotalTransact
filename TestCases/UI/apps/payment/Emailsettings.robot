*** Settings ***
Documentation       Creating A Customer in Specified Enviornment

Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary   
Library    ../../../../Libraries/Selenium/Selenium2LibraryMBExtended/__init__.py                                                              locale=en_US
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource
Resource    ../

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 A User Login to Payment Portal clicks on Settings tab
Test Teardown    Run keywords    Test Ui Teardown                   
Suite Teardown    Teardown Test Suite

*** Variables ***
${add_row}=    Set Variable    0

*** Keywords ***
Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

A User Login to Payment Portal clicks on Settings tab
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV005

User select Account Location
    Select Combobox Value JS    \#paymentsettingspanel > #accountlocationcombobox    Downtown
    Sleep    10s   #Dont remove failing  TC             
    
User select Email Settings tab
     Execute Javascript    var tabPanel = Ext.ComponentQuery.query('#tier2settingstabpanel')[0],
             ...               hppTab = Ext.ComponentQuery.query('#emailsettingspanel')[0];
             ...               tabPanel.setActiveTab(hppTab);
     Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Merchant    timeout=20s 
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Change Next Payment Date     timeout=30s
      
User checking all the checkboxes under the Merchant
    Execute Javascript    Ext.ComponentQuery.query('#checkboxescontainer #merchant')[0].setValue(true);
    
User checking all the checkboxes under the Account Location
    Execute Javascript    Ext.ComponentQuery.query('#checkboxescontainer #accountlocation')[0].setValue(true);
        
User checking all the checkboxes under the Customer Location
    Execute Javascript    Ext.ComponentQuery.query('#checkboxescontainer #customer')[0].setValue(true);
         
User unchecking all the checkboxes under the Merchant
    Execute Javascript    Ext.ComponentQuery.query('#checkboxescontainer #merchant')[0].setValue(false);
    
User unchecking all the checkboxes under the Account Location
    Execute Javascript    Ext.ComponentQuery.query('#checkboxescontainer #accountlocation')[0].setValue(false);
        
User unchecking all the checkboxes under the Customer Location
    Execute Javascript    Ext.ComponentQuery.query('#checkboxescontainer #customer')[0].setValue(false);
    
Adding email keyword
    [Arguments]    ${add_row}
    Execute Javascript    var txtfld = Ext.ComponentQuery.query("sharedtriggertextfield")[${add_row}].down('textfield').setValue("test${add_row}@email.com");
             ...               var btn = Ext.ComponentQuery.query("sharedtriggertextfield")[${add_row}].down('button');
             ...               btn.fireEvent("click", btn);

Adding new emails to all the rows
    FOR    ${add_row}    IN RANGE    0    18    
    \    Run Keyword    Adding email keyword    ${add_row}
    END
    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    test${add_row}@email.com    timeout=20s     

Adding invalid email keyword
    [Arguments]    ${add_row}    ${test_data}
    Execute Javascript    var txtfld = Ext.ComponentQuery.query("sharedtriggertextfield")[${add_row}].down('textfield').setValue("${test_data}");
             ...               var btn = Ext.ComponentQuery.query("sharedtriggertextfield")[${add_row}].down('button');
             ...               btn.fireEvent("click", btn);

Adding invalid emails to all the rows with a space in between the email
    FOR    ${add_row}    IN RANGE    0    18    
    \    Run Keyword    Adding invalid email keyword    ${add_row}    tes${SPACE}${SPACE}ting@gmail.com
    \    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Can't add email addresses.    timeout=20s   
    \    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok 
 

Adding invalid emails to all the rows with only spaces
    FOR    ${add_row}    IN RANGE    0    18    
    \    Run Keyword    Adding invalid email keyword    ${add_row}    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
    \    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Can't add email addresses.    timeout=20s   
    \    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok 

Adding invalid emails to all the rows with numbers only
    FOR    ${add_row}    IN RANGE    0    18    
    \    Run Keyword    Adding invalid email keyword    ${add_row}    123456
    \    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Can't add email addresses.    timeout=20s   
    \    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok 
                        
Adding invalid emails to all the rows with special characters only
    FOR    ${add_row}    IN RANGE    0    18    
    \    Run Keyword    Adding invalid email keyword    ${add_row}    @_|.,;
    \    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Can't add email addresses.    timeout=20s   
    \    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok 

Adding invalid emails to all the rows with only empty value
    FOR    ${add_row}    IN RANGE    0    18    
    \    Run Keyword    Adding invalid email keyword    ${add_row}    ${EMPTY}
    \    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Can't add email addresses.    timeout=20s   
    \    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok 

Removing email keyword
    [Arguments]    ${remove_row}
    Execute Javascript    removeBtn = Ext.ComponentQuery.query("sharedtriggerdisplayfield")[${remove_row}].down("button");
                 ...          removeBtn.fireEvent("click",removeBtn);
            
Removing added emails from all the rows
    ${remove_row_seventeen}=    Set Variable    17
    ${flag}=    Set Variable    0
    FOR    ${flag}    IN RANGE    0    18    
    \    Run Keyword    Removing email keyword    ${remove_row_seventeen}
    \    ${remove_row_seventeen}=    Set Variable    ${remove_row_seventeen}-1
    \    ${flag}=    Set Variable    ${flag}+1
    
User clicking on the Save button
    Execute Javascript    var btn=Ext.ComponentQuery.query("#savebutton[text=Save Changes]")[0];
             ...               btn.fireEvent("click",btn); 
    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Email setting updated successfully    timeout=20s 
             
Verifying on clicking the OK button
    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Status    timeout=20s 
    Wait Until Keyword Succeeds    15s    15s    Wait until page contains    Email setting updated successfully    timeout=20s  
    Wait Until Keyword Succeeds    15s    15s    Wait Until Ext Element Is Enabled    \#ok 
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok
         
*** Test Cases ***
To verify the functionality of available checkboxes by selecting all
    
    [Tags]    Smoke    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User checking all the checkboxes under the Merchant
    And User checking all the checkboxes under the Account Location
    And User checking all the checkboxes under the Customer Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
     
To verify whether user can Save after Entering Emails into all corresponding textboxes and checking all the checkboxes
    
    [Tags]    Smoke    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When Adding new emails to all the rows    
    Then User clicking on the Save button
    And Verifying on clicking the OK button
   
To verify whether user can Save after Entering Emails into all corresponding textboxes and unchecking all the checkboxes
    
    [Tags]    Smoke    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When Adding new emails to all the rows    
    And User unchecking all the checkboxes under the Merchant
    And User unchecking all the checkboxes under the Account Location
    And User unchecking all the checkboxes under the Customer Location
    Then User clicking on the Save button
    And Verifying on clicking the OK button

To verify whether the user can Save after removing Emails from all corresponding textboxes and by retainig all the checked chekboxes
    
    [Tags]    Smoke    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When Removing added emails from all the rows
    And User checking all the checkboxes under the Merchant
    And User checking all the checkboxes under the Account Location
    And User checking all the checkboxes under the Customer Location
    Then User clicking on the Save button
    And Verifying on clicking the OK button    
    
To verify whether the functionality of checkboxes by unselecting all available checkboxes and saving
    
    [Tags]    Smoke    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User unchecking all the checkboxes under the Merchant
    And User unchecking all the checkboxes under the Account Location
    And User unchecking all the checkboxes under the Customer Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
    
To verify the functionality of all available Merchants checkboxes by selecting the master checkbox option
    
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User checking all the checkboxes under the Merchant
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
    
To verify the functionality of available Account Locations checkboxes by selecting the master checkbox option
    
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User checking all the checkboxes under the Account Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button

To verify the functionality of available Customer checkboxes by selecting the master checkboxe option
    
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User checking all the checkboxes under the Customer Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
    
To verify the functionality of available Merchants checkboxes by unselecting the master checkbox option
    
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User unchecking all the checkboxes under the Merchant
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
       
To verify the functionality of available Account Locations checkboxes by unselecting the master checkboxes option
    
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User unchecking all the checkboxes under the Account Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button

To verify the functionality of available Customer checkboxes by unselecting the master checkbox option
    
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab 
    When User unchecking all the checkboxes under the Customer Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
    
To verify the functionality by Saving with Merchants checkboxes master as selected and Email in all the fields
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab
    When Adding new emails to all the rows 
    And User checking all the checkboxes under the Merchant
    Then User clicking on the Save button      
    And Verifying on clicking the OK button
    
To verify the functionality by Saving with Account Locations checkboxes master as selected and Email in all the fields
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab
    When User unchecking all the checkboxes under the Merchant 
    And User checking all the checkboxes under the Account Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button    
    
To verify the functionality by Saving with Customer checkboxes master as selected and Email in all the fields
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab
    When User unchecking all the checkboxes under the Account Location
    And User checking all the checkboxes under the Customer Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button    
    
Unselecting all the master checkboxes and Saving without any emails
    [Tags]    Regression    
    Given User select Account Location  
    And User select Email Settings tab
    When Removing added emails from all the rows
    And User unchecking all the checkboxes under the Merchant
    And User unchecking all the checkboxes under the Account Location
    And User unchecking all the checkboxes under the Customer Location
    Then User clicking on the Save button      
    And Verifying on clicking the OK button   
    
Verifying the working of an invalid email with spaces in between a valid email
    [Tags]    Negative    Regression 
    [Documentation]    test ing@gmail is sample test data
    Given User select Account Location  
    And User select Email Settings tab
    When Adding invalid emails to all the rows with a space in between the email
    Then User clicking on the Save button
    And Verifying on clicking the OK button

Verifying the working of an invalid email with only spaces
    [Tags]    Negative    Regression 
    Given User select Account Location  
    And User select Email Settings tab
    When Adding invalid emails to all the rows with only spaces  
    Then User clicking on the Save button
    And Verifying on clicking the OK button

Verifying the working of an invalid email with only numbers 
    [Tags]    Negative    Regression 
    [Documentation]    123456 is sample test data
    Given User select Account Location  
    And User select Email Settings tab
    When Adding invalid emails to all the rows with numbers only
    Then User clicking on the Save button
    And Verifying on clicking the OK button
     
Verifying the working of an invalid email with only special characters
    [Tags]    Negative    Regression 
    [Documentation]    @_|.,; is sample test data
    Given User select Account Location  
    And User select Email Settings tab
    When Adding invalid emails to all the rows with special characters only
    Then User clicking on the Save button
    And Verifying on clicking the OK button

Verifying the working of an invalid email with an empty value
    [Tags]    Negative    Regression 
    [Documentation]    ${EMPTY} is sample test data
    Given User select Account Location  
    And User select Email Settings tab
    When Adding invalid emails to all the rows with only empty value
    Then User clicking on the Save button
    And Verifying on clicking the OK button
    
