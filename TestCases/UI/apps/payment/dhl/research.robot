*** Settings ***
Documentation       Searching for DHL Transaction(s) in Specified Enviornment

Library             SeleniumLibrary    timeout=10   implicit_wait=2   run_on_failure=Capture Page Screenshot    
Library             String   #In TotalTransact > Roboto Standard Libraries > String    
Library             ExtMVC
Library             PaymentPortal
Library             FakerLibrary    locale=en_US
Resource            ${CURDIR}../../../../../../variables/CommonKeywordsAndVariables.resource

Suite Setup         Run Keywords   Setup Test Suite
  ...               AND           Import Resource  ${CURDIR}../../../../../../variables/CommonUIKeywordsAndVariables.resource
Test Setup          Test UI Setup    
Test Teardown       Test Ui Teardown
Suite Teardown      View Log

*** Variables ***


*** Keywords ***
Test UI Setup
    Login
    Choose Research Tab

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot

Test UI Teardown
    Failure Options
    #Close Browser
    
Login
    Login to Payment Portal Through UI as DHL User
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-center' and contains(text(),'Research')]    timeout=30 seconds    error=None

View Log
    Open Browser    ${LOG_FILE}    ${browser}

Button Up The Test
	Click Ext Button  \#submitbutton
    #Research Transactions Should Be Visible

*** Test Cases ***

# Transaction Search by Amount for last 30 Days
#     #Confirm Panel Focused Is Visible  ${payment_information_panel}
#     ${begin_date}=      Set Days Behind         30
#     ${end_date}=        Set Days Ahead          0
#     ${amount}=          Get Value From User	    Enter Amount    5.00

#     Set Test Variable   \${amount}  ${amount}
#     Set Test Variable   \${begin_date}  ${begin_date}
#     Set Test Variable   \${end_date}  ${end_date}
#     Log Variables

#     #Set Suite Variable  \${payment_method}  ${ach}
#     Set Datefield Value  \#begindate  ${begin_date}
#     Set Datefield Value  \#enddate    ${end_date}
#     Set Textfield Value  \#searchcriteria  ${amount}            #    #${payment_mount_default}
#     Button Up The Test

Transaction Search by Waybill Number for last User Defined Date Range
    #Confirm Panel Focused Is Visible  ${payment_information_panel}
    ${default_begin_date}=      Set Days Behind         30
    ${default_end_date}=        Set Days Ahead          0
    ${begin_date}=          Get Value From User	    Enter Start Date in format 'm/d/y'  ${default_begin_date}
    ${end_date}=            Get Value From User	    Enter End Date in format 'm/d/y'    ${default_end_date}
    ${airwaybill_number}=   Get Value From User	    Enter AirWaybill Number     151231234

    Set Test Variable   \${airwaybill_number}  ${airwaybill_number}
    Set Test Variable   \${begin_date}  ${begin_date}
    Set Test Variable   \${end_date}  ${end_date}
    Log Variables
    Sleep  ${latency_time_default}

    Set Datefield Value  \#begindate  ${begin_date}
    Set Datefield Value  \#enddate    ${end_date}
    Set Textfield Value  \#searchcriteria  ${airwaybill_number}            #    #${payment_mount_default}
    Sleep  ${latency_time_default}
    Sleep  ${latency_time_default}
    Button Up The Test