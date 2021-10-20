*** Settings ***
Documentation       Running DHL Webship Workflow in Specified Enviornment

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
    Initiate WebShip Workflow
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-center' and contains(text(),'Customers')]    timeout=30 seconds    error=None

Test UI Setup
    Initiate WebShip WOrkflow

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot

Test UI Teardown
    Failure Options
    #Close Browser

View Log
    Open Browser    ${LOG_FILE}    ${browser}

Button Up The Test
    Click Ext Button  \#submitbutton
    # Payment Receipt Should Be Visible

Overwrite Url Information
    Input Text  //input[@id='url']    ${url}/sbps/dhl/index

#Overwrite Payments Information

*** Test Cases ***

Create Webship Card Payment
    Overwrite Url Information
    Click RefPortal Preview Button Link
    Click RefPortal Execute Button Link
    #Overwrite Payments Information
    Sleep  12s

    Set Textfield Value  \#nameoncard  Jane Doe     #${fullname_default}
    Set Textfield Value  \#cardnumber  4111111111111111    #${card_number}
    Set Textfield Value  \#cvv  ${cvv_dhl_default}
    Select Simple Combobox Value  \#month  12   #${expiration_month}
    Select Simple Combobox Value  \#year  24    #${expiration_year}
    Button Up The Test
    #Payment Account List Should Contain  ${created_payment_account_card_name}  ${card}