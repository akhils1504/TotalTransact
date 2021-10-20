*** Settings ***
Documentation       Running DHL Print and Post Workflow in Specified Enviornment

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
    Initiate Print and Post Workflow
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-center' and contains(text(),'Customers')]    timeout=30 seconds    error=None

Test UI Setup
    Initiate Print and Post WOrkflow
    Set Suite Variable       \${authorization}  true  #${authorization}
    #Sleep  60s
    #Choose Payment Tab

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot

Test UI Teardown
    Failure Options
    #Close Browser

View Log
    Open Browser    ${LOG_FILE}    ${browser}

Button Up The Test
    Sleep  ${latency_time_default}
    Click Ext Button  \#paybutton
    # Payment Receipt Should Be Visible

Overwrite Request Information
    Input Text  //input[@id='url']    ${url}/sbps/invoicePayment
    

#Overwrite Payments Information
#Overwrite Payment Account Information

*** Test Cases ***

Create Print and Post ACH Payment - Checking
    Overwrite Request Information
    Click RefPortal Preview Button Link
    Click RefPortal Execute Button Link
    ${random}=      Word  #Numerify  @@@!!!
    Log Variables
    #Confirm Panel Focused Is Visible  
    Sleep  ${latency_time_default}
    Select Simple Combobox Value  \#accounttype  Checking  #${account_text_checking}
    Sleep  ${latency_time_default}
    Set Textfield Value  \#nameonaccount  ${fullname_default}
    Set Textfield Value  \#routingnumber  ${routing_number}
    Set Textfield Value  \#accountnumber  ${account_number}
    Set Checkbox Value       \#achcheckbox  ${authorization}
    Click Ext Button  \#submitbutton
    Sleep  ${latency_time_default}
    Ext MessageBox Button FireHandler  \#ok


Create Print and Post Card Payment
    ${random}=      Word  #Numerify  @@@!!!
    Overwrite Request Information
    Click RefPortal Preview Button Link
    Click RefPortal Execute Button Link
    ${random}=      Word  #Numerify  @@@!!!
    Log Variables
    #Confirm Panel Focused Is Visible
    Sleep  ${latency_time_default}
    Select Simple Combobox Value  \#accounttype  ${account_text_credit_card}
    Sleep  ${latency_time_default}
    Set Textfield Value  \#nameoncard  ${fullname_default}
    Set Textfield Value  \#cardnumber  ${card_number}
    Set Textfield Value  \#cvv  ${cvv_dhl_default}
    Select Simple Combobox Value  \#month  12   #${expiration_month}
    Select Simple Combobox Value  \#year  24    #${expiration_year}
    Set Textfield Value  \#street1  ${address_default}
    Set Textfield Value  \#city  ${city_default}
    #Select Simple Combobox Value  \#state  ${state_default}
    Select Combobox Value By Name  \#state  Utah  #${state_default}
    Sleep  ${latency_time_default}
    Set Textfield Value  \#postalcode  ${zip_code_default}
    Click Ext Button  \#submitbutton
    Sleep  ${latency_time_default}
    Ext MessageBox Button FireHandler  \#ok
