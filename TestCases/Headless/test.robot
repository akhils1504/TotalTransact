# coding: utf-8
*** Settings ***
Documentation     Exercises the system as much as possible to give clues to Burp Suite for testing.  BURP MUST BE SET TO LISTEN ON LOCALHOST:8080
Library           Collections
Library           Dialogs
Library           robot.libraries.DateTime
Library           RequestsLibrary
Library           JsonpathLibrary
Library           OperatingSystem
Library           String
Library           XML
Resource          ../../variables/CommonKeywordsAndVariables.resource
Suite Setup       Setup Test Suite

*** Keywords ***
Read Payment Status Submitted
    [Tags]  minVersion_2.7
    ${data}  Create Dictionary   csrfToken  ${session_id}
    ${today}    Get Current Date    result_format=%m/%d/%Y
    Set To Dictionary  ${data}  transactiondate  ${today} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urcontent_lengthcoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/home/xPaymentStatusSubmittedRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    

    ${content}=    Set Variable    ${resp.json()}
    ${content_length}=    Get Length    ${resp.json()}
    # Set Global Variable    ${content_length}    
    # Log To Console    ${content_length}
    Run Keyword If    ${content_length}>0    Should Be Equal    ${resp.json()['success']}    True    
     #...                ELSE    Should Be True    ${content_length}==0    


# Not an empty value
  # ${success}=  Get Items By Path  ${content}  $..success
    # Should Be Equal   ${success}  true
    


*** Test Cases ***
Authenticate to the Server
    [Tags]    Smoke
    Login To Payment Portal  ${username}  ${password}
    
Post Merchant Detail (Cannot be called later because it sets the merchant too. This requires fixing.)
	[Tags]    Smoke
	&{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/header/xGetMerchantDetail  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    Log  ${url}
    
Read Payment Status Submitted Wait Until Succeeds
    Wait Until Keyword Succeeds    1 min    20 sec    Read Payment Status Submitted
    Run Keyword If    ${content_length}==0    Should Be True    ${content_length}==0     
    

