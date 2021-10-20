*** Settings ***
Documentation    Creating an Individual and a Business Customer with ACH and CC payment accounts and Search for a specific customer and multiple operations for scheduled payments

Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary
Library     DateTime                                                            
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
Test Teardown     Test Ui Teardown
Suite Teardown    Teardown Test Suite

*** Variables ***
${latency_time}  5s
# ${refresh_btn}         (//span[@class="x-btn-icon-el x-tbar-loading "])[2]

*** Keywords ***

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Payments')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV001

User Select Account Location 
    Wait Until Keyword Succeeds    25s  15s   Select Combobox Value JS  \#onetimepaymentcontainer > #accountlocationcombobox    Downtown
User clicks on Add customer button
    Click Ext Button JS     \#addcustomerbutton{isVisible(true)}  
    Wait Until Page Contains    Add New Customer      timeout=15s  
User creates an ACH customer
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                          ${customerid}
    ${first_name}=  First Name Male
    Set Textfield Value JS   \#addcustomerwindow #firstname                           ${first_name}John
    ${last_name}=  Last Name Male
    Set Textfield Value JS   \#addcustomerwindow #lastname                            ${last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                            491 South Van
    Set Textfield Value JS   \#addcustomerwindow #city                                Wales   
    Set Textfield Value JS   \#addcustomerwindow #state                               FL
    Set Textfield Value JS   \#addcustomerwindow #postalcode                          24576-6642
    Sleep    ${latency_time}
    Set Textfield Value JS   \#addcustomerwindow #routingnumber                       011000015
    ${account_number}=  Generate Random String  length=10   chars=[NUMBERS]
    Set Textfield Value JS   \#addcustomerwindow #accountnumber                        ${account_number}
  
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    Sleep    ${latency_time}
    Set Textfield Value JS    \#addcustomerwindow #accountname                        UTF ACH Created ${month}${random_word}
    Set Textfield Value JS    \#addcustomerwindow #customername                       UTF ACH Created ${month}${random_word}
   ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                        ${phone_number}
    ${email_address}    Email    
    Set Textfield Value JS    \#addcustomerwindow #emailaddress                       ${email_address}
    Sleep    ${latency_time}
    Click Ext button JS    \#savebutton{isVisible(true)}
    Sleep    ${latency_time}
    Set Suite Variable    \${first_name}   ${first_name}John  
 User adds OTP details for an ACH Customer
    Sleep    ${latency_time}
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance    ${amount}.00
    Sleep    ${latency_time}
    Execute Javascript         Ext.ComponentQuery.query('#writtenauthorization')[0].setValue(true);
    Execute Javascript         Ext.ComponentQuery.query('#authorizationcheckbox')[0].setValue(true);
User clicks on create payment button
    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
Payment is successfully created
   Sleep    ${latency_time}
User copies the transaction ID from the Payment receipt screen  
    Wait Until Page Contains     Transaction has been processed successfully!
    ${external_id}=  Execute Javascript  return Ext.ComponentQuery.query('#paymentreceiptwindow')[0].paymentDetails.externalid;
    Set Suite Variable    \${external_id}  ${external_id}
    Click Ext button JS        \#closebutton{isVisible(true)}
    
User navigates to Research tab
    
 	Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Research')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV013
    Sleep    5s
    
User enters begin and end date
      Wait Until Page Contains    Transaction    timeout=10s
     ${today}    Get Current Date    result_format=%m/%d/%Y
     # ${begin_date}    Subtract Time From Date    ${today}   2d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
     # ${end_date}      Subtract Time From Date    ${today}    1d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Wait Until Page Contains    Begin Date    timeout=15s
    Sleep  2s
    Set Datefield Value JS  \#researchtxncontainer #begindate   ${today}
    Set Datefield Value JS  \#researchtxncontainer #enddate     ${today} 
    
User enters ACH search criteria and hit Submit button
    
    Set Textfield Value JS  \#researchtxncontainer #searchcriteria     ACH
    Sleep     2s
    ${submitBtn}    Set Variable     Ext.ComponentQuery.query('#researchtxncontainer #submitbutton')[0]
    Execute Javascript    ${submitBtn}.fireEvent('click',${submitBtn});
    Sleep     30s
Transaction results are displayed
   
    Wait Until Page Contains    Transaction Results    timeout=50s
    # Reload page
    Sleep  5s
    
User enters dates and CARD search criteria 
     ${begin_date}    Subtract Time From Date    ${today}   2d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
     # ${end_date}      Subtract Time From Date    ${today}    1d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Set Datefield Value JS  \#researchtxncontainer #begindate  ${begin_date}
    Set Datefield Value JS  \#researchtxncontainer #enddate     ${today}  
    Set Textfield Value JS  \#researchtxncontainer #searchcriteria     CARD
    Sleep 	2s
User hits submit button
    ${submitBtn}    Set Variable     Ext.ComponentQuery.query('#researchtxncontainer #submitbutton')[0]
    Execute Javascript    ${submitBtn}.fireEvent('click',${submitBtn});
       Sleep     30s
User sets a date range for 30 days
     ${today}    Get Current Date    result_format=%m/%d/%Y
     ${begin_date}    Subtract Time From Date    ${today}   30d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Set Datefield Value JS  \#researchtxncontainer #begindate  ${begin_date}
    Set Datefield Value JS  \#researchtxncontainer #enddate     ${today} 

User enters the transction ID in Search criteria and hit Submit button
    Set Textfield Value JS  \#researchtxncontainer #searchcriteria     ${external_id}
    Sleep     2s
   ${submitBtn}    Set Variable     Ext.ComponentQuery.query('#researchtxncontainer #submitbutton')[0]
    Execute Javascript    ${submitBtn}.fireEvent('click',${submitBtn});
Searched Transaction is displayed
    Wait Until Page Contains    ${external_id}    timeout=20s
*** Test Cases ***

Create ACH One Time Payment
    [Tags]    Smoke    Regression
    Given User Select Account Location
	And User clicks on Add customer button
    And User creates an ACH customer
    And User adds OTP details for an ACH Customer
    When User clicks on create payment button
    Then Payment is successfully created
    And User copies the transaction ID from the Payment receipt screen

Transaction search by ACH Payment type
  [Tags]    Smoke    Regression
  Given User navigates to Research tab
  And User enters begin and end date
  And User enters ACH search criteria and hit Submit button
  Then Transaction results are displayed

Transaction search By CARD Payment type
  [Tags]    Smoke    Regression
  Given User navigates to Research tab
  Given User enters dates and CARD search criteria
  And User hits submit button
  Then Transaction results are displayed
       
Transaction Search by Transaction ID for last 30 Days 
   [Tags]    Smoke    Regression
   Given User navigates to Research tab
   Given User sets a date range for 30 days
   And User enters the transction ID in Search criteria and hit Submit button
   Then Searched Transaction is displayed
 
    
    
   

    


    

    