# coding: utf-8
*** Settings ***
Documentation     Exercizes the system as much as possible to give clues to Burp Suite for testing.  BURP MUST BE SET TO LISTEN ON LOCALHOST:8080
Library           Collections
Library           robot.libraries.DateTime
Library           RequestsLibrary
Library           JsonpathLibrary
Library           OperatingSystem
Library           String
Library           XML
          
*** Keywords ***
Setup Test Suite
    ${today}=  Get Current Date  result_format=%m/%d/%Y
    Set Suite Variable  \${today}  ${today}

Pretty Print 
    [Arguments]  ${output}
    ${output}=    To Json    ${output}    pretty_print=True
    Log    ${output}

Login
    &{data}=  Create Dictionary  j_username=${username}  j_password=${password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  POST Request  adminSession  /sbps/j_spring_security_check  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches  ${resp.content}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #verify the cache prevention headers are present
    Dictionary Should Contain Item  ${resp.headers}  Cache-Control  no-cache, no-store, max-age=0, must-revalidate
    Dictionary Should Contain Item  ${resp.headers}  Pragma  no-cache
    
Login to Admin
    &{data}=  Create Dictionary  j_username=${username}  j_password=${password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  POST Request  adminSession  /sbpsAdmin/j_spring_security_check  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches  ${resp.content}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]}      

Logout
    ${resp}=  Get Request  adminSession  /sbps/j_spring_security_logout
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  Password

Read Account Location
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/accountLocation/xRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${processing_account_id}  Get Items By Path  ${resp.content}  $..accountlocations[?(@.accountlocationname=='${processing_account_search_string}')].id
    Log  ${processing_account_id}
    Set Suite Variable  \${processing_account_id}  ${processing_account_id}

Read API Key
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/settings/xReadApiKey  data=${data}  headers=${headers}     
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Pretty Print  ${resp.content}
    Should Be Equal  ${success}  true
    ${api_key}=  Get items By Path  ${resp.content}  $..apikey
    Log  ${api_key}
    Set Suite Variable  \${api_key}  ${api_key}

Find Webship Payment
    [Arguments]  ${airwayBillNumber}
    &{headers}=  Create Dictionary  Content-Type=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary   ${headers}  Accept=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary  ${headers}  X-TT-APIKEY  ${api_key}
    ${queryStringParams}=  Set Variable  ?filter=airwaybillnumbers:${airwayBillNumber},creditCardPaymentStatus:P2EqpaxBJf3aIKcOBazAh!!!XTSthTC0YsH90MJdXBftpkOZrl@@@iDqCVrIPI6C2llT
    Log To Console  Attempting to find webship payment with params ${queryStringParams}
    ${resp}=  Get Request  dhlSession  /sbps/api/creditcardpayments${queryStringParams}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  CustomDataFields
    ${credit_card_payment_id}=  Get Regexp Matches  ${resp.content}  CreditCardPayment id="(.*)" href  1
    ${data}=  Set Variable  <CreditCardPayment xmlns="http://www.fundtech.com/t3applicationmedia-v1"><Amount>101.01</Amount><CreditCardPaymentStatus id="YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ"/></CreditCardPayment>
    ${resp}=  Put Request  dhlSession  /sbps/api/creditcardpayment/${credit_card_payment_id[0]}  data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    #authorized status is YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ
    Should Contain  ${resp.content}  YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ
	
Find Autopay Payment
    [Arguments]   ${externalId}   ${EBPPUserName}
    &{headers}=  Create Dictionary  properties  
	Set To Dictionary   ${headers}	UserName						dhluser
    Set To Dictionary   ${headers}  SESSION_TOKEN					${session_id}
	Set To Dictionary   ${headers}	ProcessingAccount				QDGfoL8MVLK8A49qup7O2vW1kILuFE2EJMEzbLnq0lPPpviBGUg8!!!jVoNEtcPPe@@@
	Set To Dictionary   ${headers}	Password 						pass2
	Set To Dictionary   ${headers}	Customerid						${customerid}
	Set To Dictionary   ${headers}	CreditCardPaymentStatus			P2EqpaxBJf3aIKcOBazAh!!!XTSthTC0YsH90MJdXBftpkOZrl@@@iDqCVrIPI6C2llT
	Set To Dictionary   ${headers}	CreditCardPaymentAccount		${cc_pmt_acct_id}
	Set To Dictionary   ${headers}	Cookie							null
	Set To Dictionary   ${headers}	BankAccountType					${BankAccountType}
	Set To Dictionary   ${headers}	API_KEY							${api_key}
	Set To Dictionary   ${headers}	ApiKeyName						${ApiKeyName}
	Set To Dictionary   ${headers}	Amount							${Amount}
	Set To Dictionary   ${headers}	AchPaymentAccount		        ${ach_pmt_acct_id}		
	Set To Dictionary   ${headers}	CreditCardPaymentid				${cc_pmt_acct_id}
	Set To Dictionary   ${headers}	AuditUserId						763
	Set To Dictionary   ${headers}	Userid						    ${Userid}
	
	
*** Variables ***
#Each of these must be passed by command line
#an example:  robot --variable OS:Linux --variable IP:10.0.0.42 my_test_suite_file.robot
#See http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#configuring-execution for more detail
#${url}=  http://172.16.225.252:8003
#${username}=  admin
#${password}=  pass2 
#${merchant_search_string}=  Topaz Soda
#${processing_account_search_string}=  Downtown
#${enable_burp_proxy}=  true
${reseller_search_string}=  Topaz Reseller
${account_search_string}=  Dow
${gateway_profile_search_string}=  MONETRAPROFILE
${card_processor_search_string}=  MONETRA
${appName_admin}=  ADMIN
${time_zone_search_string}=   (-10:00) Hawaii
${country_search_string}=  United States
${endpoint_search_string}=  Topaz Reseller
${session_id}=  SESSION_ID_NOT_FOUND
${ach_created_customer_id}=  ACH_CREATED_CUSTOMER_ID_NOT_FOUND 
${cc_created_customer_id}=  CC_CREATED_CUSTOMER_ID_NOT_FOUND
${processing_account_id}=  PROCESSING_ACCOUNT_ID_NOT_FOUND
${api_key}=  API_KEY_NOT_FOUND
${api_key_id}=  API_KEY_ID_NOT_FOUND
${merchant__org_id}=  merchant__org_id_NOT_FOUND
${merchant_merchant_id}=  merchant_merchant_id_NOT_FOUND
${merchant_external_id}=  merchant_external_id_NOT_FOUND
${cc_pmt_acct_id}=  CC_PAYMENT_ACCOUNT_ID_NOT_FOUND
${ach_pmt_acct_id}=  ACH_PAYMENT_ACCOUNT_ID_NOT_FOUND
${fee_schedule_id}=  FEE_SCHEDULE_ID_NOT_FOUND
${zero_fee_schedule_id}=  ZERO_FEE_SCHEDULE_ID_NOT_FOUND
${payment_id}=  PAYMENT_ID_NOT_FOUND
${payment_schedule_id}=  PAYMENT_SCHEDULE_ID_NOT_FOUND
${payment_external_id}=  PAYMENT_EXTERNAL_ID_NOT_FOUND
${alert_id}=  ALERT_ID_NOT_FOUND
${today}=  NULL
${custom_field_name}=  CUSTOM_FIELD_NAME
${custom_field_id}=  CUSTOM_FIELD_ID
${processing_account_email_type_id}=  PROCESSING_ACCOUNT_EMAIL_TYPE_ID
${processing_account_email_type_search_str}=  CHANGE_NEXT_PAYMENT_DATE_EMAILS
${fee_schedule_name}=  FEE_SCHEDULE_NAME
${accountAchAccountId}=  PROCESSING_ACCOUNT_ID_NOT_FOUND
${accountCardId}=  SIGNATURE_ID_NOT_FOUND
${scheduleId}=  SIGNATURE_ID_NOT_FOUND
#dummy signature, this needs to be computed for a valid test
${signature}=  ODI4MjA2MTN8MjAxOC0xMS0zMCAwNzowNjowNyBVVEN8aGREZFZWaUxLdEx3aXpxckBmdW5kdGVjaC5jb218OTYyYTcwMTZmYWEwYTI4ZjNiYzM3NDNhZGU0NzFmNzM0Y2U4MA\=\=
${BusinessName}=  BUSINESS_NAME_NOT_FOUND
${api_processing_account_id}=  API_PROCESSING_ACCOUNT_ID_NOT_FOUND
${reseller_id}=  RESELLER_ID_NOT_FOUND
${merchant_id}=  MERCHANT_ID_NOT_FOUND
${external_id}=  EXTERNAL_ID_NOT_FOUND
${card_processor_id}=   CARD_PROCESSOR_ID_NOT_FOUND
${country_id}=   COUNTRY_ID_NOT_FOUND
${timezone_id}=  TIMEZONE_ID_NOT_FOUND
${gateway_profiles_id}=  GATEWAY_PROFILE_ID_NOT_FOUND
${endpoint_id}=  ENDPOINT_ID_NOT_FOUND
${account_location_id}=  ACCOUNT_LOCATION_ID_NOT_FOUND
${processing_account_location_id}=  ACCOUNT_LOCATION_ID_NOT_FOUND
${acount_location_name_uniqueifier}=  ACCOUNT_LOCATION_UNIQUEIFIER_NOT_FOUND
${profile_id}=  PROFILE_ID_NOT_FOUND
#${today}=  Get Current Date result_format=%m/%d/%Y
#${today} =    Subtract Time From Date    ${today}    10d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
${yesterday}=    Subtract Time From Date    ${today}    1d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
${successflag}
${BankAccountType}=   BankAccountType_NOT_FOUND
${ApiKeyName}=   ApiKeyName_NOT_FOUND
${Amount}=   Amount_NOT_FOUND
${Userid}=   Userid_NOT_FOUND
${OrganizationTypeid}=  OrganizationType id_FOUND
${customerid}=  OrganizationType id_FOUND


*** Settings ***
Test Setup  Setup Test Suite

*** Test Cases ***

Authenticate to the Admin Server  
    Set Log Level  debug
    ${proxies}=  Create Dictionary  http=localhost:8080  https=localhost:8080
    Run Keyword If  '${enable_burp_proxy}'=='true'  Create Session  adminSession  ${url}  debug=3  proxies=${proxies}
    Run Keyword Unless  '${enable_burp_proxy}'=='true'  Create Session  adminSession  ${url}  debug=3 
    Login to Admin
    
GetSessionIdleTimeOut
   
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/xGetSessionIdleTimeOut  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=    Run Keyword And Return Status    Should Contain    ${resp.content}    "timeout"
    Should Be Equal   '${success}'  'True'
    
Application Header Admin
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/header/xGenerateHeaderJsonData  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${companyName}=  Get Items By Path  ${resp.content}  $..companyname
    Should Be Equal   ${companyName}   ${compName}
    
    
Read App Name Admin
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/navNavigationItem/xGenerate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${applicationName}=  Get Items By Path  ${resp.content}  $..appName
    Should Be Equal  ${applicationName}  ${appName_admin}
    
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
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
	#&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    #${resp}=  Post Request  adminSession  /sbpsAdmin/reseller/xList  data=${data}  headers=${headers}
    ${resp}=  Post Request  adminSession  /sbpsAdmin/reseller/xList  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${reseller_id}  Get Items By Path  ${resp.content}  $..resellers[?(@.resellername=='${reseller_search_string}')].id
    Log  ${reseller_id}
    #Pretty Print  ${reseller_id}
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
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadCardProcessors  data=${data}  headers=${headers}
    Log  ${resp.content}s
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    #${reseller_id}  Get Items By Path  ${resp.content}  $..resellers[?(@.resellername=='${reseller_search_string}')].id
    ${card_processor_id}  Get Items By Path  ${resp.content}  $..cardProcessors[?(@.name=='${card_processor_search_string}')].id
    Log  ${card_processor_id}
    #Pretty Print  ${reseller_id}
    Set Suite Variable  \${card_processor_id}  ${card_processor_id}  
    
Read TimeZones
    
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
    ${succes}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${succes}   false

Search Merchant
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
   
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}    searchValue  Topaz Soda
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
    Set To Dictionary  ${data}  searchValue  Downtown
    Set To Dictionary  ${data}  merchantid  ${merchant_id}
    Set To Dictionary  ${data}  page  1
   Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    # ${account_location_id}  Get Items By Path  ${resp.content}  $..accountlocations[?(@.accountlocationname=='${processing_account_search_string}')].merchantid
    # Log  ${account_location_id}
    # Set Suite Variable  \${account_location_id}  ${account_location_id}
    ${success}=  Get Items By Path  ${resp.content}  $..succes
    Should Be Equal   ${success}   true    


Get Extra Settings
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  processorName  LOOPBACK
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xGetExtraSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   false  
    


Read Card Institutions
    &{data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  processorId  ${card_processor_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/configuration/xReadCardInstitutions  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Read ACH Endpoints
    
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

Read Gateway Profiles
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  merchantid   ${merchant_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/merchant/xReadGatewayProfiles  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true    
    ${gateway_profiles_id}  Get Items By Path  ${resp.content}  $..gatewayprofiles[?(@.cardpresentprofilename=='${gateway_profile_search_string}')].id
    Log  ${gateway_profiles_id}
    Set Suite Variable  \${gateway_profiles_id}  ${gateway_profiles_id}

 



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
        

 
Create Merchant with CC Account 
 
    Log  ${reseller_id} 
    Log  ${card_processor_id}
    Log  ${timezone_id}
    Log  ${country_id}
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    ${merchant_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    Log   ${merchant_name_uniqueifier}
    
    Set To Dictionary  ${data}   merchantdata                   [{"resellerid":"${reseller_id}","merchantname":"${merchant_name_uniqueifier}","address":"253 East Lincoln Ave","addresstwo":"","city":"Plain City","state":"AL","zipcode":"10415-9480","country":"US","phone":"555-581-5392","fax":"555-622-9490","merchantTimeZone":"${timezone_id}","contactfirstname":"firstname${merchant_name_uniqueifier}","contactlastname":"lastname${merchant_name_uniqueifier}","contactphone":"555-396-3280","contactemail":"breanna@example.com","merchantwebsite":"http://www.moorecomputer.info/","billingroutingnumber":"021200025","billingaccountnumber":"6011111111111117","logoutreturnpath":"www.moorecomputer.net","merchantreferencenumber":"","externalid":"76897","merchantid":""}]
    Set To Dictionary  ${data}   ccdata                         [{"cardpresentprofilename":"InvolvitAdmittenda","cardprocessor":"${card_processor_id}","cardinstitution":"","cybersourcemerchantid":"","extrasettings":"","cardbatchcutofftime":"0","cardbatchcutoffminute":"0","acceptvisa":"on","acceptmastercard":"on","acceptamex":"on","acceptdiscover":"on","acceptamericanexpress":"on"}]
    Set To Dictionary  ${data}   achdata                        [{}]
    Set To Dictionary  ${data}   rdcdata                        [{}]
    Set To Dictionary  ${data}   processorfieldvalues           [{}]
    Set To Dictionary  ${data}   accountlocations                [{"merchantid":"","merchantname":"","accountlocationname":"incumbit","address":"419 East Roosevelt Sq, Building 23","city":"Sigurd","state":"AL","zipcode":"37607","country":"US","phone":"555-425-8683","fax":"555-356-5623","contactfirstname":"Michael","contactlastname":"Rowland","contactphone":"555-873-8642","contactemail":"caroline@example.com","merchantwebsite":"www.demortuisautbene.com","naics":111110,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"","acceptCreditcard":"on","acceptRdc":"","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"123456","accountLocationTimeZone":"${timezone_id}","gatewayTimeZone":"","extrasettings":"","id":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xCreate  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Create Merchant with ACH Account 
 
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
    #Set To Dictionary  ${data}   ccdata                         [{"cardpresentprofilename":"InvolvitAdmittenda","cardprocessor":"${card_processor_id}","cardinstitution":"","cybersourcemerchantid":"","extrasettings":"","cardbatchcutofftime":"0","cardbatchcutoffminute":"0","acceptvisa":"on","acceptmastercard":"on","acceptamex":"on","acceptdiscover":"on","acceptamericanexpress":"on"}]
    Set To Dictionary  ${data}   achdata                        [{"endpoint":"${endpoint_id}","achdepositrouting":"121042882","achdepositaccountnumber":"491282246310 005","nameonachdeposit":"Timothy Huffman","nametoapperincustomer":"Timothy","companyid":"4546434325","achdisbursementwindow":"0","reserverate":"0","reservemax":"99999","maxtransactionlimit":"999999.99","achduplicatecheckingwindow":"0","maxdailynumberofpayments":"99999999","maxmonthlynumberofpayments":"99999999","maxmonthlytransactionlimit":"999999.99","maxdailytransactionlimit":"999999.99","nsfautomatedresubmits":"0"}]
    Set To Dictionary  ${data}   rdcdata                        [{}]
    Set To Dictionary  ${data}   processorfieldvalues           [{}]
    Set To Dictionary  ${data}   accountlocations               [{"merchantid":"","merchantname":"","accountlocationname":"Virginia","address":"716 Penn Drive","city":"Bristow","state":"VA","zipcode":"20136","country":"US","phone":"6143085405","fax":"6143085405","contactfirstname":"Timothy","contactlastname":"Huffman","contactphone":"6143085405","contactemail":"timothy.huffman@yahoo.co.in","merchantwebsite":"www.merchantutf.com","naics":424910,"achdepositrouting":"","achdepositaccountnumber":"","nameonachdeposit":"","nametoapperincustomer":"","acceptAch":"on","acceptCreditcard":"","acceptRdc":"","acceptCash":"","resellername":"","cardprocessor":"","cardinstitution":"","maxcreditperday":"999999.99","maxcreditpermonth":"999999.99","cardpresentprofilename":"","gatewayusername":"","gatewaypassword":"","terminalid":"","acceptvisa":"","acceptmastercard":"","acceptamericanexpress":"","acceptdiscover":"","requirecvv":"","avscheck":"","gatewayprofileid":"","fileendpointid":"","cardbatchcutofftime":"","processingaccountstatus":"Active","gatewayId":"","organizationId":"","externalId":"","displayLevel2Fields":"","displayCvvField":"","requireCvv":"","a8ooldxqx6":"","dateCreated":"","lastUpdated":"","fullname":"","achdisbursementwindow":"","reserverate":"","reservemax":"","maxdailynumberofpayments":"","maxmonthlynumberofpayments":"","maxmonthlytransactionlimit":"","maxdailytransactionlimit":"","achduplicatecheckingwindow":"","nsfautomatedresubmits":"","cardbatchcutoffminute":"","companyid":"","maxtransactionlimit":"","status":"","achendpointid":"","rdcdepositrouting":"","rdcdepositaccountnumber":"","accountreferencenumber":"","accountLocationTimeZone":"${timezone_id}","gatewayTimeZone":"","extrasettings":"","id":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/processingAccount/xCreate  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
 
 
Create Account Location with CC Account
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
    
    ${olddate}    Subtract Time From Date    ${today}    1d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y 
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate    ${olddate}
    Set To Dictionary  ${data}  todate    ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  checkDataExist  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbpsAdmin/adminReport/txnSummaryReportDownload  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Not Be Empty   ${success}
    ${totalCount}=  Get Items By Path  ${resp.content}  $..totalCount
    Should Not Be Equal   ${totalCount}   0
    Should Be Equal   ${success}   true
     
Research Transactions
    
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

Authenticate to the server 
    [Tags]  DHL  
    Set Log Level  debug
    ${proxies}=  Create Dictionary  http=localhost:8080  https=localhost:8080
    Run Keyword If  '${enable_burp_proxy}'=='true'  Create Session  adminSession  ${url}  debug=3  proxies=${proxies}
    Run Keyword Unless  '${enable_burp_proxy}'=='true'  Create Session  adminSession  ${url}  debug=3 
    Login 

Check error page doesn't contain user input
	&{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/accountLocation/xReadMasterCardValidationmpw9uytofq   data=${data}  headers=${headers}
    Should Not Contain  ${resp.text}  mpw9uytofq

Post Merchant Detail (Cannot be called later because it sets the merchant too. This requires fixing.)
	&{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/header/xGetMerchantDetail  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    
Application Header
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/header/xGenerateHeaderJsonData  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${companyName}=  Get Items By Path  ${resp.content}  $..companyname
    Should Be Equal   ${companyName}   ${compName}
    
Read App Name
    &{data}=  Create Dictionary   csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/navNavigationItem/xGenerate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${applicationName}=  Get Items By Path  ${resp.content}  $..appName
    Should Be Equal  ${applicationName}  ${appName}  
    
Application Sidebar
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/sidebar/xGenerateSidebarJsonData  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${collapsible}=  Get Items By Path  ${resp.content}  $..collapsible
    Should Be Equal   ${collapsible}   true
    
Mastercard Validation
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/accountLocation/xReadMasterCardValidation  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
    
Available Downloads
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/transactionReport/xAvailableDownloads  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true 

Read TodayDate
    &{data}  Create Dictionary   csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/json;charset=UTF-8
    ${resp}=  Post Request  adminSession  /sbps/home/xUserTodayDate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
Read Payment Alert Summary
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/home/xPaymentAlertSummary  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${total}=  Get Items By Path  ${resp.content}  $..total
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Run keyword if  ${total} == 0  Should Be Equal  ${success}  false    
    # ELSE  Should Be Equal  ${success}  true
      
Retrieve Merchant List and Select Merchant (version > 2.4 only)
    ${data}=  Create Dictionary  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/header/xRetrieveMerchantList  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${merchant__org_id}=  Get Regexp Matches  ${resp.content}  "${merchant_search_string}","orgId":"?(.*?)"?,  1
    Log  ${merchant__org_id}
    Set Suite Variable  \${merchant__org_id}  ${merchant__org_id[0]}
    ${merchant_merchant_id}=  Get Regexp Matches  ${resp.content}  "${merchant_search_string}".*?,"merchantId":"?(.*?)"?,  1
    Log  ${merchant_merchant_id}
    Set Suite Variable  \${merchant_merchant_id}  ${merchant_merchant_id[0]}  
    ${merchant_external_id}=  Get Regexp Matches  ${resp.content}  "${merchant_search_string}".*?,"externalId":"?(.*?)"?,  1
    Log  ${merchant_external_id}
    Set Suite Variable  \${merchant_external_id}  ${merchant_external_id[0]}  

Update Merchant (version > 2.4 only)
    ${data}  Create Dictionary  orgId  ${merchant__org_id}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/header/xUpdateMerchant  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
         
Read Account Location Id
    Read Account Location 

Hide Reconcilaton Report
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  merchantid  ${merchant_external_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/transactionReport/xHideReconcilationReport  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${hidereport}=  Get Items By Path  ${resp.content}  $..hidereport
    Should Be Equal  ${hidereport}  true
    
Read Supported AccountTypes
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  accountlocationid  ${processing_account_id}
    Set To Dictionary  ${data}  simpleNames  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/accountType/xReadSupportedAccountTypes  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    
Retrieve Summary
    
    ${today}    Get Current Date    result_format=%m/%d/%Y
    ${olddate}    Subtract Time From Date    ${today}    10d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y    
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate  ${olddate}
    Set To Dictionary  ${data}  todate  ${today}
    Set To Dictionary  ${data}  accountlocationids  All
    Set To Dictionary  ${data}  reportbydate  transactionDate
    Set To Dictionary  ${data}  includestatustype  Accepted
    Set To Dictionary  ${data}  includestatustype  Authorized
    Set To Dictionary  ${data}  includestatustype  Pending Deposit Review
    Set To Dictionary  ${data}  includestatustype  Processed
    Set To Dictionary  ${data}  includestatustype  Settled
    Set To Dictionary  ${data}  includestatustype  Submitted
    Set To Dictionary  ${data}  includecustomdataflag  false
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/TransactionReport/getSummary  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${var}=    Run Keyword And Return Status    Should Contain    ${resp.content}    "errors"
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Run keyword if  ${var} == 'True'    Should Be Equal   ${success}   false  
    Run keyword if  ${var} == 'False'  Should Be Equal   ${success}   true  
   
Retrieve Details
 
    ${today}    Get Current Date    result_format=%m/%d/%Y
    ${olddate}    Subtract Time From Date    ${today}    10d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate  ${olddate}
    Set To Dictionary  ${data}  todate  ${today}
    Set To Dictionary  ${data}  accountlocationids  All
    Set To Dictionary  ${data}  reportbydate  transactionDate
    Set To Dictionary  ${data}  includestatustype  Accepted
    Set To Dictionary  ${data}  includestatustype  Authorized
    Set To Dictionary  ${data}  includestatustype  Pending Deposit Review
    Set To Dictionary  ${data}  includestatustype  Processed
    Set To Dictionary  ${data}  includestatustype  Settled
    Set To Dictionary  ${data}  includestatustype  Submitted
    Set To Dictionary  ${data}  includecustomdataflag  false
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/TransactionReport/getDetails  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${errors}=  Get Items By Path  ${resp.content}  $..errors
    ${errLength}=  Get Length  ${errors}
    Run keyword if  ${errLength} == 2  Should Be Equal   ${success}  true
    Run keyword if  ${errLength} > 2    Should Be Equal   ${success}   false
      
Download Report
   
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/transactionReport/isDownloadTooLarge  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${message}=  Get Items By Path  ${resp.content}  $..message
    log     ${message}
    ${resp}=    Run Keyword And Return Status    Should Contain    ${message}    success
    Run keyword if  ${resp} == 'true'   Should Be Equal   ${message}   Download too large
    Run keyword if  ${resp} == 'false'  Should Be Equal   ${message}   Download ok  
    log     ${resp}
    log     ${message}
    
Create API Key
    ${api_key}=  Generate Random String  length=10  chars=[LETTERS]
    ${data}  Create Dictionary   name  ${api_key} 
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/settings/xCreateApiKey  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${api_key}=  Get Regexp Matches  ${resp.content}  "apikey":"(.*?)","  1
    ${api_key_id}=  Get Regexp Matches  ${resp.content}  "prcacctapiid":"?(.*?)"?,"  1                                               
    Log  ${api_key[0]}
    Set Suite Variable  \${api_key}  ${api_key[0]}   
    Log  ${api_key_id[0]}
    Set Suite Variable  \${api_key_id}  ${api_key_id[0]}   
    
Update API Key    
     ${data}  Create Dictionary  csrfToken  ${session_id}
     Set To Dictionary  ${data}  name  ${api_key}  
     Set To Dictionary  ${data}  prcacctapiid  ${api_key_id}
     Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
     Set To Dictionary  ${data}  isenabled  true
     &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
     ${resp}=  Post Request  adminSession  /sbps/settings/xUpdateApiKey  data=${data}  headers=${headers}
     Pretty Print  ${resp.content}
     ${success}=  Get Items By Path  ${resp.content}  $..success
     Should Be Equal  ${success}  true

Create Customer With ACH Account
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  customertype  person
    Set To Dictionary  ${data}  entprocessingaccount_id  ${processing_account_id}
    Set To Dictionary  ${data}  city  Kaysville
    Set To Dictionary  ${data}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${data}  emailaddress  monte.wingle${customer_name_uniqueifier}@dh.com
    Set To Dictionary  ${data}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  phonenumber  (555)555-5555 
    Set To Dictionary  ${data}  state  UT 
    Set To Dictionary  ${data}  street1  10 W 600 N 
    Set To Dictionary  ${data}  zip  84041 
    Set To Dictionary  ${data}  entbankaccounttype  1 
    Set To Dictionary  ${data}  pa_accountnumber  111111111111 
    Set To Dictionary  ${data}  pa_nameonaccount  firstname lastname
    Set To Dictionary  ${data}  pa_routingnumber  021000021 
    Set To Dictionary  ${data}  pa_name  JPMORGAN CHASE BANK CHECKING xxxxx1111 
    Set To Dictionary  ${data}  billingaddressstreet  10 W 600 N 
    Set To Dictionary  ${data}  billingcity  Kaysville 
    Set To Dictionary  ${data}  billingstate  UT 
    Set To Dictionary  ${data}  billingzip  84041 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${ach_created_customer_id}=  Get Regexp Matches  ${resp.content}  customers":\\[{"id":"?(.*?)"?,  1                                               
    Log  ${ach_created_customer_id[0]}
    Set Suite Variable  \${ach_created_customer_id}  ${ach_created_customer_id[0]}

Read New Customer
    ${data}  Create Dictionary   customerorgid  ${ach_created_customer_id} 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/customerOrganization/xGetCustomer  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  

Create ACH Payment Account
    ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  customertype  person
    Set To Dictionary  ${data}  paymentaccounts  [{"customer_id":"${ach_created_customer_id}","name":"${payment_account_name}","entbankaccounttype":1,"datecreated":"","lastupdated":"","nameonaccount":"a081726588","routingnumber":"021000021","achabart":"","achaccountnumber":"","accountnumber":"0626","nameoncard":"","cardnumber":"","expirymonth":"","expiryyear":"","isactive":"","entcreditcardtype":"","accounttype":1,"pa_nameonaccount":"a081726588","pa_nameoncard":"","pa_cardnumber":"","billingaddress":"","billingaddressstreet":"","billingcity":"","billingstate":"","billingpostalcode":"","billingzip":"","requirecvv":"","user_id":""}]
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    Should Contain  ${resp.content}  ${ach_created_customer_id}
    ${ach_pmt_acct_id}  Get Items By Path  ${resp.content}  $..paymentaccounts.id
    Log  ${ach_pmt_acct_id}
    Set Suite Variable  \${ach_pmt_acct_id}  ${ach_pmt_acct_id}

Get ACH Payment Accounts
    ${data}  Create Dictionary  customer_id  ${ach_created_customer_id} 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  filter  [{"property":"customer_id","value":"${ach_created_customer_id}"]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/xListAchAccount  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    
Create Customer with Card Payment Account
    ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${customer_name_random_part}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary    customertype  person
    Set To Dictionary  ${data}  entprocessingaccount_id  ${processing_account_id}
    Set To Dictionary  ${data}  city  Gainesville
    Set To Dictionary  ${data}  customerid  ${customer_name_random_part}
    Set To Dictionary  ${data}  emailaddress  ${customer_name_random_part}@dh.com
    Set To Dictionary  ${data}  firstname  first${customer_name_random_part}
    Set To Dictionary  ${data}  lastname  last${customer_name_random_part}
    Set To Dictionary  ${data}  phonenumber  (801)540-7447
    Set To Dictionary  ${data}  state  FL
    Set To Dictionary  ${data}  street1  5800 NW 39th AVE
    Set To Dictionary  ${data}  zip  32606
    Set To Dictionary  ${data}  billingaddressstreet  5800 NW 39th AVE
    Set To Dictionary  ${data}  billingcity  Gainesville
    Set To Dictionary  ${data}  billingstate  FL
    Set To Dictionary  ${data}  billingzip  32606
    Set To Dictionary  ${data}  entcreditcardtype  4
    Set To Dictionary  ${data}  expirymonth  11
    Set To Dictionary  ${data}  expiryyear  23
    Set To Dictionary  ${data}  pa_cardnumber  4111111111111111
    Set To Dictionary  ${data}  cardnumber  4111111111111111
    Set To Dictionary  ${data}  name  VISAxxxxx1111
    Set To Dictionary  ${data}  pa_nameoncard  name${customer_name_random_part}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${cc_created_customer_id}=  Get Regexp Matches  ${resp.content}  customers":\\[{"id":"?(.*?)"?,  1
    ${cc_pmt_acct_id}=   Get Regexp Matches  ${resp.content}  paymentAccount_id":"?(.*?)"?,  1  
    Log  ${cc_pmt_acct_id[0]}                                       
    Log  ${cc_created_customer_id[0]}
    Set Suite Variable  \${cc_created_customer_id}  ${cc_created_customer_id[0]}
    Set Suite Variable  \${cc_pmt_acct_id}  ${cc_pmt_acct_id[0]}
    
Create Fee Schedule   
    ${fee_schedule_name}=  Generate Random String  length=20  chars=[LETTERS][NUMBERS]
    ${data} =  Create Dictionary    achAmount  1
    Set To Dictionary  ${data}  achPercent  1
    Set To Dictionary  ${data}  ccAmount  1
    Set To Dictionary  ${data}  ccPercent  1
    Set To Dictionary  ${data}  description  Autogenerated
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  sortOrder  4
    Set To Dictionary  ${data}  isDefault  false
    Set To Dictionary  ${data}  name  ${fee_schedule_name}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/configuration/xCreateFeeSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${fee_schedule_id}=  Get Items By Path  ${resp.content}  $..entFeeScheduleId
    ${fee_schedule_id}=  Remove String  ${fee_schedule_id}  "
    Set Suite Variable  \${fee_schedule_id}  ${fee_schedule_id}
    Set Suite Variable   \${fee_schedule_name}  ${fee_schedule_name}
    
Update Fee Schedule
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  name   ${fee_schedule_name}
    Set To Dictionary  ${data}  feeScheduleId  ${fee_schedule_id}
    Set To Dictionary  ${data}  isDefault  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/configuration/xUpdateFeeSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
    
Read Fee Schedule
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xReadFeeSchedule  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${fee_schedule_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${fee_schedule_id[0]} 
    ${zero_fee_schedule_id}=  Get Items By Path  ${resp.content}  $..feeSchedules[?(@.name=='ZERO FEE SCHEDULE')].id
    Set Suite Variable  \${zero_fee_schedule_id}  ${zero_fee_schedule_id} 

Calculate Payment Total
    #ACH OneTime
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  achamount  ""  
    Set To Dictionary  ${data}  achbeginningbal  6.02
    Set To Dictionary  ${data}  achfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  achnumberpayments  ""  
    Set To Dictionary  ${data}  entbankaccounttype  1
    Set To Dictionary  ${data}  paymenttype  OneTime
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${totalAmount}  Get Items By Path  ${resp.content}  $..totalamount 
    Should Be Equal  ${totalAmount}  $7.08 
    ${feeAmount}  Get Items By Path  ${resp.content}  $..feeamount 
    Should Be Equal  ${feeAmount}  $1.06 
    #CC OneTime
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  ccamount  ""  
    Set To Dictionary  ${data}  ccbeginningbal  6.02
    Set To Dictionary  ${data}  ccfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  ccnumberpayments  ""
    Set To Dictionary  ${data}  entcreditcardtype  4
    Set To Dictionary  ${data}  paymenttype  OneTime
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${totalAmount}  Get Items By Path  ${resp.content}  $..totalamount 
    Should Be Equal  ${totalAmount}  $7.08 
    ${feeAmount}  Get Items By Path  ${resp.content}  $..feeamount 
    Should Be Equal  ${feeAmount}  $1.06 
    #ACH Installment
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  achamount  13.14
    Set To Dictionary  ${data}  achbeginningbal  257
    Set To Dictionary  ${data}  achfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  achnumberpayments  "" 
    Set To Dictionary  ${data}  entbankaccounttype  1
    Set To Dictionary  ${data}  paymenttype  Installment
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${totalAmount}  Get Items By Path  ${resp.content}  $..totalamount 
    Should Be Equal  ${totalAmount}  $279.54 
    ${firstPayment}  Get Items By Path  ${resp.content}  $..firstpayment 
    Should Be Equal  ${firstPayment}  $13.14 
    ${firstPaymentFee}  Get Items By Path  ${resp.content}  $..firstpaymentfee 
    Should Be Equal  ${firstPaymentFee}  $1.13 
    ${firstPaymentWithFee}  Get Items By Path  ${resp.content}  $..firstpaymentwithfee 
    Should Be Equal  ${firstPaymentWithFee}  $14.27 
    ${lastPaymentFee}  Get Items By Path  ${resp.content}  $..lastpaymentfee 
    Should Be Equal  ${lastPaymentFee}  $1.07 
    ${numberPayments}  Get Items By Path  ${resp.content}  $..numberpayments 
    Should Be Equal  ${numberPayments}  20 
    # CC Installment
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  ccamount  13.14 
    Set To Dictionary  ${data}  ccbeginningbal  257
    Set To Dictionary  ${data}  ccfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  ccnumberpayments  "" 
    Set To Dictionary  ${data}  entcreditcardtype  4
    Set To Dictionary  ${data}  paymenttype  Installment
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${totalAmount}  Get Items By Path  ${resp.content}  $..totalamount 
    Should Be Equal  ${totalAmount}  $279.54 
    ${firstPayment}  Get Items By Path  ${resp.content}  $..firstpayment 
    Should Be Equal  ${firstPayment}  $13.14 
    ${firstPaymentFee}  Get Items By Path  ${resp.content}  $..firstpaymentfee 
    Should Be Equal  ${firstPaymentFee}  $1.13 
    ${firstPaymentWithFee}  Get Items By Path  ${resp.content}  $..firstpaymentwithfee 
    Should Be Equal  ${firstPaymentWithFee}  $14.27 
    ${lastPaymentFee}  Get Items By Path  ${resp.content}  $..lastpaymentfee 
    Should Be Equal  ${lastPaymentFee}  $1.07 
    ${numberPayments}  Get Items By Path  ${resp.content}  $..numberpayments 
    Should Be Equal  ${numberPayments}  20 
    # Recurring does not call calculatePaymentTotal
    
Create Card Payment - Authorized based on $12 amount
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":12,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"${today}","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    Log  ${data}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}    

Create Card Payment - Authorized based on $11.00 amount
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":11,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"${today}","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}  

Create Card Payment - Authorized based on $15 amount
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":15.0,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"${today}","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}  
    
Create CC Installment Payment for $6
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions    [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"10","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":2,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":10,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":1,"firstpaymentwithfee":6,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":10,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 

Create CC Installment Payment for $5/Payment Expect Failure
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions     [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"100","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":20,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":100,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":1,"firstpaymentwithfee":5,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":100,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Log  ${paymentStatus}
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}
    ${payment_schedule_id}=   Get Items By Path  ${resp.content}  $..txnpaymentscheduleid
    Log  ${payment_schedule_id}    
    Set Suite Variable  \${payment_schedule_id}  ${payment_schedule_id}
    ${payment_id}=   Get Items By Path  ${resp.content}  $..onetimeid
    Log  ${payment_id}    
    Set Suite Variable  \${payment_id}  ${payment_id}
    ${payment_external_id}=   Get Items By Path  ${resp.content}  $..externalid
    Log  ${payment_external_id}
    Set Suite Variable  \${payment_external_id}  ${payment_external_id}

Read Payment Status Submitted
    [Tags]  minVersion_2.7
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  transactiondate  ${today} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/home/xPaymentStatusSubmittedRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}  true

Read Transaction History
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  month  10
    Set To Dictionary  ${data}  year  118
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/home/xTransactionHistoryRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

 Read Snapshot Calendar
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  date  ${today} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/home/xSnapshotCalendar  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Get Payment Alerts
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/home/xPaymentAlertSummary  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${alertstatus}=  Get Items By Path  ${resp.content}  $..alertstatus 
    Should Be Equal  ${alertstatus}  1
    ${amount}=  Get Items By Path  ${resp.content}  $..amount
    Should Be Equal  ${amount}  5 
    ${payment_id_in}=  Get Items By Path  ${resp.content}   $..id
    Should Be Equal  ${payment_id_in}  ${payment_id} 
    ${alert_id}=  Get Items By Path  ${resp.content}  $..alertid
    Log  ${alert_id}
    ${alert_id}=  Set Suite Variable  \${alert_id}  ${alert_id}

Read Transaction Detail  
    ${stripped_payment_id}=  Remove String  ${payment_id}  "
    ${stripped_payment_external_id}=  Remove String  ${payment_external_id}  "
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  id  ${stripped_payment_id} 
    Set To Dictionary  ${data}  paymenttxntype  CC
    Set To Dictionary  ${data}  externalid  ${stripped_payment_external_id} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xReadTransactionDetail  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${alertid_in}=  Get Items By Path  ${resp.content}  $..alertid 
    Should Be Equal  ${alertid_in}  ${alertid}  
    ${alertstatus_in}=  Get Items By Path  ${resp.content}  $..alertstatus 
    Should Be Equal  ${alertstatus_in}  1  
    ${processingaccountid_in}=  Get Items By Path  ${resp.content}  $..processingaccountid 
    Should Be Equal  ${processingaccountid_in}  ${processing_account_id}  

Read Payment Schedules for CC Customer
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id  ${cc_created_customer_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    Set To Dictionary  ${data}  filter  [{"property":"customer_id","value":"${cc_created_customer_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactions  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
                    
Create ACH Installment Payment
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions  [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${ach_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Richard Rich","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":8,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":25,"ccbeginningbal":"","achbeginningbal":200,"achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","achtxnfrequencytype":1,"cctxnfrequencytype":"","firstpaymentwithfee":25,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":1,"entcreditcardtype":"","achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":200,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 

Read Customers
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    Set To Dictionary  ${data}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/customerOrganization/xListCustomers  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 

Display Email Settings
    &{data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  usertz  -0600
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/settings/xDisplayEmailSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${payment_receipt_emails_api}  Get Items By Path  ${resp.content}  $..merchants[?(@.name=='${merchant_search_string}')]
    Log  ${payment_receipt_emails_api}
    Should Contain  ${payment_receipt_emails_api}  PAYMENT_RECEIPT_EMAILS_API
    ${emailTypeId}  Get Items By Path  ${resp.content}  $..emailTypes[?(@.name=='${processing_account_email_type_search_str}')].id
    Set Suite Variable  \${processing_account_email_type_id}  ${emailTypeId}
    Log  ${emailTypeId}

Delete API Key
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  prcacctapiid  ${api_key_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/settings/xDeleteApiKey  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    Should Contain  ${resp.content}   "success":true,"errors"
    
Read CustomField Types
    ${data}=  Create Dictionary  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession   /sbps/configuration/xReadCustomFieldTypes  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${customFieldTypes_id}=  Get Items By Path  ${resp.content}  $..customFieldTypes
    Log  ${customFieldTypes_id}

Create CustomField
    ${customFieldName}=  Generate Random String  length=10  chars=[LETTERS]
    Set Suite Variable  \${custom_field_name}  ${customFieldName}
    ${data}  Create Dictionary   csrfToken   ${session_id}
    Set To Dictionary  ${data}   processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}   customFieldName  ${customFieldName}
    Set To Dictionary  ${data}   customFieldRule   AnyText32
    Set To Dictionary  ${data}   customFieldType   TEXT
    Set To Dictionary  ${data}   isRequired   true
    Set To Dictionary  ${data}   isEnabled    true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xCreateCustomField   data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Read CustomField   
    ${data} =  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}   usertz  +0530  
    Set To Dictionary  ${data}   entProcessingAccountId   ${processing_account_id}
    Set To Dictionary  ${data}   filter  [{"property":"processingAccountId", "value":"${processing_account_id}"}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xReadCustomField  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${customfieldid}=  Get Items By Path  ${resp.content}  $..prcAccountCustomFields[?(@.customFieldName=='${custom_field_name}')].id 
    Set Suite Variable  \${custom_field_id}  ${customfieldid}    
    Should Be Equal  ${success}  true

Update CustomField in Payment Portal
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entPrcAccountCustomFieldId  ${custom_field_id}
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  isRequired  false
    Set To Dictionary  ${data}  isEnabled  true  
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xUpdateCustomField  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Update CustomField in HPP
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entPrcAccountCustomFieldId  ${custom_field_id}
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  isHostedPageRequired  true
    Set To Dictionary  ${data}  isHostedPageEnabled  true  
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xUpdateCustomField  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Delete Custom Field
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId   ${processing_account_id}
    Set To Dictionary  ${data}  id  ${custom_field_id}   
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xDeleteCustomField  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
Read Processing Settings
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  processingaccountid   ${processing_account_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xReadProcessingSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    
Update Processing Settings
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  displayLevel2Fields  true
    Set To Dictionary  ${data}  requireCvv  true  
    Set To Dictionary  ${data}  requireAvs  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xUpdateProcessingSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Delete Fee Schedule
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0500
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  feeScheduleId  ${fee_schedule_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xDeleteFeeSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
Read Custom Field Rules
    ${data}  Create Dictionary  csrfToken   ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0       
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xReadCustomFieldRules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    
Store Email Settings
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  merchants  [{"id":"${merchant_merchant_id}", "accountLocations":[{"id": "${processing_account_id}","emailTypes":[{"id":"${processing_account_email_type_id}","bccEmails":null,"name": "${processing_account_email_type_search_str}","sendTo":{"merchant": true,"customer": true,"accountLocation":true}}]}]}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/settings/xStoreEmailSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Read HostedPage
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId   ${processing_account_id}
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=   Post Request  adminSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success} =  Get Items By Path   ${resp.content}  $..success
    Should Be Equal  ${success}  true

Read Hosted Page Logo
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/configuration/xReadHostedPageLogo  data=${data}  headers=${headers} 
    
Update Hosted Page Self-Service Payment Settings
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  feeSchedule  ${fee_schedule_id}
    Set To Dictionary  ${data}  displayLevel2DataFields  true
    Set To Dictionary  ${data}  requireCvv  true
    Set To Dictionary  ${data}  requireAvs  false
    Set To Dictionary  ${data}  display  topofpage
    Set To Dictionary  ${data}  disclaimerText  Test
    Set To Dictionary  ${data}  agreeToTerms  true
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/configuration/xUpdateHostedPageSelfServicePaymentSettings  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    
Update HostedPage ReceiptAndMessageSettings
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  customMessage  Test
	Set To Dictionary  ${data}  displayReceiptMessage  false
	Set To Dictionary  ${data}  accountLocationName  true
	Set To Dictionary  ${data}  customerName  true
	Set To Dictionary  ${data}  email  true
	Set To Dictionary  ${data}  phone  true
	Set To Dictionary  ${data}  billingAddress  true
	Set To Dictionary  ${data}  billingCity  true
	Set To Dictionary  ${data}  billingState  true
	Set To Dictionary  ${data}  billingPostalCode  true
	Set To Dictionary  ${data}  nameOnAccount  true
	Set To Dictionary  ${data}  paymentAccount  true
	Set To Dictionary  ${data}  accountType  true
	Set To Dictionary  ${data}  expirationDate  true
	Set To Dictionary  ${data}  transactionId  false
	Set To Dictionary  ${data}  authorizationCode  true
	Set To Dictionary  ${data}  paymentAmount  true
	Set To Dictionary  ${data}  feeAmount  true
	Set To Dictionary  ${data}  totalAmount  true
	Set To Dictionary  ${data}  paymentDate  true    
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/configuration/xUpdateHostedPageReceiptAndMessageSettings  data=${data}  headers=${headers}     
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
Read API Key
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  sbps/settings/xReadApiKey  data=${data}  headers=${headers}     
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Upload Logo
    &{data}  Create Dictionary  csrfToken   ${session_id}
    Set To Dictionary  ${data}  hiddenProcessingAccountId  ${processing_account_id}
    &{files}=    Evaluate  {'file': open('${CURDIR}//grails_logo.png', 'rb')}
    Log Variables 
    ${resp}  Post Request  adminSession  /sbps/configuration/xUpdateLogo  files=${files}  data=${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true


Logout
    Logout

Read Account Location requires csrfToken
    Login
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/accountLocation/xRead  data=${data}  headers=${headers}
    Should Contain  ${resp.text}  <title>Login</title>

Read supported account types
    Login
    ${data}=  Create Dictionary   page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/accountType/xRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    Should Contain  ${resp.content}  CHECKING 
    Should Contain  ${resp.content}  SAVINGS
    Should Contain  ${resp.content}  Credit Card 
    Should Contain  ${resp.content}  RDC 

Read supported account types does not verify csrfToken enforcement because of use by Hosted Payment Page
    ${data}=  Create Dictionary   page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  12345  #invalid token value
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/accountType/xRead  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  <label for='username'>Username:</label>
    Should Contain  ${body}  <label for='password'>Password:</label>
    # the session is invalidated - must login again

Check Hosted Payment Page xReadCustomFields does not enforce csrfToken 
    Login
    Read Account Location
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${paymentPageUrl}=  Get Items By Path  ${resp.content}  $..paymentPageUrl
    Log  ${paymentPageUrl}
    Logout
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  filter  [{"property":"processingAccountId","value":"${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    #Set To Dictionary  ${data}  csrfToken  ${session_id}i
    ${resp}=  Post Request  adminSession  /sbps/payment/${paymentPageUrl}/xReadCustomFields  data=${data}  headers=${headers}  allow_redirects=False
    Log  ${resp.content}
    Log  ${resp.status_code}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  

CalculatePaymentTotal enforces csrfToken
    Login
    ${data}  Create Dictionary  ccamount  13.14 
    Set To Dictionary  ${data}  ccbeginningbal  257
    Set To Dictionary  ${data}  ccfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  ccnumberpayments  "" 
    Set To Dictionary  ${data}  entcreditcardtype  4
    Set To Dictionary  ${data}  paymenttype  Installment
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
    #should have been rejected and redirected to the login screen
    Should Contain  ${resp.text}  <title>Login</title>

Remove extra payment enforces csrfToken
    Login
    ${data}  Create Dictionary  scheduleid  12345 
    Set To Dictionary  ${data}  removeextrapaymentid  257
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xRemoveExtraPayment  data=${data}  headers=${headers}
    #should have been rejected and redirected to the login screen
    Should Contain  ${resp.text}  <title>Login</title>

###########################################################################################################################################
###########################################################################################################################################
# DHL
###########################################################################################################################################
###########################################################################################################################################
Login as dhluser and retrieve the apikey
    [Tags]    DHL
    #hardcoded values (bad, sorry)
    Set Suite Variable  ${username}  dhluser
    Set Suite Variable  ${password}  pass1 
    Set Suite Variable  ${merchant_search_string}  DHL Express
    Set Suite Variable  ${processing_account_search_string=  DHL
    Login
    Read Account Location
    Read API Key
    ${proxies}=  Create Dictionary  http=localhost:8080  https=localhost:8080
    Run Keyword If  '${enable_burp_proxy}'=='true'  Create Session  dhlSession  ${url}  debug=3  proxies=${proxies}
    Run Keyword Unless  '${enable_burp_proxy}'=='true'  Create Session  dhlSession  ${url}  debug=3 
    Set Suite Variable  ${processing_account_id}  1
    Logout

List Processing Accounts using /sbps/api/processingaccounts
    [Tags]    DHL
    &{headers}=  Create Dictionary  Content-Type=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary   ${headers}  Accept=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary  ${headers}  X-TT-APIKEY  ${api_key}
    ${resp}=  Get Request  dhlSession  /sbps/api/processingaccounts  headers=${headers}
    Log  ${resp.content}
    ${root}=  Parse XML  ${resp.content}
    ${api_processing_account_id}=  Get Element Attribute  ${root}  id  xpath=ProcessingAccount[Name='DHL'][last()] 		
    Log  ${api_processing_account_id}
    Set Suite Variable  \${api_processing_account_id}  ${api_processing_account_id}

Call Webship - Simulates a user selecting 'Pay Now' on the DHL
    [Tags]    DHL
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${shipperid}=  Generate Random String  length=7  chars=[NUMBERS]
    ${customer_number}=  Generate Random String  length=9  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  hdnBFCCache  <?xml version\="1.0" encoding\="UTF-8"?><creditcard action\="cc_request"><shipper><shipperid>${shipperid}</shipperid><companyname>Fundtech</companyname><addressline1>5800 NWi 39th AVE</addressline1><addressline2>null</addressline2><city>Gainesville</city><state>FL</state><postalcode>32606</postalcode><countrycode>100</countrycode></shipper><shipment><currentawb>${airwayBillNumber}</currentawb><hasci>1</hasci><ssouserid>${shipperid}</ssouserid><estimatedcharge>18.83</estimatedcharge><userapp>webship</userapp><userappurl>https://webship.dhl-usa.com/</userappurl></shipment></creditcard>
    Set To Dictionary  ${data}  hdnCache  <?xml version\="1.0" encoding\="UTF-8"?><exchange vsn\="1" action\="Response"><fault>null</fault><shpt action\=""><inv_typ>com</inv_typ><paperless>null</paperless><fault>null</fault><shpt_id>0</shpt_id><arbl_nbr>${airwayBillNumber}</arbl_nbr><arbl_nbr_edited>null</arbl_nbr_edited><prnt_alt_for_edited>YES</prnt_alt_for_edited><lbl_prnt_flg>NO</lbl_prnt_flg><totl_chrg>null</totl_chrg><sndr><fault>null</fault><user_id>${shipperid}</user_id><cust_nbr>${customer_number}</cust_nbr><third_pty_cust_nbr>null</third_pty_cust_nbr><sent_nam>FirstoD LastoD</sent_nam><phon_nbr>801-716-4720</phon_nbr><ca_nam>null</ca_nam><ca_phon_nbr>null</ca_phon_nbr><ca_email_addr>null</ca_email_addr><notify_default_user_flg>NO</notify_default_user_flg><emplr_id_typ_cd descr\="null">0</emplr_id_typ_cd><emplr_id_nbr>null</emplr_id_nbr><co_nam>Fundtech</co_nam><str_addr_1>5800 NW 39th AVE</str_addr_1><str_addr_2>null</str_addr_2><city_nam>Gainesville</city_nam><st_prvnc_cd>FL</st_prvnc_cd><postl_cd>32606</postl_cd><email_addr>firstoD.lastoD@fundtech.com</email_addr><reset_addr_flg>YES</reset_addr_flg><CanShipToOfacCountries><![CDATA[NO]]></CanShipToOfacCountries><RegisteredForPaperless><![CDATA[NO]]></RegisteredForPaperless><PaperlessDefInvTyp>null</PaperlessDefInvTyp><PaperlessDefInvMethod>0</PaperlessDefInvMethod><PaperlessDefCertOrgnMethod>0</PaperlessDefCertOrgnMethod><PaperlessGeneratedInvFlg><![CDATA[NO]]></PaperlessGeneratedInvFlg><PaperlessTermsConditionsFlg><![CDATA[NO]]></PaperlessTermsConditionsFlg><org_id>3</org_id><CanRegisterForPaperless><![CDATA[YES]]></CanRegisterForPaperless><CanPrepareITNRequestShpt><![CDATA[YES]]></CanPrepareITNRequestShpt><CanPrepareDeptStateShpt><![CDATA[NO]]></CanPrepareDeptStateShpt><show_mgn_box_flg>YES</show_mgn_box_flg><shpt_val_prtct_flg>YES</shpt_val_prtct_flg></sndr><save_sndr_addr>NO</save_sndr_addr><display_edit_addr>null</display_edit_addr><addr_chng_alowd>YES</addr_chng_alowd><shpt_dt>10/29/2014</shpt_dt><svc_typ_cd>1</svc_typ_cd><shpt_typ>5</shpt_typ><wt_cd>2</wt_cd><dims_len>10.1</dims_len><dims_wdth>5.8</dims_wdth><dims_hgt>5.9</dims_hgt><cstms_valu_amt>100</cstms_valu_amt><dutiable_flg><![CDATA[N]]></dutiable_flg><valu_amt>0</valu_amt><shpt_pkg_descr>Book</shpt_pkg_descr><shpt_ref_cd>null</shpt_ref_cd><show_ref_flg>NO</show_ref_flg><bill_to_typ_cd>4</bill_to_typ_cd><bill_to_cust_nbr>null</bill_to_cust_nbr><bill_duty_to_typ_cd>2</bill_duty_to_typ_cd><bill_duty_to_cust_nbr>null</bill_duty_to_cust_nbr><free_domcl_flg>YES</free_domcl_flg><ntfy_rcv_flg>NO</ntfy_rcv_flg><ntfy_othr_flg>NO</ntfy_othr_flg><othr_email_addr>null</othr_email_addr><ntfy_msg_txt>null</ntfy_msg_txt><cod_amt>null</cod_amt><cod_pmt_term_cd>null</cod_pmt_term_cd><hazmat_flg>NO</hazmat_flg><haa_flg>NO</haa_flg><creat_rcpt_flg>NO</creat_rcpt_flg><creat_ci_flg>NO</creat_ci_flg><creat_sed_flg>0</creat_sed_flg><ignored_err_list>null</ignored_err_list><is_ci_reqd>NO</is_ci_reqd><is_sed_reqd>NO</is_sed_reqd><is_ci_suprs>NO</is_ci_suprs><is_self_filing>NO</is_self_filing><void_flg>NO</void_flg><sav_to_prsnl_addr_flg>NO</sav_to_prsnl_addr_flg><ask_user_sed_quest>NO</ask_user_sed_quest><user_sed_choice>null</user_sed_choice><total_pieces>null</total_pieces><xtn>null</xtn><res_del_flg>YES</res_del_flg><type_pickup>0</type_pickup><pick_up_option>null</pick_up_option><pick_up_date>null</pick_up_date><pick_up_closetime>null</pick_up_closetime><pick_up_readytime>null</pick_up_readytime><pick_up_specilainstruction>null</pick_up_specilainstruction><nbr_of_pkp_pkgs>null</nbr_of_pkp_pkgs><est_pkp_wt>null</est_pkp_wt><pick_up_current_time>1109</pick_up_current_time><ca_creditcard_opt>0</ca_creditcard_opt><user_pickup_opt>4</user_pickup_opt><crdt_card_details><crdt_Card_nbr>null</crdt_Card_nbr><crdt_card_typ>null</crdt_card_typ><unique_id>null</unique_id><crdt_exp_dt>null</crdt_exp_dt></crdt_card_details><getfocus>null</getfocus><is_sed_frm_eef>NO</is_sed_frm_eef><cstms_valu_req_sed>2500</cstms_valu_req_sed><is_cntry_allow_aes4>YES</is_cntry_allow_aes4><ant_pu_dt>null</ant_pu_dt><ca_int_allow>True</ca_int_allow><eef_cstms_valu_amt>null</eef_cstms_valu_amt><ftr_cd>0</ftr_cd><pieces_flg>0</pieces_flg><sed action\="null"><fault>null</fault><emplr_id_typ_cd descr\="null"></emplr_id_typ_cd><emplr_id_nbr>null</emplr_id_nbr><itn_requested_emplr_id_typ_cd>0</itn_requested_emplr_id_typ_cd><prty_relt_flg>NO</prty_relt_flg><itarITN>null</itarITN><itarLic>null</itarLic><ultCntry>null</ultCntry><ultCsgn>null</ultCsgn><itn>null</itn><sed_id>null</sed_id><sed_filing_typ>null</sed_filing_typ><eef_login_id>null</eef_login_id><routed_export_txn>NO</routed_export_txn><ln_itms action\=""><totl>0</totl><totl_wt>0</totl_wt></ln_itms><ultCnsg>null</ultCnsg></sed><dept_state_shpt_flg>NO</dept_state_shpt_flg><prnt_nafta_flg>NO</prnt_nafta_flg><creat_cert_orgn_flg>NO</creat_cert_orgn_flg><request_landed_cost>null</request_landed_cost><orgn_stat_id>null</orgn_stat_id><dest_svc_area_cd>null</dest_svc_area_cd><orgn_svc_area_cd>null</orgn_svc_area_cd><svc_typ_descr>null</svc_typ_descr><wt_um_cd>1</wt_um_cd><package_typ>6</package_typ><insur_typ_cd>0</insur_typ_cd><insur_typ_cd_descr>null</insur_typ_cd_descr><bill_to_desc>null</bill_to_desc><bill_duty_to_desc>null</bill_duty_to_desc><stat_cd><![CDATA[P]]></stat_cd><src_cd>null</src_cd><trans_id>null</trans_id><crdt_Card_nbr>null</crdt_Card_nbr><pkp_cnfrm_nbr>null</pkp_cnfrm_nbr><unique_id>null</unique_id><shpt_for_focus_flg>YES</shpt_for_focus_flg><gbl_product_cd>D</gbl_product_cd><lcl_product_cd>null</lcl_product_cd><ofac_flg>NO</ofac_flg><paperless_flg><![CDATA[NO]]></paperless_flg><paperless_clr_typ>null</paperless_clr_typ><eco_status_cd>null</eco_status_cd><paperless_clr_archive_dt>null</paperless_clr_archive_dt><dce_itn>null</dce_itn><email_addr><![CDATA[firstoD.lastoD@fundtech.com]]></email_addr><sndr_nam>null</sndr_nam><sndr_addr_1>null</sndr_addr_1><sndr_addr_2>null</sndr_addr_2><sndr_dept_nam>null</sndr_dept_nam><sndr_city_nam>null</sndr_city_nam><sndr_st_prvnc_id>null</sndr_st_prvnc_id><sndr_postl_cd>null</sndr_postl_cd><sndr_cntry_id>100</sndr_cntry_id><sndr_cntry_nam><![CDATA[UNITED STATES]]></sndr_cntry_nam><sndr_regn_cd>1</sndr_regn_cd><rcvr><addr_id>null</addr_id><co_nam><![CDATA[Bright Light]]></co_nam><str_addr_1><![CDATA[1 Canterbury]]></str_addr_1><str_addr_2>null</str_addr_2><dept_nam><![CDATA[Suite 300]]></dept_nam><city_nam><![CDATA[CANTERBURY]]></city_nam><st_prvnc_cd><![CDATA[FL]]></st_prvnc_cd><postl_cd><![CDATA[CT1]]></postl_cd><cntry_id>412.1</cntry_id><regn_cd>4</regn_cd><cntry_nam><![CDATA[UNITED KINGDOM]]></cntry_nam><attn_nam><![CDATA[OtheroD]]></attn_nam><phon_nbr>18015551212</phon_nbr><email_addr><![CDATA[rcvrFirstoD.rcvrLastoD@fundtech.com]]></email_addr><ref_cd>null</ref_cd><note_txt>null</note_txt><prty_relt_flg>NO</prty_relt_flg><ctry_cd><![CDATA[GB]]></ctry_cd><suburb>null</suburb><rcvr_cust_nbr>null</rcvr_cust_nbr><third_pty_cust_nbr>null</third_pty_cust_nbr><addr_bk_typ>null</addr_bk_typ><ofac_restricted_ctry_flg><![CDATA[NO]]></ofac_restricted_ctry_flg><rcvr_postal_code_reqd_flg><![CDATA[YES]]></rcvr_postal_code_reqd_flg><rcvr_suburb_reqd_flg><![CDATA[NO]]></rcvr_suburb_reqd_flg><credit_card_restrict_flg><![CDATA[NO]]></credit_card_restrict_flg><third_party_restrict_flg><![CDATA[NO]]></third_party_restrict_flg><third_party_restrict_wt>0</third_party_restrict_wt><receiver_restrict_flg><![CDATA[NO]]></receiver_restrict_flg><paperless_cntry_flg><![CDATA[YES]]></paperless_cntry_flg><paperless_cntry_max_cstms_valu>9999999.99</paperless_cntry_max_cstms_valu></rcvr><is_itn_requested>NO</is_itn_requested><allow_prsnl_addr_bk>YES</allow_prsnl_addr_bk><neutral_dlvy_flg>NO</neutral_dlvy_flg><acct_supp_flg>NO</acct_supp_flg><is_demo_cust>NO</is_demo_cust><svc_cmpr_cd>NO</svc_cmpr_cd><shpt_ref_fld_lbl><![CDATA[Shipment Reference]]></shpt_ref_fld_lbl><ignore_warn_flg>NO</ignore_warn_flg><ca_paperless_allow>YES</ca_paperless_allow><ca_paperless_generated_inv_flg>YES</ca_paperless_generated_inv_flg><is_validate_address_requested>NO</is_validate_address_requested><ready_time>null</ready_time><check_receiver_address>YES</check_receiver_address><estimatedcharge>18.83</estimatedcharge><shpt_pces>null</shpt_pces><ci action\=""><fault/><is_first_visit/><tax_id/><pkg_mark_txt/><comt_txt/><ln_itms action\=""><totl/><totl_wt/></ln_itms><misc_chrgs><misc_chrg_1>com.fundtech.sbps.dhl.MiscChrg : 19654</misc_chrg_1><misc_chrg_2>com.fundtech.sbps.dhl.MiscChrg : 19655</misc_chrg_2><misc_chrg_3>com.fundtech.sbps.dhl.MiscChrg : 19656</misc_chrg_3><totl/></misc_chrgs><tot_typ_cd/><grnd_totl/><tot_typ_descr/></ci></shpt></exchange>
    ${resp}=  Post Request  dhlSession  /sbps/dhl/index   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>WebShip</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}

    Set To Dictionary  ${data}  accountAchAccountNumber= 
    Set To Dictionary  ${data}  accountAchActive=
    Set To Dictionary  ${data}  accountAchAuditUserId=
    Set To Dictionary  ${data}  accountAchDateCreated=
    Set To Dictionary  ${data}  accountAchDefault=
    Set To Dictionary  ${data}  accountAchExternalId=
    Set To Dictionary  ${data}  accountAchId=
    Set To Dictionary  ${data}  accountAchLastFour=
    Set To Dictionary  ${data}  accountAchLastUpdated=
    Set To Dictionary  ${data}  accountAchName=
    Set To Dictionary  ${data}  accountAchNameOnAccount=
    Set To Dictionary  ${data}  accountAchRoutingNumber=
    Set To Dictionary  ${data}  accountCardActive=
    Set To Dictionary  ${data}  accountCardAuditUserId=
    Set To Dictionary  ${data}  accountCardBillingCity=
    Set To Dictionary  ${data}  accountCardBillingCountry=
    Set To Dictionary  ${data}  accountCardBillingPostalCode=
    Set To Dictionary  ${data}  accountCardBillingState=
    Set To Dictionary  ${data}  accountCardBillingStreet1=
    Set To Dictionary  ${data}  accountCardBillingStreet2=
    Set To Dictionary  ${data}  accountCardCardNumber  4111111111111111
    Set To Dictionary  ${data}  accountCardCardType=
    Set To Dictionary  ${data}  accountCardDateCreated=
    Set To Dictionary  ${data}  accountCardDefault=
    Set To Dictionary  ${data}  accountCardExpiredDate=
    Set To Dictionary  ${data}  accountCardExternalId=
    Set To Dictionary  ${data}  accountCardId=
    Set To Dictionary  ${data}  accountCardLastFour  4111111111111111
    Set To Dictionary  ${data}  accountCardLastUpdated=
    Set To Dictionary  ${data}  accountCardName=
    Set To Dictionary  ${data}  accountCardNameOnCard  Robot Tester
    Set To Dictionary  ${data}  accountRemember  false
    Set To Dictionary  ${data}  customerActive=
    Set To Dictionary  ${data}  customerAuditUserId=
    Set To Dictionary  ${data}  customerBusinessName  Fundtech
    Set To Dictionary  ${data}  customerCity  Gainesville
    Set To Dictionary  ${data}  customerCountry=
    Set To Dictionary  ${data}  customerCustomDataFields=
    Set To Dictionary  ${data}  customerDateCreated=
    Set To Dictionary  ${data}  customerEmailAddress  firstyd.lastyd@fundtech.com
    Set To Dictionary  ${data}  customerExternalId  ${shipperid}
    Set To Dictionary  ${data}  customerFirstName  Firstyd
    Set To Dictionary  ${data}  customerId=
    Set To Dictionary  ${data}  customerLastName  Lastyd
    Set To Dictionary  ${data}  customerLastUpdated=
    Set To Dictionary  ${data}  customerPhoneNumber=
    Set To Dictionary  ${data}  customerPostalCode  32606
    Set To Dictionary  ${data}  customerSortOrder=
    Set To Dictionary  ${data}  customerState  FL
    Set To Dictionary  ${data}  customerStatus=
    Set To Dictionary  ${data}  customerStreet1  5800 Nw 39th Ave
    Set To Dictionary  ${data}  customerStreet2=
    Set To Dictionary  ${data}  customerTypeId=
    Set To Dictionary  ${data}  paymentAchAccountNumber=
    Set To Dictionary  ${data}  paymentAchAchBatchId=
    Set To Dictionary  ${data}  paymentAchAchFileId=
    Set To Dictionary  ${data}  paymentAchAchNsfReturnCount=
    Set To Dictionary  ${data}  paymentAchAchPaymentAccountId=   
    Set To Dictionary  ${data}  paymentAchAchReferenceNo=
    Set To Dictionary  ${data}  paymentAchAchReturnCode=
    Set To Dictionary  ${data}  paymentAchAchTrxId=
    Set To Dictionary  ${data}  paymentAchActive=
    Set To Dictionary  ${data}  paymentAchAmount=
    Set To Dictionary  ${data}  paymentAchAuditUserId=
    Set To Dictionary  ${data}  paymentAchAuditUserName=
    Set To Dictionary  ${data}  paymentAchBankAccountTypeId=
    Set To Dictionary  ${data}  paymentAchCustomDataFields=
    Set To Dictionary  ${data}  paymentAchDateCreated=
    Set To Dictionary  ${data}  paymentAchEffectiveDate= 
    Set To Dictionary  ${data}  paymentAchEmailNotes=
    Set To Dictionary  ${data}  paymentAchExternalId=
    Set To Dictionary  ${data}  paymentAchFee=
    Set To Dictionary  ${data}  paymentAchFeeScheduleId=
    Set To Dictionary  ${data}  paymentAchId=
    Set To Dictionary  ${data}  paymentAchInvoiceNumber=
    Set To Dictionary  ${data}  paymentAchLastUpdated=
    Set To Dictionary  ${data}  paymentAchName=
    Set To Dictionary  ${data}  paymentAchParentPaymentExternalId=
    Set To Dictionary  ${data}  paymentAchPaymentDate=
    Set To Dictionary  ${data}  paymentAchPointOfEntryId=
    Set To Dictionary  ${data}  paymentAchPoNumber=
    Set To Dictionary  ${data}  paymentAchProcessDate=
    Set To Dictionary  ${data}  paymentAchReportNotes=
    Set To Dictionary  ${data}  paymentAchReversedAmount=
    Set To Dictionary  ${data}  paymentAchReversedPayment= 
    Set To Dictionary  ${data}  paymentAchRoutingNumber=
    Set To Dictionary  ${data}  paymentAchScheduleId=
    Set To Dictionary  ${data}  paymentAchSecCode=
    Set To Dictionary  ${data}  paymentAchServiceClassCode=
    Set To Dictionary  ${data}  paymentAchSettlementDate=
    Set To Dictionary  ${data}  paymentAchSettlementEffectiveDate=
    Set To Dictionary  ${data}  paymentAchStatus=
    Set To Dictionary  ${data}  paymentAchStatusId=
    Set To Dictionary  ${data}  paymentAchTaxAmount=
    Set To Dictionary  ${data}  paymentAchTransactionCode=
    Set To Dictionary  ${data}  paymentAchTransactionTypeId=
    Set To Dictionary  ${data}  paymentCardActive=
    Set To Dictionary  ${data}  paymentCardAddressVerificationResult=
    Set To Dictionary  ${data}  paymentCardAmount  575.63
    Set To Dictionary  ${data}  paymentCardAuditUserId=
    Set To Dictionary  ${data}  paymentCardAuditUserName=
    Set To Dictionary  ${data}  paymentCardAuthCode=
    Set To Dictionary  ${data}  paymentCardCardId=
    Set To Dictionary  ${data}  paymentCardCardPaymentAccountId=
    Set To Dictionary  ${data}  paymentCardCardPaymentStatus=
    Set To Dictionary  ${data}  paymentCardCardPaymentStatusId= 
    Set To Dictionary  ${data}  paymentCardCardVerificationResult=
    Set To Dictionary  ${data}  paymentCardCpgBatchId=
    Set To Dictionary  ${data}  paymentCardCpgItemNumber=
    Set To Dictionary  ${data}  paymentCardCpgItemTimestamp=
    Set To Dictionary  ${data}  paymentCardCpgPcRiskLevel=
    Set To Dictionary  ${data}  paymentCardCpgPnrefId=
    Set To Dictionary  ${data}  paymentCardCpgProcResponse=
    Set To Dictionary  ${data}  paymentCardCpgResultId=
    Set To Dictionary  ${data}  paymentCardCustomDataFields  [{airwayBillNumbers:'${airwayBillNumber}'}]
    Set To Dictionary  ${data}  paymentCardCustomerReferenceNumber=
    Set To Dictionary  ${data}  paymentCardCvv  1111
    Set To Dictionary  ${data}  paymentCardDateCreated=
    Set To Dictionary  ${data}  paymentCardDestinationCountryCode=
    Set To Dictionary  ${data}  paymentCardDestinationPostalCode=
    Set To Dictionary  ${data}  paymentCardDiscountAmount=
    Set To Dictionary  ${data}  paymentCardDutyAmount=  
    Set To Dictionary  ${data}  paymentCardEmailNotes=
    Set To Dictionary  ${data}  paymentCardExpirationDate  11/23
    Set To Dictionary  ${data}  paymentCardExternalId=
    Set To Dictionary  ${data}  paymentCardFee=
    Set To Dictionary  ${data}  paymentCardFeeScheduleId=
    Set To Dictionary  ${data}  paymentCardFreightAmount=
    Set To Dictionary  ${data}  paymentCardId=
    Set To Dictionary  ${data}  paymentCardInvoiceNumber=
    Set To Dictionary  ${data}  paymentCardLastUpdated=
    Set To Dictionary  ${data}  paymentCardLevel3Items=
    Set To Dictionary  ${data}  paymentCardNameOnCard=
    Set To Dictionary  ${data}  paymentCardOrderNumber=
    Set To Dictionary  ${data}  paymentCardParentCardPaymentExternalId=
    Set To Dictionary  ${data}  paymentCardPaymentDate=
    Set To Dictionary  ${data}  paymentCardPointOfEntryId=
    Set To Dictionary  ${data}  paymentCardPoNumber=
    Set To Dictionary  ${data}  paymentCardReportNotes=
    Set To Dictionary  ${data}  paymentCardReversedAmount=
    Set To Dictionary  ${data}  paymentCardScheduleId=
    Set To Dictionary  ${data}  paymentCardTaxAmount=
    Set To Dictionary  ${data}  paymentCardTransactionTypeId=
    Set To Dictionary  ${data}  urlBack  http://172.16.225.252:8001/sbpsRefPortal/webShipData/save
    Set To Dictionary  ${data}  urlFail=
    Set To Dictionary  ${data}  urlSucceed=
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]} 
    ${resp}=  Post Request  dhlSession  /sbps/dhl/submitPayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    #force the payment using the API
    Wait Until Keyword Succeeds  3 min  10 sec  Find Webship Payment  ${airwayBillNumber}

Call Print and Post - Simulates a user selecting 'Pay Now' on the DHL
    [Tags]    DHL
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.com
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://172.16.225.252:8001/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  extraToken  extraToken
    Set To Dictionary  ${data}  signature   ${signature}
    Set To Dictionary  ${data}  payload  <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstmqgMYnbD</FirstName><LastName>LastmqgMYnbD</LastName><BusinessName>LastmqgMYnbD's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstmqgMYnbD.LastmqgMYnbD@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>2102809917 P 1 43.31</AmexTaa1><AmexTaa2>mqgMYnbD1661800012</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP552199 PP552199</AmexTaa4><Amount>43.31</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>67710516</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>PrintPost</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstqVfEqMbqMKgXxUxo</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastqVfEqMbqMKgXxUxo</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>mqgMYnbD1661800012</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>43.31</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>91255974</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>48178127</CommodityCode><ProductDescription>2102809917</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>43.31</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>2102809917</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>43.31</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>mqgMYnbD1661800012</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200

	
Call Print and Post - Simulates a user Submit CC payment selecting 'Submit' on the DHL
    [Tags]    DHL
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS]
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=13   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@dh.com
    ${account_ACH_NameOn}=  Generate Random String  length=10  chars=[LETTERS]
    ${account_ACH_Number}=  Generate Random String  length=12  chars=[NUMBERS]
    ${EBPPBatchID}=   Generate Random String  length=8  chars=[NUMBERS]
    ${account_Card_NameOnCard}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}  Create Dictionary  create  Send
    Set To Dictionary  ${data}   create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/failure?callback\=failure" returnUrl\="http://172.16.225.252:8001/sbpsRefPortal/printAndPost/save" successUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/success?callback\=success" xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstOHTxOFFQ</FirstName><LastName>LastOHTxOFFQ</LastName><BusinessName>${BusinessName}</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstOHTxOFFQ.LastOHTxOFFQ@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>${airwayBillNumber} P 1 761.75</AmexTaa1><AmexTaa2>${airwayBillNumber}</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP295274 PP295274</AmexTaa4><Amount>761.75</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>${EBPPBatchID}</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>PrintPost</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>${airwayBillNumber}</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>761.75</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>${InvoiceNumber}</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>10300955</CommodityCode><ProductDescription>${airwayBillNumber}</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>761.75</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>${airwayBillNumber}</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>761.75</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>${airwayBillNumber}</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    Set To Dictionary  ${data}   invoice                           ${BusinessName}
    Set To Dictionary  ${data}   invoice                           ${ExternalId}
    Set To Dictionary  ${data}   invoice                           987.16
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${InvoiceNumber}
    Set To Dictionary  ${data}   customerEmailAddress              ${EmailID}@example.com
    Set To Dictionary  ${data}   accountCardNameOnCard             ${account_Card_NameOnCard}
    Set To Dictionary  ${data}   accountCardCardNumber             5454545454545454
    Set To Dictionary  ${data}   paymentCardCvv                    111
    Set To Dictionary  ${data}   paymentCardExpirationDate         11/20
    Set To Dictionary  ${data}   paymentCardAmount                 987.16
    Set To Dictionary  ${data}   paymentCardCardPaymentStatus      PreAuthorized
    Set To Dictionary  ${data}   paymentCardPaymentDate            ${today}
    Set To Dictionary  ${data}   accountCardBillingStreet1         test1
    Set To Dictionary  ${data}   accountCardBillingCity            test
    Set To Dictionary  ${data}   accountCardBillingState           AL
    Set To Dictionary  ${data}   accountCardBillingPostalCode      14785
    Set To Dictionary  ${data}   browserTabId   ${browser_tab_id[0]}

    ${resp}=  Post Request  dhlSession  sbps/printPost/submitPayment    data=${data}  headers=${headers}
    Log   ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true


Call Print and Post - Simulates a user Creating ACH payment selecting 'Submit' on the DHL
    [Tags]    DHL
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS]
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=13   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@dh.com
    ${account_ACH_NameOn}=  Generate Random String  length=10  chars=[LETTERS]
    ${account_ACH_Number}=  Generate Random String  length=12  chars=[NUMBERS]
    ${EBPPBatchID}=   Generate Random String  length=8  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}  Create Dictionary  create  Send
    Set To Dictionary  ${data}   create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/failure?callback\=failure" returnUrl\="http://172.16.225.252:8001/sbpsRefPortal/printAndPost/save" successUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/success?callback\=success" xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstOHTxOFFQ</FirstName><LastName>LastOHTxOFFQ</LastName><BusinessName>${BusinessName}</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstOHTxOFFQ.LastOHTxOFFQ@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>${airwayBillNumber} P 1 761.75</AmexTaa1><AmexTaa2>${airwayBillNumber}</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP295274 PP295274</AmexTaa4><Amount>761.75</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>${EBPPBatchID}</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>PrintPost</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>${airwayBillNumber}</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>761.75</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>${InvoiceNumber}</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>10300955</CommodityCode><ProductDescription>${airwayBillNumber}</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>761.75</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>${airwayBillNumber}</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>761.75</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>${airwayBillNumber}</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    &{data}  Create Dictionary   invoice                           ${BusinessName}
    Set To Dictionary  ${data}   invoice                           ${InvoiceNumber}
    Set To Dictionary  ${data}   invoice                           987.16
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${ExternalId}
    Set To Dictionary  ${data}   customerEmailAddress              FirstsWxZKXHz.LastsWxZKXHz@example.com
    Set To Dictionary  ${data}   accountAchNameOnAccount           ${account_ACH_NameOn}
    Set To Dictionary  ${data}   accountAchRoutingNumber           011000015
    Set To Dictionary  ${data}   accountAchAccountNumber           ${account_ACH_Number}
    Set To Dictionary  ${data}   accountAchBankAccountType         Savings
    Set To Dictionary  ${data}   paymentAchAmount                  987.16
    Set To Dictionary  ${data}   paymentAchStatus                  PreAuthorized
    Set To Dictionary  ${data}   paymentAchPaymentDate            ${today}
    Set To Dictionary  ${data}   browserTabId  ${browser_tab_id[0]}
    ${resp}=  Post Request  dhlSession  /sbps/printPost/submitPayment    data=${data}  headers=${headers}
    Log   ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
	
Create AutoPay ACH Mywallet and Simulates a user to selecting 'Add New Account'on the DHL
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary   extraToken   extraToken
    &{data}=  Create Dictionary   signature   ${signature}
    Set To Dictionary  ${data}   payload:   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstTijpRFrj</FirstName><LastName>LastTijpRFrj</LastName><BusinessName>LastTijpRFrj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstTijpRFrj.LastTijpRFrj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType        Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount        ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname             ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                  ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                  ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${data}  Create Dictionary  csrfToken              ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountId    ${accountAchAccountId}
    Set To Dictionary  ${data}  customer_id            ${accountCardId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
	
Create AutoPay Credit Card Mywallet and Simulates a user to selecting 'Add New Account'on the DHL
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary   extraToken   extraToken
    &{data}=  Create Dictionary   signature   ${signature}
    Set To Dictionary  ${data}   payload:   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstTijpRFrj</FirstName><LastName>LastTijpRFrj</LastName><BusinessName>LastTijpRFrj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstTijpRFrj.LastTijpRFrj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    Set To Dictionary  ${data}  accountCardBillingCity             Pune
    Set To Dictionary  ${data}  accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}  accountCardBillingState            CA
    Set To Dictionary  ${data}  accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}  accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}  accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}  accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  paymentCardExpirationDate          11/20
    Set To Dictionary  ${data}  userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id      ${cc_created_customer_id}
    Set To Dictionary  ${data}  accountCardId    ${accountCardId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
	
Add AutoPay ACH and Credit Card Mywallet and Simulates a user to selecting 'Add New Account' to Add 'ACH and CC Wallet' on the DHL    

    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary   extraToken   extraToken
    &{data}=  Create Dictionary   signature   ${signature}
    Set To Dictionary  ${data}   payload:   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstTijpRFrj</FirstName><LastName>LastTijpRFrj</LastName><BusinessName>LastTijpRFrj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstTijpRFrj.LastTijpRFrj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType        Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount         ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname              ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                   ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                   ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    Set To Dictionary  ${data}  accountCardBillingCity             Pune
    Set To Dictionary  ${data}  accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}  accountCardBillingState            CA
    Set To Dictionary  ${data}  accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}  accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}  accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}  accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  paymentCardExpirationDate          11/20
    Set To Dictionary  ${data}  userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
	
Select AutoPay ACH account as schedule wallet Simulates a user to selecting 'EDIT' on the DHL
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary   extraToken   extraToken
    &{data}=  Create Dictionary   signature   ${signature}
    Set To Dictionary  ${data}   payload:   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstTijpRFrj</FirstName><LastName>LastTijpRFrj</LastName><BusinessName>LastTijpRFrj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstTijpRFrj.LastTijpRFrj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType        Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount        ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname             ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                  ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                  ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    Set To Dictionary  ${data}  accountCardBillingCity             Pune
    Set To Dictionary  ${data}  accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}  accountCardBillingState            CA
    Set To Dictionary  ${data}  accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}  accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}  accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}  accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  paymentCardExpirationDate          11/20
    Set To Dictionary  ${data}  userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
	
	${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id      ${cc_created_customer_id}
    Set To Dictionary  ${data}  accountCardId    ${accountCardId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  adminSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
     
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountId   ${accountAchAccountId}
    Set To Dictionary  ${data}  scheduleId           ${scheduleId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xEditPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
Select AutoPay Credit Card account as schedule wallet Simulates a user to selecting 'EDIT' on the DHL
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary   extraToken   extraToken
    &{data}=  Create Dictionary   signature   ${signature}
    Set To Dictionary  ${data}   payload:   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstTijpRFrj</FirstName><LastName>LastTijpRFrj</LastName><BusinessName>LastTijpRFrj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstTijpRFrj.LastTijpRFrj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType        Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount        ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname             ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                  ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                  ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    Set To Dictionary  ${data}  accountCardBillingCity             Pune
    Set To Dictionary  ${data}  accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}  accountCardBillingState            CA
    Set To Dictionary  ${data}  accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}  accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}  accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}  accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  paymentCardExpirationDate          11/20
    Set To Dictionary  ${data}  userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
	
	${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  accountAchAccountId   ${accountAchAccountId}
    Set To Dictionary  ${data}  scheduleId           ${scheduleId}
    
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
     
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id      ${cc_created_customer_id}
    Set To Dictionary  ${data}  accountCardId    ${accountCardId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xEditPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Call Ebilling - Simulates a user create ACH payment account and Submit ACH payment by selecting 'Submit' on the DHL
    [Tags]    DHL
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${ExternalId1}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.com
    ${accountAchNickname}=  Generate Random String  length=6  chars=[LETTERS]
    ${accountAchAccountNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${accountAchNameOnAccount}=  Generate Random String  length=6  chars=[LETTERS
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary  extraToken  extraToken
    &{data}=  Create Dictionary  signature   ${signature}
    Set To Dictionary  ${data}   payload:  <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstGMDubCUd</FirstName><LastName>LastGMDubCUd</LastName><BusinessName>LastGMDubCUd's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstGMDubCUd.LastGMDubCUd@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>1138704537 P 1 224.44</AmexTaa1><AmexTaa2>GMDubCUd1187251706</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP746083 PP746083</AmexTaa4><Amount>224.44</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>GMDubCUd1187251706</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>224.44</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>20889759</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>62499289</CommodityCode><ProductDescription>1138704537</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>224.44</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1138704537</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>224.44</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>GMDubCUd1187251706</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment><Payment><AmexTaa1>1623552377 P 1 194.44</AmexTaa1><AmexTaa2>GMDubCUd1874377512</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP746083 PP746083</AmexTaa4><Amount>194.22</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>GMDubCUd1874377512</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>194.22</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>20889759</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>62499289</CommodityCode><ProductDescription>1623552377</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>194.22</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1138704537</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>194.22</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>GMDubCUd1874377512</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment><CustomerAccountPayment><Customer><ExternalId>${ExternalId1}</ExternalId><FirstName>FirstzFAHlRsG</FirstName><LastName>LastzFAHlRsG</LastName><BusinessName>LastzFAHlRsG's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstzFAHlRsG.LastzFAHlRsG@example.com</EmailAddress><CustomDataFields/><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>1867332122 P 1 514.66</AmexTaa1><AmexTaa2>zFAHlRsG1774755531</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP307846 PP307846</AmexTaa4><Amount>514.66</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>zFAHlRsG1774755531</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>514.66</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>56760281</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>56488605</CommodityCode><ProductDescription>1867332122</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>514.66</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1867332122</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>514.66</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>zFAHlRsG1774755531</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><T6axAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment><Payment><AmexTaa1>1376850522 P 1 576.66</AmexTaa1><AmexTaa2>zFAHlRsG1114081642</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP307846 PP307846</AmexTaa4><Amount>576.88</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>zFAHlRsG1114081642</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>576.88</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>56760281</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>56488605</CommodityCode><ProductDescription>1376850522</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>576.88</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1867332122</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>576.88</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>zFAHlRsG1114081642</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    
    Set To Dictionary  ${data}  accountAchAccountNumber= ${accountAchAccountNumber}
    Set To Dictionary  ${data}  accountAchBankAccountType= Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount= ${accountAchNameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname= ${accountAchNickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber= 011000015
    Set To Dictionary  ${data}  customerEmailAddress= ${EbppUserName}
    Set To Dictionary  ${data}  oboEmailAddress= ${EbppUserName}
    Set To Dictionary  ${data}  userEmailAddress= ${EbppUserName}
    Set To Dictionary  ${data}  accountDigits= ${accountAchAccountNumber}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]} 
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount   data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${accountAchAccountId}=  Get Regexp Matches  ${resp.content}  paymentAccount_id":"?(.*?)"?,  1
    Log  ${accountAchAccountId}
    Set Suite Variable  \${accountAchAccountId}  ${accountAchAccountId}

    Set To Dictionary  ${data}  accountAchAccountId= ${accountAchAccountId}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]} 
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xSubmitInvoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    
    
Call Ebilling - Simulates a user create CC payment account and Submit CC payment by selecting 'Submit' on the DHL
    [Tags]    DHL
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${ExternalId1}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.com
    ${accountCardNickname}=  Generate Random String  length=6  chars=[LETTERS]
    ${accountCardNameOnCard}=  Generate Random String  length=6  chars=[LETTERS]
    ${EmailIDs}=    Generate Random String    length=8   chars=[LETTERS]
    ${domains}=    Generate Random String    length=5   chars=[LETTERS]
    ${customerEmailAddress}=     Set Variable    ${EmailIDs}@${domains}.com
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk
    &{data}=  Create Dictionary  create  Send
    &{data}=  Create Dictionary  extraToken  extraToken
    &{data}=  Create Dictionary  signature   ${signature}
    Set To Dictionary  ${data}   payload:  <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstGMDubCUd</FirstName><LastName>LastGMDubCUd</LastName><BusinessName>LastGMDubCUd's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstGMDubCUd.LastGMDubCUd@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>1138704537 P 1 224.44</AmexTaa1><AmexTaa2>GMDubCUd1187251706</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP746083 PP746083</AmexTaa4><Amount>224.44</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>GMDubCUd1187251706</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>224.44</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>20889759</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>62499289</CommodityCode><ProductDescription>1138704537</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>224.44</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1138704537</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>224.44</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>GMDubCUd1187251706</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment><Payment><AmexTaa1>1623552377 P 1 194.44</AmexTaa1><AmexTaa2>GMDubCUd1874377512</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP746083 PP746083</AmexTaa4><Amount>194.22</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastgjdRZVoWJEOKZWQk</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>GMDubCUd1874377512</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>194.22</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>20889759</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>62499289</CommodityCode><ProductDescription>1623552377</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>194.22</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1138704537</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>194.22</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>GMDubCUd1874377512</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment><CustomerAccountPayment><Customer><ExternalId>${ExternalId1}</ExternalId><FirstName>FirstzFAHlRsG</FirstName><LastName>LastzFAHlRsG</LastName><BusinessName>LastzFAHlRsG's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstzFAHlRsG.LastzFAHlRsG@example.com</EmailAddress><CustomDataFields/><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>1867332122 P 1 514.66</AmexTaa1><AmexTaa2>zFAHlRsG1774755531</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP307846 PP307846</AmexTaa4><Amount>514.66</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>zFAHlRsG1774755531</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>514.66</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>56760281</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>56488605</CommodityCode><ProductDescription>1867332122</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>514.66</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1867332122</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>514.66</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>zFAHlRsG1774755531</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><T6axAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment><Payment><AmexTaa1>1376850522 P 1 576.66</AmexTaa1><AmexTaa2>zFAHlRsG1114081642</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP307846 PP307846</AmexTaa4><Amount>576.88</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>41451814</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastZXaYuZChEYdtNBnA</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>zFAHlRsG1114081642</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>576.88</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>56760281</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>56488605</CommodityCode><ProductDescription>1376850522</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>576.88</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1867332122</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>576.88</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>zFAHlRsG1114081642</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    Should Contain  ${resp.content}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    
    Set To Dictionary  ${data}  accountCardBillingCity= Gainesville
    Set To Dictionary  ${data}  accountCardBillingPostalCode= 32606
    Set To Dictionary  ${data}  accountCardBillingState= FL
    Set To Dictionary  ${data}  accountCardBillingStreet1= 5800 NW 39th AVE
    Set To Dictionary  ${data}  accountCardCardNumber= 5454545454545454
    Set To Dictionary  ${data}  accountCardNameOnCard= ${accountCardNameOnCard}
    Set To Dictionary  ${data}  accountCardNickname= ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress= ${customerEmailAddress}
    Set To Dictionary  ${data}  oboEmailAddress= ${customerEmailAddress}
    Set To Dictionary  ${data}  paymentCardExpirationDate= 11/28
    Set To Dictionary  ${data}  userEmailAddress= ${customerEmailAddress}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]} 
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount   data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${accountCardId}  Get Regexp Matches  ${resp.content}  paymentAccount_id":"?(.*?)"?,  1
    Log  ${accountCardId}
    Set Suite Variable  \${accountCardId}  ${accountCardId}
    
    Set To Dictionary  ${data}  accountCardId= ${accountCardId}
    Set To Dictionary  ${data}  paymentCardCvv= 1111
    Set To Dictionary  ${data}  paymentCardExpirationDate= 11/28
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]} 
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xSubmitInvoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true