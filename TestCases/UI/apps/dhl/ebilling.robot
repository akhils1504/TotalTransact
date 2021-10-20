*** Settings ***
Documentation       Running DHL EBilling Workflow in Specified Enviornment

Library             SeleniumLibrary    timeout=10   implicit_wait=2   run_on_failure=Capture Page Screenshot    
Library             String   #In TotalTransact > Roboto Standard Libraries > String    
Library             ExtMVC
Library             FakerLibrary    locale=en_US
Resource            ${CURDIR}../../../../../variables/CommonKeywordsAndVariables.resource

Suite Setup         Run Keywords   Setup Test Suite
  ...               AND           Import Resource  ${CURDIR}../../../../../variables/CommonUIKeywordsAndVariables.resource
Test Setup          Test UI Setup
Test Teardown       Test Ui Teardown
Suite Teardown      View Log

*** Variables ***


*** Keywords ***
Login
    Initiate EBilling Workflow
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-center' and contains(text(),'Customers')]    timeout=30 seconds    error=None

Test UI Setup
    Initiate EBilling WOrkflow
    Set Suite Variable       \${authorization}  true  #${authorization}
    #Sleep  60s
    #Choose Payment Tab

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot

Test UI Teardown
    #Sleep  ${latency_time_default}
    Failure Options
    #Close Browser

View Log
    Open Browser    ${LOG_FILE}    ${browser}

Button Up The Test
    Sleep  ${latency_time_default}
    Click Ext Button  \#paybutton
    # Payment Receipt Should Be Visible

Overwrite Reqest Information
    Input Text  //input[@id='url']    ${url}/sbps/invoicePayment
    #Input Text  //input[@id='body']    kara.jensen@finastra.com
    

#Overwrite Payments Information
#Overwrite Payment Account Information

*** Test Cases ***

Create eBilling ACH Payment - Checking
    Overwrite Reqest Information
    Click RefPortal Preview Button Link
    Click RefPortal Execute Button Link
    Click Ext Button  \#addnewaccountbutton
    ${random}=      Word  #Numerify  @@@!!!
    ${created_payment_account_ach_name}=  Set Variable  Selenium ACH Created 001002${random}
    Log Variables
    #Confirm Panel Focused Is Visible  
    Sleep  ${latency_time_default}
    Select Simple Combobox Value  \#accounttype  Checking  #${account_text_checking}
    Sleep  ${latency_time_default}
    Set Textfield Value  \#nameonaccount  ${fullname_default}
    Set Textfield Value  \#routingnumber  ${routing_number}
    Set Textfield Value  \#accountnumber  ${account_number}
    Set Textfield Value  \#nickname  ${created_payment_account_ach_name}
    Click Ext Button  \#savebutton
    Sleep  ${latency_time_default}
    Ext MessageBox Button FireHandler  \#ok
    Sleep  ${latency_time_default}
    Set Checkbox Value       \#achcheckbox  ${authorization}
    Button Up The Test


Create eBilling Card Payment
    ${random}=      Word  #Numerify  @@@!!!
    Overwrite Reqest Information
    Click RefPortal Preview Button Link
    Click RefPortal Execute Button Link
    Click Ext Button  \#addnewaccountbutton
    ${random}=      Word  #Numerify  @@@!!!
    ${created_payment_account_card_name}=  Set Variable  Selenium Card Created 001002${random}
    Log Variables
    #Confirm Panel Focused Is Visible
    Sleep  ${latency_time_default}
    Select Simple Combobox Value  \#accounttype  ${account_text_credit_card}
    Sleep  ${latency_time_default}
    Set Textfield Value  \#nameoncard  ${fullname_default}
    Set Textfield Value  \#cardnumber  ${card_number}
    Select Simple Combobox Value  \#month  12   #${expiration_month}
    Select Simple Combobox Value  \#year  24    #${expiration_year}
    Set Textfield Value  \#nickname  ${created_payment_account_card_name}
    Set Textfield Value  \#street1  ${address_default}
    Set Textfield Value  \#city  ${city_default}
    #Select Simple Combobox Value  \#state  ${state_default}
    Select Combobox Value By Name  \#state  Utah  #${state_default}
    Sleep  ${latency_time_default}
    Set Textfield Value  \#postalcode  ${zip_code_default}
    Click Ext Button  \#savebutton
    Sleep  ${latency_time_default}
    Ext MessageBox Button FireHandler  \#ok
    Sleep  ${latency_time_default}
    Set Textfield Value  \#cvv  ${cvv_dhl_default}
    Button Up The Test
    #Payment Account List Should Contain  ${created_payment_account_card_name}  ${card}