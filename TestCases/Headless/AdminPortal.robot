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
Login to Admin
    &{data}=  Create Dictionary  username=${admin_username}  password=${admin_password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbpsAdmin
    ${resp}=  POST Request  adminSession  /sbpsAdmin/login/authenticate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]}  
    Should Contain  ${resp.text}  <title>Small Business Payment Suite</title>
    Should Not Contain  ${resp.text}  <title>Login</title>
    Should Not Contain  ${resp.text}  You entered an invalid username or password 

Login to Admin As Merchant Admin
    &{data}=  Create Dictionary  username=${username}  password=${password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbpsAdmin
    ${resp}=  POST Request  adminSession  /sbpsAdmin/login/authenticate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches   ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]}  
    Should Contain  ${resp.text}  <title>Small Business Payment Suite</title>
    Should Not Contain  ${resp.text}  <title>Login</title>
    Should Not Contain  ${resp.text}  You entered an invalid username or password 

Logout of Admin
    ${resp}=  Get Request  adminSession  /sbpsAdmin/logoff
    Should Contain  ${resp.content.decode('utf-8')}  Password
    
Login to Admin in CI Environment
    &{data}=  Create Dictionary  username=${admin_username}  password=${admin_password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  POST Request  adminSession  /sbpsAdmin/login/authenticate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]}  
    Should Contain  ${resp.text}  <title>Small Business Payment Suite</title>
    Should Not Contain  ${resp.text}  <title>Login</title>
    Should Not Contain  ${resp.text}  You entered an invalid username or password 

Login to Admin As Merchant Admin in CI Environment
    
    &{data}=  Create Dictionary  j_username=${username}  j_password=${password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  POST Request  adminSession  /sbpsAdmin/j_spring_security_check  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches   ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]}  
    Should Contain  ${resp.text}  <title>Small Business Payment Suite</title>
    Should Not Contain  ${resp.text}  <title>Login</title>
    Should Not Contain  ${resp.text}  You entered an invalid username or password 

Logout of Admin in CI Environment
    ${resp}=  Get Request  adminSession  /sbpsAdmin/j_spring_security_logout
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  Password

*** Test Cases ***

Authenticate to the Admin Server  
    [Tags]    Smoke  
       
    Set Log Level  debug
    # Run Keyword If  '${testServer}'=='AzureCustint'  Login to Admin in CI Environment 
     # ...                ELSE  Login to Admin
    Login to Admin
    
GetSessionIdleTimeOut 
    [Tags]    Smoke  
      
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/xGetSessionIdleTimeOut  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=    Run Keyword And Return Status    Should Contain    ${resp.text}    "timeout"
    Should Be Equal   '${success}'  'True'
    
Application Header Admin
     
    
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/header/xGenerateHeaderJsonData  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${companyName}=  Get Items By Path  ${resp.content}  $..companyname
    Should Be Equal   ${companyName}   ${admin_compName}
    
    
Read App Name Admin
     
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/navNavigationItem/xGenerate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${applicationName}=  Get Items By Path  ${resp.content}  $..appName
    Should Be Equal  ${applicationName}  ${admin_appName}
    
Read Naics
    
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xGetComNaics  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Read Processing Account Status
    
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xProcessingAccountStatus  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Read Merchant Status
   
    

    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xMerchantStatus  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Read StatesProvinces
    
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadStatesProvinces  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Retrieve Reseller List and Select Reseller
     [Tags]    Smoke 
     
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/reseller/xList  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${reseller_id}  Get Items By Path  ${resp.content}  $..resellers[?(@.resellername=='${reseller_search_string}')].id
    Log  ${reseller_id}
    Set Suite Variable  \${reseller_id}  ${reseller_id}
    
Read Countries
   
    
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530    
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbpsAdmin/configuration/xReadCountries  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${country_id}  Get Items By Path  ${resp.content}  $..countries[?(@.name=='${country_search_string}')].id
    Log  ${country_id}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    
Read Card Processors
    [Tags]    Smoke 
    
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadCardProcessors  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${card_processor_id}  Get Items By Path  ${resp.content}  $..cardProcessors[?(@.name=='${card_processor_search_string}')].id
    Log  ${card_processor_id}
    Set Suite Variable  \${card_processor_id}  ${card_processor_id}
    
Read TimeZones
   [Tags]    Smoke 
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadTimeZones  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${timezone_id}  Get Items By Path  ${resp.content}  $..timeZones[?(@.name=='${time_zone_search_string}')].id
    Log  ${timezone_id}
    Set Suite Variable  \${timezone_id}  ${timezone_id}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true

Search Merchant when clicking on Merchants tab
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  resellerid  0
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    # misspelling of success as succes is in response from server and intentional
    ${success}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${success}   false

Search Merchant
    [Tags]    Smoke  
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${succes}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${succes}   true    
    ${merchant_id}  Get Items By Path  ${resp.content}  $..merchant[?(@.merchantname=='${merchant_search_string}')].merchantid
    Log  ${merchant_id}
    Set Suite Variable  \${merchant_id}  ${merchant_id}  
    
Search Merchant by entering search term
    [Tags]    Smoke 
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}    searchValue  ${merchant_search_string}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${succes}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${succes}   true    
    # ${merchant_id}  Get Items By Path  ${resp.content}  $..merchant[?(@.merchantname=='${merchant_search_string}')].merchantid
    # Log  ${merchant_id}
    # Set Suite Variable  \${merchant_id}  ${merchant_id} 
    
    
Search Merchant when clicking on page arrow
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page    4
    Set To Dictionary  ${data}  start   75
    Set To Dictionary  ${data}  limit   25
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${succes}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${succes}   true    
 
View MerchantDetail
    [Tags]    Smoke 
    
    Log  ${merchant_id}
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25    
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xViewMerchantDetail  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${external_id}  Get Items By Path  ${resp.content}  $..merchantdetail.externalid
    Log  ${external_id}
    Set Suite Variable  \${external_id}  ${external_id}
    
Update MerchantDetail
    [Tags]    Smoke 
     
    Log  ${merchant_id}
    Log  ${external_id}
    Log  ${timezone_id}
    Log  ${reseller_id}
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    ${value}    Set Variable    [{"resellerid":"${reseller_id}","merchantid":"${merchant_id}","externalid":"${external_id}","merchantname":"Topaz Soda","address":"street name and number","addresstwo":"apt/floor","city":"Salt Lake City","state":"UT","zipcode":"84107","country":"US","phone":"111-222-3331","fax":"111-222-3331","contactfirstname":"Topaz Soda","contactlastname":"Topaz Soda","contactphone":"111-222-3333","contactemail":"Topaz.Soda@fundtech.com","merchantwebsite":"totaltseeddata.com","billingroutingnumber":"011000015","billingaccountnumber":"12348","logoutreturnpath":"www.google.in","merchantstatus":"Active","merchantreferencenumber":"","merchantTimeZone":"${timezone_id}"}]
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  merchantdata                   ${value}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xUpdateMerchantDetail  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Search Processing Account
 
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${account_location_id}  Get Items By Path  ${resp.content}  $..accountlocations[?(@.accountlocationname=='${processing_account_search_string}')].merchantid
    Log  ${account_location_id}
    Set Suite Variable  \${account_location_id}  ${account_location_id}
    ${success}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${success}   true
    
Search Processing Account by entering search term
    
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  searchValue  ${processing_account_search_string}
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${success}   true    

Get Extra Settings
  
       
    [Documentation]    Retrieves the specific extra settings are needed for a particular card processing institution.  
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    #processorName parameter is really institution name
    Set To Dictionary  ${data}  processorName  HEARTLAND
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xGetExtraSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    Should Contain   ${resp.text}  extraSettings

Read Card Institutions
    [Tags]    Smoke 
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Log  ${card_processor_id}
    Set To Dictionary  ${data}  processorId  ${card_processor_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadCardInstitutions  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${institution_id}  Get Items By Path  ${resp.content}  $..cardInstitutions[?(@.displayname=='${card_institution_search_string}')].id
    Log  ${institution_id}
    Set Suite Variable  \${institution_id}  ${institution_id}
    Should Be Equal   ${success}   true
    
Read ACH Endpoints
    [Tags]    Smoke 
    
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530 
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadAchEndpoints  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${endpoint_id}  Get Items By Path  ${resp.content}  $..data[?(@.name=='${endpoint_search_string}')].id
    Log  ${endpoint_id}
    Set Suite Variable  \${endpoint_id}  ${endpoint_id}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true   

Create Merchant with RDC Account 
    Log  ${reseller_id} 
    Log  ${card_processor_id}
    Log  ${timezone_id}
    Log  ${country_id}
    
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    ${merchant_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    Log   ${merchant_name_uniqueifier}
    ${merchant_random_id}=  Generate Random String  length=6  chars=[NUMBERS]
    Log   ${merchant_random_id}
    Set To Dictionary  ${data}   merchantdata                   [{"resellerid":"${reseller_id}","merchantname":"${merchant_name_uniqueifier}","address":"253 East Lincoln Ave","addresstwo":"","city":"Plain City","state":"AL","zipcode":"10415-9480","country":"US","phone":"555-581-5392","fax":"555-622-9490","merchantTimeZone":"${timezone_id}","contactfirstname":"firstname${merchant_name_uniqueifier}","contactlastname":"lastname${merchant_name_uniqueifier}","contactphone":"555-396-3280","contactemail":"breanna@example.com","merchantwebsite":"http://www.moorecomputer.info/","billingroutingnumber":"021200025","billingaccountnumber":"6011111111111117","logoutreturnpath":"www.moorecomputer.net","merchantreferencenumber":"","externalid":"${merchant_random_id}","merchantid":""}]
    Set To Dictionary  ${data}   ccdata                         [{"cardpresentprofilename":"InvolvitAdmittenda","cardprocessor":"${card_processor_id}","cardinstitution":"","cybersourcemerchantid":"","extrasettings":"","cardbatchcutofftime":"0","cardbatchcutoffminute":"0","acceptvisa":"on","acceptmastercard":"on","acceptamex":"on","acceptdiscover":"on","acceptamericanexpress":"on"}]
    Set To Dictionary  ${data}   achdata                        [{}]
    Set To Dictionary  ${data}   rdcdata                        [{"rdcdepositrouting":"102301092","rdcdepositaccountnumber":"2222630000001125"}]
    Set To Dictionary  ${data}   processorfieldvalues           [{}]
    Set To Dictionary  ${data}   accountlocations                [{"merchantid":"","merchantname":"","accountlocationname":"incumbit","address":"419 East Roosevelt Sq, Building 23","city":"Sigurd","state":"AL","zipcode":"37607","country":"US","phone":"555-425-8683","fax":"555-356-5623","contactfirstname":"Michael","contactlastname":"Rowland","contactphone":"555-873-8642","contactemail":"caroline@example.com","merchantwebsite":"www.demortuisautbene.com","naics":111110,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"","acceptCreditcard":"","acceptRdc":"on","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"123456","accountLocationTimeZone":"${timezone_id}","gatewayTimeZone":"","extrasettings":"","id":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xCreate  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
 
Create Merchant and Processing Account with CC Account 
  
    
    Log  ${reseller_id} 
    Log  ${card_processor_id}
    Log  ${timezone_id}
    Log  ${country_id}
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    ${merchant_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    Set Suite Variable  \${merchant_name_uniqueifier}  ${merchant_name_uniqueifier}
    Log   ${merchant_name_uniqueifier}   
    Set To Dictionary  ${data}   merchantdata                   [{"resellerid":"${reseller_id}","merchantname":"${merchant_name_uniqueifier}","address":"253 East Lincoln Ave","addresstwo":"","city":"Plain City","state":"AL","zipcode":"10415-9480","country":"US","phone":"555-581-5392","fax":"555-622-9490","merchantTimeZone":"${timezone_id}","contactfirstname":"firstname${merchant_name_uniqueifier}","contactlastname":"lastname${merchant_name_uniqueifier}","contactphone":"555-396-3280","contactemail":"breanna@example.com","merchantwebsite":"http://www.moorecomputer.info/","billingroutingnumber":"021200025","billingaccountnumber":"6011111111111117","logoutreturnpath":"www.moorecomputer.net","merchantreferencenumber":"","externalid":"76897","merchantid":""}]
    Set To Dictionary  ${data}   ccdata                         [{"cardpresentprofilename":"${merchant_name_uniqueifier}profile","cardprocessor":"${card_processor_id}","cardinstitution":"${institution_id}","cybersourcemerchantid":"","extrasettings":"","cardbatchcutofftime":"0","cardbatchcutoffminute":"0","acceptvisa":"on","acceptmastercard":"on","acceptamex":"on","acceptdiscover":"on","acceptamericanexpress":"on"}]
    Set To Dictionary  ${data}   achdata                        [{}]
    Set To Dictionary  ${data}   rdcdata                        [{}]
    Set To Dictionary  ${data}   processorfieldvalues           [{}]
    Set To Dictionary  ${data}   accountlocations                [{"merchantid":"","merchantname":"","accountlocationname":"incumbit","address":"419 East Roosevelt Sq, Building 23","city":"Sigurd","state":"AL","zipcode":"37607","country":"US","phone":"555-425-8683","fax":"555-356-5623","contactfirstname":"Michael","contactlastname":"Rowland","contactphone":"555-873-8642","contactemail":"caroline@example.com","merchantwebsite":"www.demortuisautbene.com","naics":111110,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"","acceptCreditcard":"on","acceptRdc":"","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"123456","accountLocationTimeZone":"${timezone_id}","gatewayTimeZone":"","extrasettings":"","id":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${cc_merchant_id}=  Get Items By Path  ${resp.content}  $..merchantid
    Set Suite Variable  \${cc_merchant_id}  ${cc_merchant_id}
    
Read Gateway Profiles
    
    
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  merchantid   ${cc_merchant_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xReadGatewayProfiles  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true    
    ${gateway_profiles_id}  Get Items By Path  ${resp.content}  $..gatewayprofiles[?(@.cardpresentprofilename=='${merchant_name_uniqueifier}profile')].id
    Log  ${gateway_profiles_id}
    Set Suite Variable  \${gateway_profiles_id}  ${gateway_profiles_id}

Create Merchant with ACH Account 
    [Tags]    Smoke 
    
    Log  ${reseller_id} 
    Log  ${card_processor_id}
    Log  ${timezone_id}
    Log  ${country_id}
    Log  ${endpoint_id}
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    ${merchant_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    Log   ${merchant_name_uniqueifier}
    ${merchant_random_id}=  Generate Random String  length=6  chars=[NUMBERS]
    Log   ${merchant_random_id}
    Set To Dictionary  ${data}   merchantdata                   [{"resellerid":"${reseller_id}","merchantname":"${merchant_name_uniqueifier}","address":"253 East Lincoln Ave","addresstwo":"","city":"Plain City","state":"AL","zipcode":"10415-9480","country":"US","phone":"555-581-5392","fax":"555-622-9490","merchantTimeZone":"${timezone_id}","contactfirstname":"firstname${merchant_name_uniqueifier}","contactlastname":"lastname${merchant_name_uniqueifier}","contactphone":"555-396-3280","contactemail":"breanna@example.com","merchantwebsite":"http://www.moorecomputer.info/","billingroutingnumber":"021200025","billingaccountnumber":"6011111111111117","logoutreturnpath":"www.moorecomputer.net","merchantreferencenumber":"","externalid":"${merchant_random_id}","merchantid":""}]
    Set To Dictionary  ${data}   ccdata                         [{}]
    Set To Dictionary  ${data}   achdata                        [{"endpoint":"${endpoint_id}","achdepositrouting":"121042882","achdepositaccountnumber":"491282246310005","nameonachdeposit":"Timothy Huffman","nametoapperincustomer":"Timothy","companyid":"4546434325","achdisbursementwindow":"0","reserverate":"0","reservemax":"99999","maxtransactionlimit":"999999.99","achduplicatecheckingwindow":"0","maxdailynumberofpayments":"99999999","maxmonthlynumberofpayments":"99999999","maxmonthlytransactionlimit":"999999.99","maxdailytransactionlimit":"999999.99","nsfautomatedresubmits":"0"}]
    Set To Dictionary  ${data}   rdcdata                        [{}]
    Set To Dictionary  ${data}   processorfieldvalues           [{}]
    Set To Dictionary  ${data}   accountlocations               [{"merchantid":"","merchantname":"","accountlocationname":"Virginia","address":"716 Penn Drive","city":"Bristow","state":"VA","zipcode":"20136","country":"US","phone":"6143085405","fax":"6143085405","contactfirstname":"Timothy","contactlastname":"Huffman","contactphone":"6143085405","contactemail":"timothy.huffman@yahoo.co.in","merchantwebsite":"www.merchantutf.com","naics":424910,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"on","acceptCreditcard":"","acceptRdc":"","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"","accountLocationTimeZone":"${timezone_id}","gatewayTimeZone":"","extrasettings":"","id":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xCreate  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
  
Create Account Location with CC Account
    [Tags]    Smoke  
    
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    ${acount_location_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    Set Suite Variable  \${acount_location_name_uniqueifier}  ${acount_location_name_uniqueifier}
    Log   ${acount_location_name_uniqueifier}
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  ccdata  [{"gatewayprofiles":-1,"cardpresentprofilename":"${acount_location_name_uniqueifier}","cardprocessor":"${card_processor_id}","gatewayTimeZone":"${timezone_id}","cardinstitution":"LOOPBACK","cybersourcemerchantid":"","extrasettings":"","cardbatchcutofftime":"0","cardbatchcutoffminute":"0","acceptvisa":"on"}]
    Set To Dictionary  ${data}  achdata  [{}]
    Set To Dictionary  ${data}  rdcdata  [{}]
    Set To Dictionary  ${data}  processorfieldvalues  [{}]
    Set To Dictionary  ${data}  accountlocations  [{"merchantid":"${merchant_id}","merchantname":"","accountlocationname":"${acount_location_name_uniqueifier}","address":"340 West Nixon Square","city":"Santaquin","state":"AL","zipcode":"73121-2128","country":"US","phone":"555-981-8075","fax":"555-285-2103","contactfirstname":"${acount_location_name_uniqueifier}","contactlastname":"${acount_location_name_uniqueifier}","contactphone":"555-712-7662","contactemail":"ppatel@example.com","merchantwebsite":"http://www.cuiusvishominisesterrare.net/","naics":111110,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"","acceptCreditcard":"on","acceptRdc":"","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"41111","accountLocationTimeZone":"P2EqpaxBJf3aIKcOBazAh!!!XTSthTC0YsdMGnws56rInC74x9Wd99gOXgl60v6msRIQmqNekCDb!!!VedtGODhlCzDwxaSC6Fe!!!SzsDqNI142YEspgdMaF6AqHdU8mteHxUKYV7DJJj3hRppcFfRolpjuJ3OezVKhgB","gatewayTimeZone":"","extrasettings":"","id":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${processing_account_location_id}  Get Items By Path  ${resp.content}  $..processingaccount.id
    Log  ${processing_account_location_id}
    Set Suite Variable  \${processing_account_location_id}  ${processing_account_location_id}

Enable ACH to Account Location
    [Tags]    Smoke  
    
    

   &{data}=  Create Dictionary  csrfToken  ${session_id}
   Set To Dictionary  ${data}  merchantid  ${merchant_id}
   Set To Dictionary  ${data}  usertz  +0530
   Set To Dictionary  ${data}  ccdata                  [{"gatewayprofiles":"${gateway_profiles_id}","cardpresentprofilename":"${acount_location_name_uniqueifier}","cardprocessor":"${card_processor_id}","gatewayTimeZone":"${timezone_id}","cardinstitution":"LOOPBACK","cybersourcemerchantid":"","extrasettings":"","cardbatchcutofftime":"0","cardbatchcutoffminute":"0","acceptvisa":"on","acceptmastercard":"on","acceptamex":"on","acceptdiscover":"on","acceptamericanexpress":"on"}]
   Set To Dictionary  ${data}  achdata                 [{"endpoint":"${endpoint_id}","achdepositrouting":"123006800","achdepositaccountnumber":"123456","nameonachdeposit":"Jennifer Thomas","nametoapperincustomer":"Jennifer","companyid":"0987654321","achdisbursementwindow":"0","reserverate":"0","reservemax":"99999","maxtransactionlimit":"999999.99","achduplicatecheckingwindow":"0","maxdailynumberofpayments":"99999999","maxmonthlynumberofpayments":"99999999","maxmonthlytransactionlimit":"999999.99","maxdailytransactionlimit":"999999.99","nsfautomatedresubmits":"0"}]
   Set To Dictionary  ${data}  rdcdata                 [{}]
   Set To Dictionary  ${data}  processorfieldvalues    [{}]
   Set To Dictionary  ${data}  accountlocations        [{"merchantid":"${merchant_id}","merchantname":"","accountlocationname":"${acount_location_name_uniqueifier}","address":"Suncreek Road","city":"Allen","state":"TX","zipcode":"12345","country":"US","phone":"8765439876","fax":"5552852103","contactfirstname":"Jennifer","contactlastname":"Thomas","contactphone":"5557127662","contactemail":"ppatel@example.com","merchantwebsite":"http://www.cuiusvishominisesterrare.net/","naics":111110,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"on","acceptCreditcard":"on","acceptRdc":"","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"","accountLocationTimeZone":"${timezone_id}","gatewayTimeZone":"","extrasettings":"","id":"${processing_account_location_id}"}]
   &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
   ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xUpdate  data=${data}  headers=${headers}
   Pretty Print  ${resp.content}
   ${success}=  Get Items By Path  ${resp.content}  $..success
   Should Not Be Empty   ${success}
   Should Be Equal   ${success}   true

Summary Report Download
    [Tags]    Smoke 
    
    ${olddate}    Subtract Time From Date    ${today}    2d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y 
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate    ${olddate}
    Set To Dictionary  ${data}  todate    ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  checkDataExist  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/adminReport/txnSummaryReportDownload  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${totalCount}=     Run Keyword If   '${success}' == 'true'   Get Items By Path  ${resp.content}  $..totalCount
    Run Keyword If    ${totalCount}!=None  Should Be Equal    ${success}  true   
    Run Keyword If    ${totalCount}==None  Should Be Equal    ${success}  false  
    
Research Transactions
    [Tags]    Smoke 
    
    ${olddate}    Subtract Time From Date    ${today}    1d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y 
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate    ${olddate} 
    Set To Dictionary  ${data}  todate    ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  searchvalue  credit
    Set To Dictionary  ${data}  admin  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/research/xAdminTransactionSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Not Be Empty   ${success}

Research Transactions Check for SQL Injection 1


    [Documentation]    Sends a searchvalue that must be rejected for single quotes and parenthesis.  Verifies success value is false.
    ${olddate}    Subtract Time From Date    ${today}    90d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y 
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate    ${olddate} 
    Set To Dictionary  ${data}  todate    ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  searchvalue  monte'||substr('foo',0,0)||'
    Set To Dictionary  ${data}  admin  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/research/xAdminTransactionSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}  false
    Should Contain  ${resp.text}  The system experienced an error while attempting to process your request

Research Transactions Check for SQL Injection 2
    
    [Documentation]    Sends a searchvalue that must be rejected (contains '--').  Verifies success value is false.
    ${olddate}    Subtract Time From Date    ${today}    90d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y 
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate    ${olddate} 
    Set To Dictionary  ${data}  todate    ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  searchvalue  --ach
    Set To Dictionary  ${data}  admin  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/research/xAdminTransactionSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Not Be Empty   ${success}
    Should Be Equal   ${success}  false
    Should Contain  ${resp.text}  The system experienced an error while attempting to process your request

Roles List
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xRoleList  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}     
    ${success}=  Get Items By Path  ${resp.content}  $..success    
    Should Be Equal   ${success}   true

User Details Role List
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xUserAvailableRoles  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}     
    ${success}=  Get Items By Path  ${resp.content}  $..success    
    Should Be Equal   ${success}   true


Create User
    [Tags]    Smoke 
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    ${first_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${last_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${reset_username}=  Generate Random String  length=20  chars=[LETTERS]
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    Set To Dictionary  ${data}  firstname  ${first_name}
    Set To Dictionary  ${data}  lastname  ${last_name}
    Set To Dictionary  ${data}  username  ${reset_username}
    Set To Dictionary  ${data}  role  T3ResellerAdmin
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xCreateUser  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${reset_username}=  Get Items By Path  ${resp.content}  $..user.username 
    ${reset_password}  Get Items By Path  ${resp.content}  $..user.password
    Log  ${reset_username}
    Log  ${reset_password}
    Should Be Equal   ${success}   true
    Set Suite Variable   \${reset_username}   ${reset_username}

Reset Password
    [Tags]    Smoke 

    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set Suite Variable  \${requsername}  ${reset_username}
    Set To Dictionary  ${data}  username  ${reset_username}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xResetPassword  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${reset_username}=  Get Items By Path  ${resp.content}  $..user.username 
    ${reset_password}  Get Items By Path  ${resp.content}  $..user.password
    Log  ${reset_username}
    Log  ${reset_password}
    Should Be Equal   ${success}   true
    Should Be Equal   ${requsername}   ${reset_username}
    
User List   
    [Tags]    Smoke 

    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xListUsers  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}     
    ${success}=  Get Items By Path  ${resp.content}  $..success 
    Should Be Equal   ${success}   true

    ${org_id}=  Get Items By Path  ${resp.content}  $..users[?(@.username=='${user_search_string}')].orgid
    Log  ${org_id}
    Set Suite Variable  \${org_id}  ${org_id}

Test 38 Search user by entering search term
    [Tags]    Smoke  
     
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  searchString  ${user_search_string}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  resellerid  ${reseller_id}
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    #Set To Dictionary  ${data}  searchValue   ${user_search_string}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xListUsers  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${totalusers}=  Get Items By Path  ${resp.content}  $..total
    Should Be Equal   ${totalusers}   1

Set LS User Status
    
    #set status to 1
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  username  ${user_search_string}
    Set To Dictionary  ${data}  status  1
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xUpdateLsUserStatus  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${newStatus}=  Get Items By Path  ${resp.content}  $..newStatus
    Should Be Equal  ${newStatus}  1
    #set back to 2
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  username  ${user_search_string}
    Set To Dictionary  ${data}  status  2
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xUpdateLsUserStatus  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${newStatus}=  Get Items By Path  ${resp.content}  $..newStatus
    Should Be Equal  ${newStatus}  2

Update LS User Roles
    
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  username  ${user_search_string}
    Set To Dictionary  ${data}  orgid  ${org_id}
    Set To Dictionary  ${data}  roles  Remote User,T3Merchant Admin,Remote Reviewer
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xUpdateLsUserRoles  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    ${newStatus}=  Get Items By Path  ${resp.content}  $..username
    Should Be Equal  ${newStatus}  ${user_search_string}
   
    
Negative Test - Verify change of admin password is disallowed
    
    Logout of Admin
    Login to Admin As Merchant Admin
    #set status to 1
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  username  ${admin_username}
    Set To Dictionary  ${data}  status  1
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/user/xUpdateLsUserStatus  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   false
    Should Contain  ${resp.text}  The attempt to change user status failed.
    Logout of Admin

    



    
