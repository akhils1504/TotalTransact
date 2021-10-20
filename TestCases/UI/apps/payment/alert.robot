*** Settings ***
Documentation       Resubmitting An Alert in Specified Enviornment

Library             SeleniumLibrary    timeout=10   implicit_wait=2   run_on_failure=Capture Page Screenshot    
Library             String   #In TotalTransact > Roboto Standard Libraries > String    
Library             ExtMVC
Library             PaymentPortal
Library             FakerLibrary    locale=en_US
Resource            ${CURDIR}../../../../../variables/CommonKeywordsAndVariables.resource

Suite Setup         Run Keywords   Setup Test Suite
  ...               AND            Import Resource  ${CURDIR}../../../../../variables/CommonUIKeywordsAndVariables.resource
Test Setup          Test UI Setup    
Test Teardown       Test Ui Teardown
Suite Teardown      Teardown Test Suite

*** Variables ***


*** Keywords ***


Test UI Setup
    Login
   
    
Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Sleep  ${latency_time_default}
    Failure Options
    Close Browser
    
Login
    Login to Payment Portal Through UI
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Dashboard')]    timeout=30 seconds    error=None
    
View Log
    Open Browser    ${LOG_FILE}    ${browser}
    
    
Payment Receipt Text Should Be Visible
    Sleep  2s
    Wait Until Internationalized Page Contains   MS282    2 seconds


Payment Account Failure Text Should Be Visible
    Sleep  2s
    Wait Until Page Contains   Invalid card number   timeout=2 seconds    error=None
    
Test Dashboard Setup 
    Choose Dashboard Tab
  
Test Variables
    ${month}=       Random Expiration Month
    ${year}=        Set Variable  23
    ${random}=      Word  #Numerify  @@@!!!
    ${cardnumber}=   Set Variable  4111111111111111
    ${created_payment_account_card_name}=   Set Variable  Selenium Card Created CB ${month}${year}${random}
    Set Test Variable  \${month}  ${month}
    Set Test Variable  \${year}  ${year}
    Set Test Variable  \${random}  ${random}
    Set Test Variable  \${cardnumber}  ${cardnumber}
    Set Test Variable  \${created_payment_account_card_name}  ${created_payment_account_card_name}
    Log Variables

    
*** Test Cases ***

Update Fee and Resubmit
    Choose Dashboard Tab
    Sleep  ${latency_time_default}
    Choose First New Alert 
    Click Selected Ext Gridrow
    Sleep  ${latency_time_default}
    Click Ext Button  \#updatefeebutton
    Choose Another Fee
    Sleep  ${latency_time_default}
    Click Ext Button  \#updatebutton
    Click Ext Button  \#resubmitbutton
    Payment Receipt Text Should Be Visible

Update CC Payment Account by an Invalid Card Number - Negative Test Case
    Choose Dashboard Tab
    Sleep  ${latency_time_default}
    Choose First New Alert
    Click Selected Ext Gridrow
    Sleep  ${latency_time_default}
    Click Ext Button  \#updatepaymentaccountbutton
    Sleep  ${latency_time_default}
    Choose Another Payment Account  name
    Sleep  ${latency_time_default}
    Test Variables
    ${invalid_card_number}=  Set Variable  4234433232434333    
    Set Test Variable  \${invalid_card_number}  ${invalid_card_number} 
    Set Textfield Value  \#accountnumber   ${invalid_card_number}   #4234433232434333
    Set Textfield Value  \#expirymonth  ${month}
    Set Textfield Value  \#expiryyear  ${year}
    Set Textfield Value  \#accountname  ${created_payment_account_card_name}
    Set Textfield Value  \#billingaddress  ${address_default}
    Set Textfield Value  \#billingcity  ${city_default}
    Set Textfield Value  \#billingstate  ${state_default}
    Set Textfield Value  \#billingpostalcode  ${zip_code_default}
    Click Ext Button  \#addbutton
    Payment Account Failure Text Should Be Visible

Update CC Payment Account by a New Account and Resubmit
    Choose Dashboard Tab
    Sleep  ${latency_time_default}
    Choose First New Alert
    Click Selected Ext Gridrow
    Sleep  ${latency_time_default}
    Click Ext Button  \#updatepaymentaccountbutton
    Sleep  ${latency_time_default}
    Choose Another Payment Account  name
    Sleep  ${latency_time_default}
    Test Variables
    Set Textfield Value  \#accountnumber  ${cardnumber}
    Set Textfield Value  \#expirymonth  ${month}
    Set Textfield Value  \#expiryyear  ${year}
    Set Textfield Value  \#accountname  ${created_payment_account_card_name}
    Set Textfield Value  \#billingaddress  ${address_default}
    Set Textfield Value  \#billingcity  ${city_default}
    Set Textfield Value  \#billingstate  ${state_default}
    Set Textfield Value  \#billingpostalcode  ${zip_code_default}
    Click Ext Button  \#addbutton
    Sleep  ${latency_time_default}
    Click Ext Button  \#resubmitbutton
    Payment Receipt Text Should Be Visible
        
Select an Alert to Resubmit    
    Choose Dashboard Tab
    Sleep  ${latency_time_default}
    Choose First New Alert 
    Click Selected Ext Gridrow
    Sleep  ${latency_time_default}
    Click Ext Button  \#resubmitbutton
    Payment Receipt Text Should Be Visible
    