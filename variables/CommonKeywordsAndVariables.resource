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

*** Keywords ***
Setup Test Suite
    ${today}=  Get Current Date  result_format=%m/%d/%Y
    Set Suite Variable  \${today}  ${today}
    Log Variables
    #not working yet
    ${testServerRequested}=    Run Keyword If  '${testServer}'=='NO_ENVIRONMENT_SELECTED'  Get Selection From User
    ...    Select the desired test environment and press OK.
    ...    AzureCustint    AzureDevint   AzurePerformanceEngineering  AzureQA  Local   
    Run Keyword If  '${testServer}'=='NO_ENVIRONMENT_SELECTED'  Set Suite Variable  \${testServer}  ${testServerRequested}  
    Import Resource    ${CURDIR}/TotalTransact/../../variables/${testServer}-environment.resource
    Set Suite Variable  \${testServer}  ${testServer}
    Log To Console  Selected test environment is ${testServer}
    Reset User Password  ${username}  ${password_hash}
    Reset User Password  ${admin_username}  ${admin_password_hash}
    Reset User Password  ${dhl_username}  ${dhl_password_hash}
    Create Sessions
    Log Variables

Teardown Test Suite
     Run Keyword If  '${browser}'=='Firefox' and '${enable_burp_proxy}'=='true'  Remove Directory  ${profile_path}  recursive=True
     Close Browser

Create Sessions
    Set Log Level  debug
    Delete All Sessions
    ${proxies}=  Create Dictionary  http=localhost:8080  https=localhost:8080
    Run Keyword If  '${enable_burp_proxy}'=='true'  Create Session  regularSession  ${url}  debug=3  proxies=${proxies}
    Run Keyword Unless  '${enable_burp_proxy}'=='true'  Create Session  regularSession  ${url}  debug=3 
    Run Keyword If  '${enable_burp_proxy}'=='true'  Create Session  adminSession  ${url}  debug=3  proxies=${proxies}
    Run Keyword Unless  '${enable_burp_proxy}'=='true'  Create Session  adminSession  ${url}  debug=3 
    Run Keyword If  '${enable_burp_proxy}'=='true'  Create Session  dhlSession  ${url}  debug=3  proxies=${proxies}
    Run Keyword Unless  '${enable_burp_proxy}'=='true'  Create Session  dhlSession  ${url}  debug=3 
    
Reset User Password
    [Arguments]  ${username_to_reset}  ${password_hash_to_reset}
    ${resetPasswordCommand}=  Set Variable  (echo update users set password = '${password_hash_to_reset}', user_status_id = 2 where name like '${username_to_reset}'; & echo commit;) | sqlplus -s ${db_ls_schema_name}/ls@${db_host}:${db_port}/${db_service} 
    Log  ${resetPasswordCommand}
    ${rc}=  Run And Return Rc  ${resetPasswordCommand}
    Log  ${rc}
    
Pretty Print 
    [Arguments]  ${output}
    ${pretty_output}=  Run Keyword and Ignore Error  To Json    ${output}    pretty_print=True
    Run Keyword If  '${pretty_output[0]}'=='FAIL'  Log    ${output}
    Run Keyword If  '${pretty_output[0]}'=='PASS'  Log    ${pretty_output[1]}

Login To Payment Portal
    [Arguments]  ${local_username}  ${local_password}
    &{data}=  Create Dictionary  username=${local_username}  password=${local_password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/
    ${resp}=  POST Request  regularSession  /sbps/login/authenticate  data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #verify the cache prevention headers are present
    Dictionary Should Contain Item  ${resp.headers}  Cache-Control  no-cache, no-store, max-age=0, must-revalidate
    Dictionary Should Contain Item  ${resp.headers}  Pragma  no-cache
    
Login To Payment Portal CI Environment
    [Arguments]  ${local_username}  ${local_password}
    &{data}=  Create Dictionary  username=${local_username}  password=${local_password}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  POST Request  regularSession  /sbps/login/authenticate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #verify the cache prevention headers are present
    Dictionary Should Contain Item  ${resp.headers}  Cache-Control  no-cache, no-store, max-age=0, must-revalidate
    Dictionary Should Contain Item  ${resp.headers}  Pragma  no-cache

Logout
    ${resp}=  Get Request  adminSession  /sbps/logoff
    Should Contain  ${resp.content.decode('utf-8')}  Password
    
Logout CI Environment
    ${resp}=  Get Request  adminSession  /sbps/j_spring_security_logout
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  Password

Read Account Location
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/
    ${resp}=  Post Request  regularSession  /sbps/accountLocation/xRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true  
    ${processing_account_id}  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountlocations[?(@.accountlocationname=='${processing_account_search_string}')].id
    Log  ${processing_account_id}
    Set Suite Variable  \${processing_account_id}  ${processing_account_id}

Create API Key
    ${api_key}=  Generate Random String  length=10  chars=[LETTERS]
    ${data}  Create Dictionary   name  ${api_key} 
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/
    ${resp}=  Post Request  regularSession  /sbps/settings/xCreateApiKey  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true  
    ${api_key}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "apikey":"(.*?)","  1
    ${api_key_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "prcacctapiid":"?(.*?)"?,"  1                                               
    Log  ${api_key[0]}
    Set Suite Variable  \${api_key}  ${api_key[0]}   
    Log  ${api_key_id[0]}
    Set Suite Variable  \${api_key_id}  ${api_key_id[0]}  

Connect database
    Connect To Database   cx_Oracle    ${db_service}    ${db_base_schema_name}   ${db_base_schema_password}    ${db_Host}    ${db_Port}
    Log to Console    Connected to Database
    
Disconnect database
    Disconnect From Database
    Log to Console    Disconnected from Database 

*** Variables ***
${enable_burp_proxy}                            false 
${reseller_search_string}=                      Topaz Reseller
${account_search_string}=                       Downtown
${gateway_profile_search_string}=               ptest
${card_processor_search_string}=                CYBERSOURCE
${card_institution_search_string}=              FDC Compass
${compName}=                                    Total Transact
${appName}                                      SBPS
${admin_appName}                                ADMIN
${time_zone_search_string}=                     (-10:00) Hawaii
${country_search_string}=                       United States
${endpoint_search_string}=                      Topaz Reseller
${testServer}=                                  NO_ENVIRONMENT_SELECTED
${session_id}=                                  SESSION_ID_NOT_FOUND
${ach_created_customer_id}=                     ACH_CREATED_CUSTOMER_ID_NOT_FOUND 
${cc_created_customer_id}=                      CC_CREATED_CUSTOMER_ID_NOT_FOUND
${processing_account_id}=                       PROCESSING_ACCOUNT_ID_NOT_FOUND
${cc_processor_based_failure_amount}=           5
${api_key}=                                     API_KEY_NOT_FOUND
${api_key_name}=				                API_KEY_NAME_NOT_FOUND
${api_key_id}=                                  API_KEY_ID_NOT_FOUND
${merchant__org_id}=                            merchant__org_id_NOT_FOUND
${merchant_merchant_id}=                        merchant_merchant_id_NOT_FOUND
${merchant_external_id}=                        merchant_external_id_NOT_FOUND
${cc_pmt_acct_id}=                              CC_PAYMENT_ACCOUNT_ID_NOT_FOUND
${ach_pmt_acct_id}=                             ACH_PAYMENT_ACCOUNT_ID_NOT_FOUND
${fee_schedule_id}=                             FEE_SCHEDULE_ID_NOT_FOUND
${zero_fee_schedule_id}=                        ZERO_FEE_SCHEDULE_ID_NOT_FOUND
${payment_id}=                                  PAYMENT_ID_NOT_FOUND
${payment_schedule_id}=                         PAYMENT_SCHEDULE_ID_NOT_FOUND
${payment_external_id}=                         PAYMENT_EXTERNAL_ID_NOT_FOUND
${alert_id}=                                    ALERT_ID_NOT_FOUND
${today}=                                       NULL
${custom_field_name}=                           CUSTOM_FIELD_NAME
${custom_field_id}=                             CUSTOM_FIELD_ID
${processing_account_email_type_id}=            PROCESSING_ACCOUNT_EMAIL_TYPE_ID
${processing_account_email_type_search_str}=    CHANGE_NEXT_PAYMENT_DATE_EMAILS
${fee_schedule_name}=                           FEE_SCHEDULE_NAME
${accountAchAccountId}=                         PROCESSING_ACCOUNT_ID_NOT_FOUND
${accountCardId}=                               SIGNATURE_ID_NOT_FOUND
${scheduleId}=                                  SIGNATURE_ID_NOT_FOUND
#dummy signature, this needs to be computed for a valid test
${signature}=                                   ODI4MjA2MTN8MjAxOC0xMS0zMCAwNzowNjowNyBVVEN8aGREZFZWaUxLdEx3aXpxckBmdW5kdGVjaC5jb218OTYyYTcwMTZmYWEwYTI4ZjNiYzM3NDNhZGU0NzFmNzM0Y2U4MA\=\=
${BusinessName}=                                BUSINESS_NAME_NOT_FOUND
${api_processing_account_id}=                   API_PROCESSING_ACCOUNT_ID_NOT_FOUND
${reseller_id}=                                 RESELLER_ID_NOT_FOUND
${merchant_id}=                                 MERCHANT_ID_NOT_FOUND
${external_id}=                                 EXTERNAL_ID_NOT_FOUND
${card_processor_id}=                           CARD_PROCESSOR_ID_NOT_FOUND
${country_id}=                                  COUNTRY_ID_NOT_FOUND
${timezone_id}=                                 TIMEZONE_ID_NOT_FOUND
${gateway_profiles_id}=                         GATEWAY_PROFILE_ID_NOT_FOUND
${alert_id}=                                    ALERT_ID_NOT_FOUND
${endpoint_id}=                                 ENDPOINT_ID_NOT_FOUND
${account_location_id}=                         ACCOUNT_LOCATION_ID_NOT_FOUND
${processing_account_location_id}=              ACCOUNT_LOCATION_ID_NOT_FOUND
${acount_location_name_uniqueifier}=            ACCOUNT_LOCATION_UNIQUEIFIER_NOT_FOUND
${profile_id}=                                  PROFILE_ID_NOT_FOUND
${today}=                                       Get Current Date result_format=%m/%d/%Y
${today} =    Subtract Time From Date    ${today}    10d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
${yesterday}=    Subtract Time From Date    ${today}    1d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
${successflag}
${BankAccountType}=                             BankAccountType_NOT_FOUND
${ApiKeyName}=                                  ApiKeyName_NOT_FOUND
${Amount}=                                      Amount_NOT_FOUND
${Userid}=                                      Userid_NOT_FOUND
${OrganizationTypeid}=                          OrganizationType id_FOUND
${customerid}=                                  OrganizationType id_FOUND
${customer_name_random_part}=                   CUSTOMER_NAME_RANDOM_PART_NOT_FOUND
${air_way_bill_number}=                         AIRWAY_BILL_NUMBER_NOT_FOUND
${zero_fee_schedule_name}=                      Zero Fee Schedule
${zero_fee_schedule_name_upper}=                ZERO FEE SCHEDULE
${reset_username}                               USER NAME
${reset_password}                               PASSWORD
${first_name}                                   FIRST NAME
${last_name}                                    LAST NAME
${user_search_string}                           tsodamerchant