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
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/home/xPaymentStatusSubmittedRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}  true
Retrieve Merchant List (version > 2.4 only)
    ${data}=  Create Dictionary  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/header/xRetrieveMerchantList  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${merchant__org_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "${merchant_search_string}","orgId":"?(.*?)"?,  1
    Log  ${merchant__org_id}
    Set Suite Variable  \${merchant__org_id}  ${merchant__org_id[0]}
    ${merchant_merchant_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "${merchant_search_string}".*?,"merchantId":"?(.*?)"?,  1
    Log  ${merchant_merchant_id}
    Set Suite Variable  \${merchant_merchant_id}  ${merchant_merchant_id[0]}  
    ${merchant_external_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "${merchant_search_string}".*?,"externalId":"?(.*?)"?,  1
    Log  ${merchant_external_id}
    Set Suite Variable  \${merchant_external_id}  ${merchant_external_id[0]}  
Update Merchant (version > 2.4 only)
    ${data}  Create Dictionary  orgId  ${merchant__org_id}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/header/xUpdateMerchant  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
*** Test Cases ***
Authenticate to the Server
    [Tags]    Smoke
    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    
Check error page doesn't contain user input
	&{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/accountLocation/xReadMasterCardValidationmpw9uytofq   data=${data}  headers=${headers}
    Should Not Contain  ${resp.text}  mpw9uytofq
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
Application Header
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/header/xGenerateHeaderJsonData  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${companyName}=  Get Items By Path  ${resp.content}  $..companyname
    Should Be Equal   ${companyName}   ${compName}
Read App Name
    &{data}=  Create Dictionary   csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/navNavigationItem/xGenerate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${applicationName}=  Get Items By Path  ${resp.content}  $..appName
    Should Be Equal  ${applicationName}  ${appName}  
Application Sidebar
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/sidebar/xGenerateSidebarJsonData  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${collapsible}=  Get Items By Path  ${resp.content}  $..collapsible
    Should Be Equal   ${collapsible}   true
Mastercard Validation
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/accountLocation/xReadMasterCardValidation  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true
Available Downloads
    &{data}=  Create Dictionary  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/transactionReport/xAvailableDownloads  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal   ${success}   true 
Read TodayDate
    &{data}  Create Dictionary   csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/json;charset=UTF-8
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/home/xUserTodayDate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read Payment Alert Summary
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/home/xPaymentAlertSummary  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${total}=  Get Items By Path  ${resp.content}  $..total
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Run keyword if  ${total} == 0  Should Be Equal  ${success}  false    
    # ELSE  Should Be Equal  ${success}  true
Get Merchant List
    [Tags]    Smoke
    Retrieve Merchant List (version > 2.4 only)
Update Merchant
    [Tags]    Smoke
    Update Merchant (version > 2.4 only)
Read Account Location Id
    [Tags]    Smoke
    Read Account Location
Hide Reconcilaton Report
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  merchantid  ${merchant_external_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/transactionReport/xHideReconcilationReport  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${hidereport}=  Get Items By Path  ${resp.content}  $..hidereport
    Should Be Equal  ${hidereport}  true
Read Supported AccountTypes
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  accountlocationid  ${processing_account_id}
    Set To Dictionary  ${data}  simpleNames  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/accountType/xReadSupportedAccountTypes  data=${data}  headers=${headers}
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
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/TransactionReport/getSummary  data=${data}  headers=${headers}
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
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/TransactionReport/getDetails  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${errors}=  Get Items By Path  ${resp.content}  $..errors
    ${errLength}=  Get Length  ${errors}
    Run keyword if  ${errLength} == 2  Should Be Equal   ${success}  true
    Run keyword if  ${errLength} > 2    Should Be Equal   ${success}   false
Get Report Summary
    ${today}    Get Current Date    result_format=%m/%d/%Y
    ${oldDate}    Subtract Time From Date    ${today}    10d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  fromdate  ${oldDate}
    Set To Dictionary  ${data}  todate  ${today}
    Set To Dictionary  ${data}  accountlocationids  All
    Set To Dictionary  ${data}  reportbydate  transactionDate
    Set To Dictionary  ${data}  includecustomdataflag  false
    ${params}=  Catenate  transactiontypeids=1
    ${params}=  Catenate  SEPARATOR=  ${params}  &  transactiontypeids=2
    ${params}=  Catenate  SEPARATOR=  ${params}  &  transactiontypeids=3
    ${params}=  Catenate  SEPARATOR=  ${params}  &  transactiontypeids=4
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Accepted
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Authorized
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Pending Deposit
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Review
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Processed
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Settled
    ${params}=  Catenate  SEPARATOR=  ${params}  &  includestatustype=Submitted
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    Log  params is ${params}
    ${resp}=  Post Request  regularSession  sbps/transactionReport/getSummary  params=${params}  data=${data}  headers=${headers}  
    Pretty Print  ${resp.content}
    Should Not Contain  ${resp.text}  \"errors\":
    Should Contain    ${resp.text}    success
Is Download Too Large
    # isDownloadTooLarge depends upon getSummary having been called with proper parameters in the current session
    # the parameters are stored in session scope and recalled by isDownloadTooLarge
    # isDownloadTooLarge will throw a NullPointerException and return the error page if this step is omitted
    &{data}=  Create Dictionary  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/transactionReport/isDownloadTooLarge  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${message}=  Get Items By Path  ${resp.content}  $..message
    log     ${message}
    Should Contain Any   ${message}  Download too large  Download ok
Create API Key
    [Tags]    Smoke
    ${api_key_name}=  Generate Random String  length=10  chars=[LETTERS]
    ${data}  Create Dictionary   name  ${api_key_name}
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/settings/xCreateApiKey  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${api_key_name}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "name":"(.*?)","  1
    ${api_key_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "prcacctapiid":"?(.*?)"?,"  1
    Log  ${api_key_name[0]}
    Set Suite Variable  \${api_key_name}  ${api_key_name[0]}
    Log  ${api_key_id[0]}
    Set Suite Variable  \${api_key_id}  ${api_key_id[0]}
Update API Key
    [Tags]    Smoke
     ${data}  Create Dictionary  csrfToken  ${session_id}
     Set To Dictionary  ${data}  name  ${api_key_name}
     Set To Dictionary  ${data}  prcacctapiid  ${api_key_id}
     Set To Dictionary  ${data}  isenabled  true
     &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
     Set To Dictionary  ${headers}  referer=${url}/sbps
     ${resp}=  Post Request  regularSession  /sbps/settings/xUpdateApiKey  data=${data}  headers=${headers}
     Pretty Print  ${resp.content}
     ${success}=  Get Items By Path  ${resp.content}  $..success
     Should Be Equal  ${success}  true
Create Customer With ACH Payment Account
    [Tags]    Smoke
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
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${ach_created_customer_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{"id":"?(.*?)"?,  1                                               
    Log  ${ach_created_customer_id[0]}
    Set Suite Variable  \${ach_created_customer_id}  ${ach_created_customer_id[0]}
    ${ach_pmt_acct_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{.*?,"paymentAccount_id":"?(.*?)"?,  1
    Log  ${ach_pmt_acct_id[0]}
    Set Suite Variable  \${ach_pmt_acct_id}  ${ach_pmt_acct_id[0]}
Read New Customer
    ${data}  Create Dictionary   customerorgid  ${ach_created_customer_id} 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/customerOrganization/xGetCustomer  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Inactivate Customer
    [Tags]    Smoke
# Create ACH Customer
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
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${ach_customer_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{"id":"?(.*?)"?,  1                                               
    Log  ${ach_customer_id[0]}
    Set Suite Variable  \${ach_customer_id}  ${ach_customer_id[0]}
# Inactivate Customer
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  status  InActive
    Set To Dictionary  ${data}  customerOrgId  ${ach_customer_id}
    Set To Dictionary  ${data}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${data}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  businessName  ${EMPTY}  
    Set To Dictionary  ${data}  CustomerAddress  Finastra Street 1234 
    Set To Dictionary  ${data}  CustomerCity  Kaysville
    Set To Dictionary  ${data}  state  UT
    Set To Dictionary  ${data}  CustomerZip  84041
    Set To Dictionary  ${data}  PhoneNumber  (555)555-5555
    Set To Dictionary  ${data}  emailaddress  Tom.George${customer_name_uniqueifier}@dh.com
    Set To Dictionary  ${data}  paymentaccountupdate  Yes
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/customerOrganization/xUpdateCustomerDetailInformation  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

# Create ACH Payment Account for Individual Customer
    # ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    # ${data}=  Create Dictionary  customertype  person
    # Set To Dictionary  ${data}  paymentaccounts  [{"customer_id":"${ach_created_customer_id}","name":"${payment_account_name}","entbankaccounttype":1,"datecreated":"","lastupdated":"","nameonaccount":"a081726588","routingnumber":"021000021","achabart":"","achaccountnumber":"","accountnumber":"0626","nameoncard":"","cardnumber":"","expirymonth":"","expiryyear":"","isactive":"","entcreditcardtype":"","accounttype":1,"pa_nameonaccount":"a081726588","pa_nameoncard":"","pa_cardnumber":"","billingaddress":"","billingaddressstreet":"","billingcity":"","billingstate":"","billingpostalcode":"","billingzip":"","requirecvv":"","user_id":""}]
    # Set To Dictionary  ${data}  csrfToken  ${session_id}
    # &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    # Set To Dictionary  ${headers}  referer=${url}/sbps
    # ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xCreate  data=${data}  headers=${headers}
    # Pretty Print  ${resp.content}
    # Should Contain  ${resp.content}  ${ach_created_customer_id}
    # ${ach_pmt_acct_id}  Get Items By Path  ${resp.content}  $..paymentaccounts.id
    # Log  ${ach_pmt_acct_id}
    # Set Suite Variable  \${ach_pmt_acct_id}  ${ach_pmt_acct_id}
Create ACH Recurring Payment with Monthly Frequency
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","amount":"","dispositionType":"","paymentType":"","achponumber":"32","ccponumber":"","taxamount":1,"paymentAccount_id":"${ach_pmt_acct_id}","achamount":"","cvv":"","achtxnfrequencytype":3,"cctxnfrequencytype":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Nate","orginalamount":"","balanceamount":"","feepercent":"","taxamountperpayment":"","totalpaymentstopay":1,"paymentspaid":"","startdate":"","achinvoicenumber":"1","ccinvoicenumber":"","emailnotes":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","paymentdate":"${today}","recurrencetype":"Recurring","paymentAccount":"","entfeeschedule":"","txnachpayment_id":"","entcreditcardtype":"","entbankaccounttype":1,"ccamount":"","ccpaymentdate":"","achpaymentdate":"","achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","expirydate":"","firstpaymentwithfee":9,"browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/recurringPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 
Create ACH Recurring Payment with 1st and 15th Frequency
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","amount":"","dispositionType":"","paymentType":"","achponumber":"32","ccponumber":"","taxamount":1,"paymentAccount_id":"${ach_pmt_acct_id}","achamount":"","cvv":"","achtxnfrequencytype":2,"cctxnfrequencytype":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Nate","orginalamount":"","balanceamount":"","feepercent":"","taxamountperpayment":"","totalpaymentstopay":1,"paymentspaid":"","startdate":"","achinvoicenumber":"1","ccinvoicenumber":"","emailnotes":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","paymentdate":"${today}","recurrencetype":"Recurring","paymentAccount":"","entfeeschedule":"","txnachpayment_id":"","entcreditcardtype":"","entbankaccounttype":1,"ccamount":"","ccpaymentdate":"","achpaymentdate":"","achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","expirydate":"","firstpaymentwithfee":9,"browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/recurringPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}      
Get ACH Payment Accounts
    ${data}  Create Dictionary  customer_id  ${ach_created_customer_id} 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  filter  [{"property":"customer_id","value":"${ach_created_customer_id}"]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xListAchAccount  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Create Customer with Card Payment Account
    [Tags]    Smoke
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
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${cc_created_customer_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{"id":"?(.*?)"?,  1
    ${cc_pmt_acct_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  paymentAccount_id":"?(.*?)"?,  1  
    Log  ${cc_pmt_acct_id[0]}                                       
    Log  ${cc_created_customer_id[0]}
    Set Suite Variable  \${cc_created_customer_id}  ${cc_created_customer_id[0]}
    Set Suite Variable  \${cc_pmt_acct_id}  ${cc_pmt_acct_id[0]}
    Set Suite Variable  \${customer_name_random_part}  ${customer_name_random_part}
Update CC Payment Account
    [Tags]    Smoke
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  accounttype  3
    Set To Dictionary  ${data}  cardnumber  xxxxxxxxxxxx1111
    Set To Dictionary  ${data}  nameonaccount  Finastra Tester
    Set To Dictionary  ${data}  accountname   VISAxxxxx1111
    Set To Dictionary  ${data}  expirymonth   10
    Set To Dictionary  ${data}  expiryyear    25 
    Set To Dictionary  ${data}  auditUserId  ${EMPTY}
    Set To Dictionary  ${data}  paymentaccountid  ${cc_pmt_acct_id}
    Set To Dictionary  ${data}  status  Active
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xUpdatePaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    Log    ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Update CC Customer
    [Tags]    Smoke
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  status  Active
    Set To Dictionary  ${data}  customerOrgId  ${cc_created_customer_id}
    Set To Dictionary  ${data}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${data}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  businessName  ${EMPTY}  
    Set To Dictionary  ${data}  CustomerAddress  Finastra Street 1235 
    Set To Dictionary  ${data}  CustomerCity  Kaysville
    Set To Dictionary  ${data}  state  UT
    Set To Dictionary  ${data}  CustomerZip  84041
    Set To Dictionary  ${data}  PhoneNumber  (555)555-5555
    Set To Dictionary  ${data}  emailaddress  Tom.George${customer_name_uniqueifier}@dh.com
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/customerOrganization/xUpdateCustomerDetailInformation  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    Log    ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true

Read New CC Customer
    ${data}  Create Dictionary   customerorgid  ${cc_created_customer_id} 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/customerOrganization/xGetCustomer  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Create Card Payment Account - Invalid card number (Not in test card list)
    ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${name_on_card}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  customertype  person
    Set To Dictionary  ${data}  paymentaccounts  [{"customer_id":"${cc_created_customer_id}","name":"${payment_account_name}","entbankaccounttype":"","datecreated":"","lastupdated":"","nameonaccount":"","routingnumber":"","achabart":"","achaccountnumber":"","accountnumber":"","nameoncard":"${name_on_card}","cardnumber":"5454252525252525","expirymonth":"02","expiryyear":"22","isactive":"","entcreditcardtype":6,"accounttype":6,"pa_nameonaccount":"","pa_nameoncard":"${name_on_card}","pa_cardnumber":"5454252525252525","billingaddress":"","billingaddressstreet":"5800 NW 39th AVE","billingcity":"Gainesville","billingstate":"FL","billingpostalcode":"32606","billingzip":"32606","requirecvv":"","user_id":""}]
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xCreate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  false
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  "Invalid card number, Please verify data. Error while parsing input parameters."
Create Fee Schedule
    [Tags]    Smoke
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
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/configuration/xCreateFeeSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${fee_schedule_id}=  Get Items By Path  ${resp.content}  $..entFeeScheduleId
    ${fee_schedule_id}=  Remove String  ${fee_schedule_id}  "
    Set Suite Variable  \${fee_schedule_id}  ${fee_schedule_id}
    Set Suite Variable   \${fee_schedule_name}  ${fee_schedule_name}
Read Fee Schedule
    [Tags]    Smoke
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadFeeSchedule  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${fee_schedule_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${fee_schedule_id[0]} 
    ${zero_fee_schedule_id}=  Get Items By Path  ${resp.content}  $..feeSchedules[?(@.name=='${zero_fee_schedule_name}')].id
    Set Suite Variable  \${zero_fee_schedule_id}  ${zero_fee_schedule_id} 
Update Fee Schedule
    [Tags]    Smoke
    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  name   ${zero_fee_schedule_name}
    Set To Dictionary  ${data}  feeScheduleId  ${zero_fee_schedule_id}
    Set To Dictionary  ${data}  isDefault  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/configuration/xUpdateFeeSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
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
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
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
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
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
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
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
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
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
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":12,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/23","ccpaymentdate":"${today}","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    Log  ${data}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}    
Create Card Payment - Authorized based on $11.00 amount 
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":11,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/23","ccpaymentdate":"${today}","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}
    ${cc_void_payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${cc_void_payment_id[0]}   
    Set Suite Variable  \${cc_void_txn_id}  ${cc_void_payment_id[0]}   
Create Card Payment - Authorized based on $15 amount
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":15.0,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/23","ccpaymentdate":"${today}","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}  
Create CC Recurring Payment with Weekly Frequency
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions    [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","amount":"","dispositionType":"","paymentType":"","achponumber":"","ccponumber":"99","taxamount":1,"paymentAccount_id":"${cc_pmt_acct_id}","achamount":"","cvv":"999","achtxnfrequencytype":"","cctxnfrequencytype":1,"nameoncard":"Akhil Kumar","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","orginalamount":"","balanceamount":"","feepercent":"","taxamountperpayment":"","totalpaymentstopay":1,"paymentspaid":"","startdate":"","achinvoicenumber":"","ccinvoicenumber":"99","emailnotes":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","paymentdate":"${today}","recurrencetype":"Recurring","paymentAccount":"","entfeeschedule":"","txnachpayment_id":"","entcreditcardtype":4,"entbankaccounttype":"","ccamount":"","ccpaymentdate":"","achpaymentdate":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","expirydate":"9/31","firstpaymentwithfee":55,"browserdate":"${today}","achAuthType":"","customdata":{},"firstpaymentdate":"","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/recurringPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    # ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    # Log  ${payment_id[0]}
    ${cc_payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${cc_payment_id[0]} 
	Set Suite Variable  \${cc_payment_id}  ${cc_payment_id[0]}
	${cc_paymentAccount_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "paymentaccount":"?(.*?)"?,  1
    Log  ${cc_paymentAccount_id[0]}
    Set Suite Variable  \${cc_paymentAccount_id}   ${cc_paymentAccount_id[0]}
Create Extra Payment for CC weekly Reccuring payment
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  scheduleid  ${cc_payment_id}
    Set To Dictionary  ${data}  paymentaccountid  ${cc_pmt_acct_id}
    Set To Dictionary  ${data}  CVV  ${EMPTY}
    Set To Dictionary  ${data}  amount  10.00
    Set To Dictionary  ${data}  feescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  paymentdate  ${today}
    Set To Dictionary  ${data}  notes  ${EMPTY}    
    Set To Dictionary  ${data}  memo   ${EMPTY} 
    Set To Dictionary  ${data}  entbankaccounttype  ${EMPTY} 
    Set To Dictionary  ${data}  entcreditcardtype  4
    Set To Dictionary  ${data}  billingaddress  ${EMPTY}
    Set To Dictionary  ${data}  billingcity  ${EMPTY}
    Set To Dictionary  ${data}  billingstate  ${EMPTY}
    Set To Dictionary  ${data}  billingpostalcode  ${EMPTY}
    Log  ${data}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreateExtraPayment  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Inactivate Recurring CC Payment Schedule After Future Date
    ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  inactivateNow  false
    Set To Dictionary  ${data}  scheduleId  ${cc_payment_id}
    Set To Dictionary  ${data}  date  ${futureDate}
    Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xTerminateSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
Cancel Termination of Recurring CC Payment Schedule
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  scheduleId  ${cc_payment_id}
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCancelPendingSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
View Recurring CC Payment Schedule
	${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  scheduleId   ${cc_payment_id}
    Set To Dictionary  ${data}  paymentAccountName  ${cc_paymentAccount_id}
    Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactionDetail  data=${data}  headers=${headers}
	Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    # Inactivate Recurring CC Payment Schedule After Future Date
    # ${data}  Create Dictionary  csrfToken  ${session_id}
	# Set To Dictionary  ${data}  inactivateNow  false
    # Set To Dictionary  ${data}  scheduleId  ${cc_payment_id}
    # Set To Dictionary  ${data}  usertz  +0530
	# Log  ${data}
	# &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	# Set To Dictionary  ${headers}  referer=${url}/sbps
    # ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xTerminateSchedulePayment  data=${data}  headers=${headers}
	# Log  ${resp.content}
    # ${success}=  Get Items By Path  ${resp.content}  $..success
    # Should Be Equal  ${success}  true
Update Payment dates of Recurring CC Payment Schedule
    [Tags]    Smoke
    ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  nextPaymentDate  ${futureDate}
    Set To Dictionary  ${data}  paymentAccountName  VISAxxxxx1111
    Set To Dictionary  ${data}  scheduleId  ${cc_payment_id}
    Set To Dictionary  ${data}  browserdate  ${today} 
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xUpdateNextPaymentDate  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
Create CC Installment Payment for $25 with Semi-Annually Frequency
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions    [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"100","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":4,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":100,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":5,"firstpaymentwithfee":25,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":100,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/
    ${resp}=  Post Request  regularSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Log  ${resp.content}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Set Suite Variable  \${cc_ins_payment_id}   ${payment_id[0]}  
    ${cc_payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${cc_payment_id[0]} 
	Set Suite Variable  \${cc_payment_id}  ${cc_payment_id[0]}
	${cc_paymentAccount_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "paymentaccount":"?(.*?)"?,  1
    Log  ${cc_paymentAccount_id[0]}
    Set Suite Variable  \${cc_paymentAccount_id}   ${cc_paymentAccount_id[0]}
View Installment CC Payment Schedule
    [Tags]    Smoke
	${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  scheduleId   ${cc_payment_id}
    Set To Dictionary  ${data}  paymentAccountName  ${cc_paymentAccount_id}
    Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactionDetail  data=${data}  headers=${headers}
	Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
# Read Fee Schedule
    # ${data}=  Create Dictionary  csrfToken  ${session_id}
    # Set To Dictionary  ${data}  page  1
    # Set To Dictionary  ${data}  start  0
    # Set To Dictionary  ${data}  limit  50
    # Set To Dictionary  ${data}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
	# &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	# Set To Dictionary  ${headers}  referer=${url}/sbps
    # ${resp}=  Post Request  regularSession  /sbps/configuration/xReadFeeSchedule  data=${data}  headers=${headers}
    # ${success}=  Get Items By Path  ${resp.content}  $..success
    # Should Be Equal  ${success}  true  
    # ${fee_schedule_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    # Log  ${fee_schedule_id[0]} 
    # ${zero_fee_schedule_id}=  Get Items By Path  ${resp.content}  $..feeSchedules[?(@.name=='${zero_fee_schedule_name}')].id
    # Set Suite Variable  \${zero_fee_schedule_id}  ${zero_fee_schedule_id}   
Customer ->Update Schedule Fee
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  scheduleid  ${cc_payment_id}
	Set To Dictionary  ${data}  feescheduleid  ${zero_fee_schedule_id}
    #Set To Dictionary  ${data}  paymentAccountName  ${cc_paymentAccount_id}
    #Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xUpdateScheduleFee  data=${data}  headers=${headers}
	Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Inactivate Installment CC Payment Schedule After Future Date
    [Tags]    Smoke
    ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  inactivateNow  false
    Set To Dictionary  ${data}  scheduleId  ${cc_ins_payment_id}
    Set To Dictionary  ${data}  date  ${futureDate}
    Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xTerminateSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
Cancel Termination of CC Installment Payment Schedule
    [Tags]    Smoke
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  scheduleId  ${cc_ins_payment_id}
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCancelPendingSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal    ${success}  true
Create CC Installment Payment for ${cc_processor_based_failure_amount}/Payment Expect Failure
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions     [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"100","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":20,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":100,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":1,"firstpaymentwithfee":${cc_processor_based_failure_amount},"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":8000,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Log  ${paymentStatus}
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
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
    # Create CC OTP - For Voiding
    # ${payment_amount}=   Generate Random String  length=2  chars=[NUMBERS]
    # ${data}  Create Dictionary  csrfToken  ${session_id}
Void CC OTP
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions   [{"id":"${cc_void_txn_id}","entbankaccounttype":false,"entcreditcardtype":true}]  
    Log    ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xVoid  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Create Business Customer with Card Payment Account
    [Tags]    Smoke 

    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  customertype  business
    Set To Dictionary  ${data}  entprocessingaccount_id  ${processing_account_id}
    Set To Dictionary  ${data}  businessname  businessname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  city  Newton
    Set To Dictionary  ${data}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${data}  emailaddress  bryan.thomas${customer_name_uniqueifier}@dh.com
    Set To Dictionary  ${data}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  phonenumber  (555)555-5555 
    Set To Dictionary  ${data}  state  UT 
    Set To Dictionary  ${data}  street1  10 W 600 N 
    Set To Dictionary  ${data}  zip  84041 
    Set To Dictionary  ${data}  entcreditcardtype  6 
    Set To Dictionary  ${data}  cardnumber  5454545454545454 
    Set To Dictionary  ${data}  expirymonth  03
    Set To Dictionary  ${data}  expiryyear   22
    Set To Dictionary  ${data}  pa_cardnumber   5454545454545454
    Set To Dictionary  ${data}  pa_expirymonth  03
    Set To Dictionary  ${data}  pa_expiryyear   22
    Set To Dictionary  ${data}  pa_nameoncard   Bennett Biotechnology
    Set To Dictionary  ${data}  name  MASTERCARD xxxxx5454 
    Set To Dictionary  ${data}  billingaddressstreet   131 Buchanan Boulevard, Apt 9
    Set To Dictionary  ${data}  billingcity            Newton
    Set To Dictionary  ${data}  billingstate           TX
    Set To Dictionary  ${data}  billingzip             29434
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${cc_created_customer_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{"id":"?(.*?)"?,  1
    Log  ${cc_created_customer_id[0]}
    Set Suite Variable  \${cc_created_customer_id}  ${cc_created_customer_id[0]} 
Create a Card Payment Account for Business Customer
    [Tags]    Smoke

    ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  usertz  +0530
    Set To Dictionary  ${data}  paymentaccounts  [{"customer_id":"${cc_created_customer_id}","name":"VISA xxxxx1111","entbankaccounttype":"","datecreated":"","lastupdated":"","nameonaccount":"","routingnumber":"","achabart":"","achaccountnumber":"","accountnumber":"","nameoncard":"John Consumer","cardnumber":"4111111111111111","expirymonth":"03","expiryyear":"22","isactive":"","entcreditcardtype":"6","accounttype":6,"pa_nameonaccount":"","pa_nameoncard":"John Consumer","pa_cardnumber":"4111111111111111","billingaddress":"","billingaddressstreet":"1614 W","billingcity":"Rocklaid","billingstate":"UT","billingpostalcode":"","billingzip":"84041","requirecvv":"","user_id":"","isdefault":""}] 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    Should Contain  ${resp.content.decode('utf-8')}  ${cc_created_customer_id}
    ${cc_pmt_acct_id}  Get Items By Path  ${resp.content}  $..paymentaccounts.id
    Log  ${cc_pmt_acct_id}}
    Set Suite Variable  \${cc_pmt_acct_id}  ${cc_pmt_acct_id}
Create CC Installment Payment for $25 with Quarterly Frequency
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions    [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"100","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":4,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":100,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":4,"firstpaymentwithfee":25,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":100,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1    
Read Transaction History
    ${monthNumber}  Get Current Date    result_format=%m
    # #Comments from the server code on why zero based month number
    # //Temporary fix until these params have been normalized in their format across the application
    # //params.month is a 0 based month currently, we add 1 to this so this follows the ISO-8601 standard,
    # //from 1 (January) to 12 (December).
    # //params.year is currently 1+last two digits of year so 2016 = 116. We need a normal 4 digit year and modify
    # // Grails only strips whitespace on data binding so in this usage we strip any surrounding whitespace.
    # // params.merchantid currently is not being passed in but will be in the future to allow the user with multiple
    # // merchants to pick which merchant to review. To future proof the application this is hardcoded in for now,
    # // to be removed later once the UI can supply us this as a Long if a String is returned other conversion will
    # // be necessary. Date/Times are now converted to the entMerchant.processingZone <ZoneId>
    ${zeroBasedMonthNumber}=  Evaluate  int($monthNumber) - 1
    Log  Zero based month number is ${zeroBasedMonthNumber}
    ${yearNumber}   Get Current Date    result_format=%y
    ${data}  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  month  ${zeroBasedMonthNumber}
    Set To Dictionary  ${data}  year  1${yearNumber}  #1 is leading because that's what UI does
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/home/xTransactionHistoryRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read Snapshot Calendar
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  date  ${today}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/home/xSnapshotCalendar  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read Snapshot Calendar for previous day
    ${olddate}    Subtract Time From Date    ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  date  ${today}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/home/xSnapshotCalendar  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true    
Get Payment Alerts
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/home/xPaymentAlertSummary  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${total_count}=  Get Items By Path  ${resp.content}  $..total
    Run Keyword If    ${total_count}!=0    Should Be Equal    ${success}  true     
    Run Keyword If    ${total_count}==0    Should Be Equal    ${success}  false   
    # Log  Looking for alert with customer id ${customer_name_random_part}
    # ${alert_id_found_by_customer_id}=  Get Items By Path  ${resp.content}  $..paymentalerts[?(@.customerid=='${customer_name_random_part}')].alertid
    # ${alert_id}=  Set Suite Variable  \${alert_id}  ${alert_id_found_by_customer_id}
    # Log  Found the alert id: ${alert_id_found_by_customer_id}
    # ${alertstatus}=  Get Items By Path  ${resp.content}  $..paymentalerts[?(@.customerid=='${customer_name_random_part}')].alertstatus
    # Should Be Equal  ${alertstatus}  1
    # ${payment_id} =  Get Items By Path  ${resp.content}  $..paymentalerts[?(@.customerid=='${customer_name_random_part}')].id
    # Log  payment_id is ${payment_id} 
    # Set Suite Variable  \${payment_id}  ${payment_id}
    # ${payment_external_id} =  Get Items By Path  ${resp.content}  $..paymentalerts[?(@.customerid=='${customer_name_random_part}')].transactionid
    # Log  payment_external_id is ${payment_external_id} 
    # Set Suite Variable  \${payment_external_id}  ${payment_external_id}
    # ${amount}=  Get Items By Path  ${resp.content}  $..paymentalerts[?(@.customerid=='${customer_name_random_part}')].amount
    # Should Be Equal  ${amount}  ${cc_processor_based_failure_amount} 
Read Transaction Detail
    ${stripped_payment_id}=  Remove String  ${payment_id}  "
    ${stripped_payment_external_id}=  Remove String  ${payment_external_id}  "
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  id  ${stripped_payment_id} 
    Set To Dictionary  ${data}  paymenttxntype  CC
    Set To Dictionary  ${data}  externalid  ${stripped_payment_external_id} 
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xReadTransactionDetail  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${processingaccountid_in}=  Get Items By Path  ${resp.content}  $..processingaccountid
    Should Be Equal  ${processingaccountid_in}  ${processing_account_id}  
    # ${alertid_in}=  Get Items By Path  ${resp.content}  $..alertid
    # Should Be Equal  ${alertid_in}  ${alertid}  
    # ${alertstatus_in}=  Get Items By Path  ${resp.content}  $..alertstatus
    # Should Be Equal  ${alertstatus_in}  1  
     
Read Payment Schedules for CC Customer

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id  ${cc_created_customer_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    Set To Dictionary  ${data}  filter  [{"property":"customer_id","value":"${cc_created_customer_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactions  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Create ACH One Time Payment Should Fail Based on Command Object for the comma in achinvoicenumber
    ${name_on_account}=  Generate Random String  length=10  chars=[LETTERS]
    ${payment_amount}=   Generate Random String  length=2  chars=[NUMBERS]
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":"","dispositionType":"","paymentType":"","achinvoicenumber":"123,456","ccinvoicenumber":"","achponumber":null,"ccponumber":"","taxamount":null,"paymentAccount_id":"${ach_pmt_acct_id}","achAmount":"${payment_amount}","cvv":"","achfeeschedule":"${fee_schedule_id}","ccfeeschedule":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":"","entbankaccounttype":1,"routingnumber":"","expirydate":"","ccpaymentdate":"","achpaymentdate":"${today}","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"written","customdata":"","nameonaccount":"${name_on_account}","nameoncard":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  false
    Should Contain  ${resp.text}  The system experienced an error while attempting to process your request, please try again.  
# Create ACH One Time Payment - For Voiding
    # ${name_on_account}=  Generate Random String  length=10  chars=[LETTERS]
    # ${payment_amount}=   Generate Random String  length=2  chars=[NUMBERS]
    # ${data}  Create Dictionary  csrfToken  ${session_id} 
Read Payment Schedules for ACH Customer

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id  ${ach_created_customer_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    Set To Dictionary  ${data}  filter  [{"property":"customer_id","value":"${ach_created_customer_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactions  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
     ${ach_schedule_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "scheduleid":"?(.*?)"?,  1
    Log  ${ach_schedule_id[0]} 
    Set Suite Variable  \${ach_schedule_id}  ${ach_schedule_id[0]} 
Create Business customer with ACH Payment Account
    [Tags]    Smoke

    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  customertype  business
    Set To Dictionary  ${data}  entprocessingaccount_id  ${processing_account_id}
    Set To Dictionary  ${data}  city  St. George
    Set To Dictionary  ${data}  businessname  business${customer_name_uniqueifier}
    Set To Dictionary  ${data}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${data}  emailaddress  jenny.austin${customer_name_uniqueifier}@dh.com
    Set To Dictionary  ${data}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  phonenumber  (555)327-7301 
    Set To Dictionary  ${data}  state  MD 
    Set To Dictionary  ${data}  street1  328 Monroe Square
    Set To Dictionary  ${data}  zip  66866-4620 
    Set To Dictionary  ${data}  entbankaccounttype  2 
    Set To Dictionary  ${data}  pa_accountnumber  4111111111111111 
    Set To Dictionary  ${data}  pa_nameonaccount  firstname lastname
    Set To Dictionary  ${data}  pa_routingnumber  122105278 
    Set To Dictionary  ${data}  pa_name  WELLS FARGO BANK NA (ARIZONA) CHECKING xxxxx1111 
    Set To Dictionary  ${data}  billingaddressstreet  10 W 600 N 
    Set To Dictionary  ${data}  billingcity  St. George 
    Set To Dictionary  ${data}  billingstate  MD
    Set To Dictionary  ${data}  billingzip  66866-4620 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Log  ${data}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/addCustomers/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${ach_created_customer_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{"id":"?(.*?)"?,  1                                               
    Log  ${ach_created_customer_id[0]}
    Set Suite Variable  \${ach_created_customer_id}  ${ach_created_customer_id[0]}
    ${ach_pmt_acct_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  customers":\\[{.*?,"paymentAccount_id":"?(.*?)"?,  1
    Log  ${ach_pmt_acct_id[0]}
    Set Suite Variable  \${ach_pmt_acct_id}  ${ach_pmt_acct_id[0]}
Update ACH Customer
    [Tags]    Smoke

    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  status  Active
    Set To Dictionary  ${data}  customerOrgId  ${ach_created_customer_id}
    Set To Dictionary  ${data}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${data}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${data}  businessName  ${EMPTY}  
    Set To Dictionary  ${data}  CustomerAddress  Finastra Street 1234 
    Set To Dictionary  ${data}  CustomerCity  Kaysville
    Set To Dictionary  ${data}  state  UT
    Set To Dictionary  ${data}  CustomerZip  84041
    Set To Dictionary  ${data}  PhoneNumber  (555)555-5555
    Set To Dictionary  ${data}  emailaddress  Tom.George${customer_name_uniqueifier}@dh.com
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/customerOrganization/xUpdateCustomerDetailInformation  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
# Create ACH Payment Account for Business Customer
    # ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    # ${data}=  Create Dictionary  customertype  business
    # #Set To Dictionary  ${data}  paymentaccounts  [{"customer_id":"${ach_created_customer_id}","name":"${payment_account_name}","entbankaccounttype":1,"datecreated":"","lastupdated":"","nameonaccount":"a081726588","routingnumber":"021000021","achabart":"","achaccountnumber":"","accountnumber":"0626","nameoncard":"","cardnumber":"","expirymonth":"","expiryyear":"","isactive":"","entcreditcardtype":"","accounttype":1,"pa_nameonaccount":"a081726588","pa_nameoncard":"","pa_cardnumber":"","billingaddress":"","billingaddressstreet":"","billingcity":"","billingstate":"","billingpostalcode":"","billingzip":"","requirecvv":"","user_id":""}]
    # Set To Dictionary  ${data}  paymentaccounts  [{"customer_id":"${ach_created_customer_id}","name":"${payment_account_name}","entbankaccounttype":1,"datecreated":"","lastupdated":"","nameonaccount":"businessTUltEWpbpADMgFTnnqdO","routingnumber":"021000021","achabart":"","achaccountnumber":"","accountnumber":"0626","nameoncard":"","cardnumber":"","expirymonth":"","expiryyear":"","isactive":"","entcreditcardtype":"","accounttype":1,"pa_nameonaccount":"businessTUltEWpbpADMgFTnnqdO","pa_nameoncard":"","pa_cardnumber":"","billingaddress":"","billingaddressstreet":"","billingcity":"","billingstate":"","billingpostalcode":"","billingzip":"","requirecvv":"","user_id":""}]
    # Set To Dictionary  ${data}  csrfToken  ${session_id}
    # &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    # Set To Dictionary  ${headers}  referer=${url}/sbps
    # ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xCreate  data=${data}  headers=${headers}
    # Pretty Print  ${resp.content}
    # Should Contain  ${resp.content}  ${ach_created_customer_id}
    # ${ach_pmt_acct_id}  Get Items By Path  ${resp.content}  $..paymentaccounts.id
    # Log  ${ach_pmt_acct_id}
    # Set Suite Variable  \${ach_pmt_acct_id}   ${ach_pmt_acct_id}
Create ACH One Time Payment
    [Tags]    Smoke

    ${name_on_account}=  Generate Random String  length=10  chars=[LETTERS]
    ${payment_amount}=   Generate Random String  length=2  chars=[NUMBERS]
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":"","dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":"","achponumber":"","ccponumber":"","taxamount":null,"paymentAccount_id":"${ach_pmt_acct_id}","achAmount":"${payment_amount}","cvv":"","achfeeschedule":"${fee_schedule_id}","ccfeeschedule":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":"","entbankaccounttype":1,"routingnumber":"","expirydate":"","ccpaymentdate":"","achpaymentdate":"${today}","authCode":"","status":"","source":"","privileged":"","browserdate":"${today}","achAuthType":"written","customdata":"","nameonaccount":"${name_on_account}","nameoncard":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${ach_void_payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${ach_void_payment_id[0]} 
    Set Suite Variable  \${ach_void_txn_id}  ${ach_void_payment_id[0]}
Void ACH OTP
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  paymentTransactions   [{"id":"${ach_void_txn_id}","entbankaccounttype":true,"entcreditcardtype":false}]  
    Log    ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xVoid  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true        
Create Recurring ACH Payment with Annual Frequency
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","amount":"","dispositionType":"","paymentType":"","achponumber":"32","ccponumber":"","taxamount":1,"paymentAccount_id":"${ach_pmt_acct_id}","achamount":"","cvv":"","achtxnfrequencytype":6,"cctxnfrequencytype":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Nate","orginalamount":"","balanceamount":"","feepercent":"","taxamountperpayment":"","totalpaymentstopay":1,"paymentspaid":"","startdate":"","achinvoicenumber":"1","ccinvoicenumber":"","emailnotes":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","paymentdate":"${today}","recurrencetype":"Recurring","paymentAccount":"","entfeeschedule":"","txnachpayment_id":"","entcreditcardtype":"","entbankaccounttype":1,"ccamount":"","ccpaymentdate":"","achpaymentdate":"","achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","expirydate":"","firstpaymentwithfee":9,"browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/recurringPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status
    ${payment_id}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}
    Set Suite Variable  \${payment_id}  ${payment_id[0]}
    ${paymentAccount_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "paymentaccount":"?(.*?)"?,  1
    Log  ${paymentAccount_id[0]}
    Set Suite Variable  \${paymentAccount_id}   ${paymentAccount_id[0]}
View Recurring ACH Payment Schedule
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  scheduleId   ${payment_id}
    Set To Dictionary  ${data}  paymentAccountName  ${paymentAccount_id}
    Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactionDetail  data=${data}  headers=${headers}
	Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Inactivate Recurring ACH Payment Schedule
    [Tags]    Smoke

    ${futureDate}    Add Time To Date   ${today}    4d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  inactivateNow  false
    Set To Dictionary  ${data}  scheduleId  ${payment_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  date  ${futureDate}
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xTerminateSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Cancel Termination of ACH Reccuring Payment Schedule
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  scheduleId  ${payment_id}
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCancelPendingSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Create Installment ACH Payment with Weekly Frequency
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  schedulepaymenttransactions  [{"paymentdate":"${today}","lastUpdated":"","cardType":"","accountType":"","ccamount":"","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${ach_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Richard Rich","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":8,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":25,"ccbeginningbal":"","achbeginningbal":200,"achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","achtxnfrequencytype":1,"cctxnfrequencytype":"","firstpaymentwithfee":25,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":1,"entcreditcardtype":"","achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":200,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"${today}","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/installmentPaymentTransaction/xCreate  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${ach_ins_payment_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "id":"?(.*?)"?,  1
    Log  ${ach_ins_payment_id[0]} 
	Set Suite Variable  \${ach_ins_payment_id}  ${ach_ins_payment_id[0]}
	${ach_ins_paymentAccount_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  "paymentaccount":"?(.*?)"?,  1
    Log  ${ach_ins_paymentAccount_id[0]}
    Set Suite Variable  \${ach_ins_paymentAccount_id}   ${ach_ins_paymentAccount_id[0]} 
Inactivate Installment ACH Payment Schedule
    ${futureDate}    Add Time To Date   ${today}    4d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  inactivateNow  false
    Set To Dictionary  ${data}  scheduleId  ${ach_ins_payment_id}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  date  ${futureDate}
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xTerminateSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Cancel Termination of ACH Installment Payment Schedule
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  scheduleId  ${ach_ins_payment_id}
    Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCancelPendingSchedulePayment  data=${data}  headers=${headers}
	Log  ${resp.content}
	${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
View Payment Schedule
    ${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  scheduleId   ${ach_ins_payment_id}
    Set To Dictionary  ${data}  usertz  +0530
	Log  ${data}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xSchedulePaymentAmortizationDetails  data=${data}  headers=${headers}
	Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
	${skippayments}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "nextpaymentdate":"?(.*?)"?,  1
	Log  ${skip_payments[1]} 
	Set Suite Variable  \${skippayments}  ${skip_payments[1]}
    ${futurepaymentid}=   Get Regexp Matches  ${resp.content.decode('utf-8')}  "futurepaymentid":"?(.*?)"?,  1
	Log  ${futurepaymentid[1]} 
	Set Suite Variable  \${futurepaymentid}  ${futurepaymentid[1]} 
Create Future Extra Payment for ACH weekly Installment payment
    ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  scheduleid  ${ach_ins_payment_id}
    Set To Dictionary  ${data}  paymentaccountid  ${ach_pmt_acct_id}
    Set To Dictionary  ${data}  amount  10.00
    Set To Dictionary  ${data}  feescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  paymentdate  ${futureDate}
    Set To Dictionary  ${data}  notes  ${EMPTY}    
    Set To Dictionary  ${data}  memo   ${EMPTY} 
    Set To Dictionary  ${data}  entbankaccounttype  1 
    Set To Dictionary  ${data}  entcreditcardtype  ${EMPTY}
    Set To Dictionary  ${data}  billingaddress  ${EMPTY}
    Set To Dictionary  ${data}  billingcity  ${EMPTY}
    Set To Dictionary  ${data}  billingstate  ${EMPTY}
    Set To Dictionary  ${data}  billingpostalcode  ${EMPTY}
    Log  ${data}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xCreateExtraPayment  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Get CC Payment Accounts
    [Tags]    Smoke

    ${data}  Create Dictionary  customer_id  ${cc_created_customer_id} 
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  filter  [{"property":"customer_id","value":"${cc_created_customer_id}"]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/xListCardAccount  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Research-Transaction search by Transaction Id
    [Tags]    Smoke

    ${data}  Create Dictionary  fromdate   08/07/2019 
    Set To Dictionary  ${data}  resultsize   1
    Set To Dictionary  ${data}  searchvalue   03050000005959
    Set To Dictionary  ${data}  todate   ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession   /sbps/research/xTransactionSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=      Get Items By Path  ${resp.content}  $..success
Read Customers
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  10
    Set To Dictionary  ${data}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/customerOrganization/xListCustomers  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Display Email Settings
    [Tags]    Smoke

    &{data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  usertz  -0600
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/settings/xDisplayEmailSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${payment_receipt_emails_api}  Get Items By Path  ${resp.content}  $..merchants[?(@.name=='${merchant_search_string}')]
    Log  ${payment_receipt_emails_api}
    Should Contain  ${payment_receipt_emails_api}  PAYMENT_RECEIPT_EMAILS_API
    ${emailTypeId}  Get Items By Path  ${resp.content}  $..emailTypes[?(@.name=='${processing_account_email_type_search_str}')].id
    Set Suite Variable  \${processing_account_email_type_id}  ${emailTypeId}
    Log  ${emailTypeId}
Delete API Key
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  prcacctapiid  ${api_key_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/settings/xDeleteApiKey  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    Should Contain  ${resp.text}   "success":true,"errors"
Read CustomField Types

    ${data}=  Create Dictionary  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession   /sbps/configuration/xReadCustomFieldTypes  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${customFieldTypes_id}=  Get Items By Path  ${resp.content}  $..customFieldTypes
    Log  ${customFieldTypes_id}
    # Disabled Failing Test
    # Fails sometimes - specifically if too many custom fields have been created for the specific processing account even if they've been deleted
    # Create CustomField
        # ${customFieldName}=  Generate Random String  length=10  chars=[LETTERS]
        # Set Suite Variable  \${custom_field_name}  ${customFieldName}
        # ${data}  Create Dictionary   csrfToken   ${session_id}
        # Set To Dictionary  ${data}   processingAccountId  ${processing_account_id}
        # Set To Dictionary  ${data}   customFieldName  ${customFieldName}
        # Set To Dictionary  ${data}   customFieldRule   AnyText32
        # Set To Dictionary  ${data}   customFieldType   TEXT
        # Set To Dictionary  ${data}   isRequired   true
        # Set To Dictionary  ${data}   isEnabled    true
        # &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
        # Set To Dictionary  ${headers}  referer=${url}/sbps
        # ${resp}=  Post Request  regularSession  /sbps/configuration/xCreateCustomField   data=${data}  headers=${headers}
        # Pretty Print  ${resp.content}
        # ${success}=  Get Items By Path  ${resp.content}  $..success
        # Should Be Equal  ${success}  true
    #Disabled Failing Test
#Fails sometimes - specifically if too many custom fields have been created for the specific processing account even if they've been deleted
# Read CustomField   
#     ${data} =  Create Dictionary   csrfToken  ${session_id}
#     Set To Dictionary  ${data}   usertz  +0530  
#     Set To Dictionary  ${data}   entProcessingAccountId   ${processing_account_id}
#     Set To Dictionary  ${data}   filter  [{"property":"processingAccountId", "value":"${processing_account_id}"}]
#     &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
#     Set To Dictionary  ${headers}  referer=${url}/sbps
#     ${resp}=  Post Request  regularSession  /sbps/configuration/xReadCustomField  data=${data}  headers=${headers}
#     Pretty Print  ${resp.content}
#     ${success}=  Get Items By Path  ${resp.content}  $..success
#     ${customfieldid}=  Get Items By Path  ${resp.content}  $..prcAccountCustomFields[?(@.customFieldName=='${custom_field_name}')].id 
Read Processing Settings
    [Tags]    Smoke

    ${data}=  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  processingaccountid   ${processing_account_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadProcessingSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
Update Processing Settings
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  displayLevel2Fields  true
    Set To Dictionary  ${data}  requireCvv  true  
    Set To Dictionary  ${data}  requireAvs  true
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xUpdateProcessingSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Delete Fee Schedule
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  usertz  +0500
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  feeScheduleId  ${fee_schedule_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xDeleteFeeSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read Custom Field Rules
   

    ${data}  Create Dictionary  csrfToken   ${session_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0       
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadCustomFieldRules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
Store Email Settings
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  merchants  [{"id":"${merchant_merchant_id}", "accountLocations":[{"id": "${processing_account_id}","emailTypes":[{"id":"${processing_account_email_type_id}","bccEmails":null,"name": "${processing_account_email_type_search_str}","sendTo":{"merchant": true,"customer": true,"accountLocation":true}}]}]}]
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/settings/xStoreEmailSettings  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read HostedPage
    [Tags]    Smoke

    ${data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId   ${processing_account_id}
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=   Post Request  regularSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success} =  Get Items By Path   ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read Hosted Page Logo

    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/configuration/xReadHostedPageLogo  data=${data}  headers=${headers}
Update Hosted Page Self-Service Payment Settings
    [Tags]    Smoke

    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  feeSchedule  ${zero_fee_schedule_id}
    Set To Dictionary  ${data}  displayLevel2DataFields  true
    Set To Dictionary  ${data}  requireCvv  true
    Set To Dictionary  ${data}  requireAvs  false
    Set To Dictionary  ${data}  display  topofpage
    Set To Dictionary  ${data}  disclaimerText  Test
    Set To Dictionary  ${data}  agreeToTerms  true
    Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/configuration/xUpdateHostedPageSelfServicePaymentSettings  data=${data}  headers=${headers}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Update HostedPage ReceiptAndMessageSettings
    [Tags]    Smoke

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
	Set To Dictionary  ${data}  usertz  +0530
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/configuration/xUpdateHostedPageReceiptAndMessageSettings  data=${data}  headers=${headers}     
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Read API Key
    [Tags]    Smoke

    &{data}  Create Dictionary  csrfToken  ${session_id}
    Set To Dictionary  ${data}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  sbps/settings/xReadApiKey  data=${data}  headers=${headers}     
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true
Research-Transaction
    [Tags]    Smoke

    ${data}  Create Dictionary  fromdate   ${today} 
    Set To Dictionary  ${data}  resultsize   1
    Set To Dictionary  ${data}  searchvalue   ach
    Set To Dictionary  ${data}  todate   ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession   /sbps/research/xTransactionSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=      Get Items By Path  ${resp.content}  $..success
    ${total_count}=  Get Items By Path  ${resp.content}  $..totalcount
    Run Keyword If    ${total_count}!=0    Should Be Equal    ${success}  true     
    Run Keyword If    ${total_count}==0    Should Be Equal    ${success}  false      
Research-Authorization
    [Tags]    Smoke

    ${data}  Create Dictionary  fromdate   ${today} 
    Set To Dictionary  ${data}  resultsize   1
    Set To Dictionary  ${data}  searchvalue   card
    Set To Dictionary  ${data}  todate   ${today}
    Set To Dictionary  ${data}  usertz  +0530
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession   /sbps/research/xPreAuthTransactionSearch  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=      Get Items By Path  ${resp.content}  $..success
    ${total_count}=  Get Items By Path  ${resp.content}  $..totalcount
    Run Keyword If    ${total_count}!=0    Should Be Equal    ${success}  true     
    Run Keyword If    ${total_count}==0    Should Be Equal    ${success}  false   
# Comment out failing test 1/30/2019 by Monte
# Due to URL is not reachable and this could be due to failing connection to antivirus server 05/21/2019 by Dayanand    
# Upload Logo
#     &{data}  Create Dictionary  csrfToken   ${session_id}
#     Set To Dictionary  ${data}  hiddenProcessingAccountId  ${processing_account_id}
#     Log  ${CURDIR}
#     &{files}=    Evaluate  {'file': open('${CURDIR}\\grails_logo.png', 'rb')}
#     Log Variables 
Read Payment Status Submitted Wait Until Succeeds
    Wait Until Keyword Succeeds    1 min    20 sec    Read Payment Status Submitted
Logout
    Run Keyword If  '${testServer}'=='AzureCustint'  Logout CI Environment
             ...                ELSE  Logout
Read Account Location requires csrfToken
    [Tags]    Smoke

    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    ${data}  Create Dictionary  page  1 
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/accountLocation/xRead  data=${data}  headers=${headers}
    Should Contain  ${resp.text}  <title>Login</title>
Read supported account types
    [Tags]    Smoke

    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    ${data}=  Create Dictionary   page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/accountType/xRead  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    Should Contain  ${resp.text}  CHECKING 
    Should Contain  ${resp.text}  SAVINGS
    Should Contain  ${resp.text}  Credit Card 
    Should Contain  ${resp.text}  RDC 
Read supported account types does not verify csrfToken enforcement because of use by Hosted Payment Page
    ${data}=  Create Dictionary   page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  50
    Set To Dictionary  ${data}  csrfToken  12345  #invalid token value
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/accountType/xRead  data=${data}  headers=${headers}
    Log  ${resp.content}
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  <label for='username'>Username:</label>
    Should Contain  ${body}  <label for='password'>Password:</label>
    # the session is invalidated - must login again
Check Hosted Payment Page xReadCustomFields
    [Tags]    Smoke

    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    Read Account Location
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${paymentPageUrl}=  Get Items By Path  ${resp.content}  $..paymentPageUrl
    Log  ${paymentPageUrl}
    Run Keyword If  '${testServer}'=='AzureCustint'  Logout CI Environment
             ...                ELSE  Logout
    #We have a new session, we need to grab the processing account id again since it is dependent on the session
    ${resp}=  Post Request  regularSession  /sbps/payment/${paymentPageUrl}  data=${data}  headers=${headers}  allow_redirects=False
    Pretty Print  ${resp.content}
    ${processing_account_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.accountLocationId = '(.*?)'  1
    Set Suite Variable  \${processing_account_id}  ${processing_account_id[0]}
    Log  ${processing_account_id}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  filter  [{"property":"processingAccountId","value":"${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    #Set To Dictionary  ${data}  csrfToken  ${session_id}i
    ${resp}=  Post Request  regularSession  /sbps/payment/${paymentPageUrl}/xReadCustomFields  data=${data}  headers=${headers}  allow_redirects=False
    Log  ${resp.content}
    Log  ${resp.status_code}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
Check Hosted Payment Page xReadCustomFields Enforces csrfToken
    [Tags]    Smoke

    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    Read Account Location
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${paymentPageUrl}=  Get Items By Path  ${resp.content}  $..paymentPageUrl
    Log  ${paymentPageUrl}
    Run Keyword If  '${testServer}'=='AzureCustint'  Logout CI Environment
             ...                ELSE  Logout
    #We have a new session, we need to grab the processing account id again since it is dependent on the session
    ${resp}=  Post Request  regularSession  /sbps/payment/${paymentPageUrl}  data=${data}  headers=${headers}  allow_redirects=False
    Pretty Print  ${resp.content}
    ${processing_account_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.accountLocationId = '(.*?)'  1
    Set Suite Variable  \${processing_account_id}  ${processing_account_id[0]}
    Log  ${processing_account_id}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    #Do not send the csrfToken this time
    #Set To Dictionary  ${data}  csrfToken  ${session_id}
    Set To Dictionary  ${data}  filter  [{"property":"processingAccountId","value":"${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    #Set To Dictionary  ${data}  csrfToken  ${session_id}i
    ${resp}=  Post Request  regularSession  /sbps/payment/${paymentPageUrl}/xReadCustomFields  data=${data}  headers=${headers}  allow_redirects=False
    Log  ${resp.content}
    Log  ${resp.status_code}
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
     Should Contain  ${body}  <title>Login</title>
CalculatePaymentTotal enforces csrfToken
    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    ${data}  Create Dictionary  ccamount  13.14 
    Set To Dictionary  ${data}  ccbeginningbal  257
    Set To Dictionary  ${data}  ccfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${data}  ccnumberpayments  "" 
    Set To Dictionary  ${data}  entcreditcardtype  4
    Set To Dictionary  ${data}  paymenttype  Installment
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentAccount/calculatePaymentTotal  data=${data}  headers=${headers}
    #should have been rejected and redirected to the login screen
    Should Contain  ${resp.text}  <title>Login</title>
Remove extra payment enforces csrfToken
    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    ${data}  Create Dictionary  scheduleid  12345 
    Set To Dictionary  ${data}  removeextrapaymentid  257
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/paymentTransaction/xRemoveExtraPayment  data=${data}  headers=${headers}
    #should have been rejected and redirected to the login screen
    Should Contain  ${resp.text}  <title>Login</title>
Submit Hosted Payment Page Payment
    [Tags]    Smoke

    
    ${random_name}=  Generate Random String  length=10  chars=[LETTERS]
    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    Read Account Location
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${paymentPageUrl}=  Get Items By Path  ${resp.content}  $..paymentPageUrl
    Log  ${paymentPageUrl}
    Run Keyword If  '${testServer}'=='AzureCustint'  Logout CI Environment
             ...                ELSE  Logout
    Create Sessions
    #We have a new session, we need to grab the processing account id again since it is dependent on the session
    ${resp}=  Post Request  regularSession  /sbps/payment/${paymentPageUrl}  data=${data}  headers=${headers}  allow_redirects=False
    Pretty Print  ${resp.content}
    ${processing_account_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.accountLocationId = '(.*?)'  1
    Set Suite Variable  \${processing_account_id}  ${processing_account_id[0]}
    Log  ${processing_account_id}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    ${data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  recaptcha_response_field	not checked for validation
    Set To Dictionary  ${data}  hostpageid	${paymentPageUrl}
    Set To Dictionary  ${data}  entProcessingAccountId	${processing_account_id}
    Set To Dictionary  ${data}  isRequireCaptcha  ${EMPTY}	
    Set To Dictionary  ${data}  usertz	-0700
    Set To Dictionary  ${data}  customdata	{}
    Set To Dictionary  ${data}  firstname	first${random_name} 
    Set To Dictionary  ${data}  lastname	last${random_name}
    Set To Dictionary  ${data}  address	10 W 600 N
    Set To Dictionary  ${data}  city	Layton
    Set To Dictionary  ${data}  state	UT
    Set To Dictionary  ${data}  postalcode	84041
    Set To Dictionary  ${data}  email	${random_name}@example.com
    Set To Dictionary  ${data}  phonenumber	(801)540-7447
    Set To Dictionary  ${data}  amount	2.00
    Set To Dictionary  ${data}  paymenttype	1
    Set To Dictionary  ${data}  nameoncard	${EMPTY}
    Set To Dictionary  ${data}  cardnumber	${EMPTY}
    Set To Dictionary  ${data}  cvv	 ${EMPTY}
    Set To Dictionary  ${data}  expirationdate  ${EMPTY}	
    Set To Dictionary  ${data}  nameonaccount	${random_name} Tester
    Set To Dictionary  ${data}  routingnumber	021000021
    Set To Dictionary  ${data}  accountnumber	282384838848483
    Set To Dictionary  ${data}  invoicenumber   ${EMPTY}	
    Set To Dictionary  ${data}  purchaseorder	${EMPTY}
    Set To Dictionary  ${data}  taxamount	 ${EMPTY}
    Set To Dictionary  ${data}  billingaddress	${EMPTY}
    Set To Dictionary  ${data}  billingcity	 ${EMPTY}
    Set To Dictionary  ${data}  billingstate  ${EMPTY}	
    Set To Dictionary  ${data}  billingpostalcode	${EMPTY}
    Set To Dictionary  ${data}  agreementofterms	on
    Set To Dictionary  ${data}  ignoreCaptcha	true  #*** This is key to enable automated request
    ${resp}=  Post Request  regularSession  /sbps/payment/save/${paymentPageUrl}  data=${data}  headers=${headers}  allow_redirects=False
    Log  ${resp.content}
    Log  ${resp.status_code}
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Not Contain  ${body}  <title>Login</title>
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
Submit Hosted Payment Page Payment without IgnoreCaptcha should be rejected
    ${random_name}=  Generate Random String  length=10  chars=[LETTERS]
    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${username}  ${password}
     ...                ELSE  Login To Payment Portal  ${username}  ${password}
    Retrieve Merchant List (version > 2.4 only)
    Update Merchant (version > 2.4 only)
    Read Account Location
    ${data}=  Create Dictionary   entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${data}  usertz  -0700
    Set To Dictionary  ${data}  csrfToken  ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  regularSession  /sbps/configuration/xReadHostedPage  data=${data}  headers=${headers}
    Pretty Print  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 
    ${paymentPageUrl}=  Get Items By Path  ${resp.content}  $..paymentPageUrl
    Log  ${paymentPageUrl}
    Run Keyword If  '${testServer}'=='AzureCustint'  Logout CI Environment
             ...                ELSE  Logout
    Create Sessions
    #We have a new session, we need to grab the processing account id again since it is dependent on the session
    ${resp}=  Post Request  regularSession  /sbps/payment/${paymentPageUrl}  data=${data}  headers=${headers}  allow_redirects=False
    Pretty Print  ${resp.content}
    ${processing_account_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.accountLocationId = '(.*?)'  1
    Set Suite Variable  \${processing_account_id}  ${processing_account_id[0]}
    Log  ${processing_account_id}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    ${data}=  Create Dictionary   csrfToken  ${session_id}
    Set To Dictionary  ${data}  recaptcha_response_field	not checked for validation
    Set To Dictionary  ${data}  hostpageid	${paymentPageUrl}
    Set To Dictionary  ${data}  entProcessingAccountId	${processing_account_id}
    Set To Dictionary  ${data}  isRequireCaptcha  ${EMPTY}	
    Set To Dictionary  ${data}  usertz	-0700
    Set To Dictionary  ${data}  customdata	{}
    Set To Dictionary  ${data}  firstname	first${random_name} 
    Set To Dictionary  ${data}  lastname	last${random_name}
    Set To Dictionary  ${data}  address	10 W 600 N
    Set To Dictionary  ${data}  city	Layton
    Set To Dictionary  ${data}  state	UT
    Set To Dictionary  ${data}  postalcode	84041
    Set To Dictionary  ${data}  email	${random_name}@example.com
    Set To Dictionary  ${data}  phonenumber	(801)540-7447
    Set To Dictionary  ${data}  amount	2.00
    Set To Dictionary  ${data}  paymenttype	1
    Set To Dictionary  ${data}  nameoncard	${EMPTY}
    Set To Dictionary  ${data}  cardnumber	${EMPTY}
    Set To Dictionary  ${data}  cvv	 ${EMPTY}
    Set To Dictionary  ${data}  expirationdate  ${EMPTY}	
    Set To Dictionary  ${data}  nameonaccount	${random_name} Tester
    Set To Dictionary  ${data}  routingnumber	021000021
    Set To Dictionary  ${data}  accountnumber	282384838848483
    Set To Dictionary  ${data}  invoicenumber   ${EMPTY}	
    Set To Dictionary  ${data}  purchaseorder	${EMPTY}
    Set To Dictionary  ${data}  taxamount	 ${EMPTY}
    Set To Dictionary  ${data}  billingaddress	${EMPTY}
    Set To Dictionary  ${data}  billingcity	 ${EMPTY}
    Set To Dictionary  ${data}  billingstate  ${EMPTY}	
    Set To Dictionary  ${data}  billingpostalcode	${EMPTY}
    Set To Dictionary  ${data}  agreementofterms	on
    #Set To Dictionary  ${data}  ignoreCaptcha	true  #*** This is key to enable automated request
    ${resp}=  Post Request  regularSession  /sbps/payment/save/${paymentPageUrl}  data=${data}  headers=${headers}  allow_redirects=False
    Log  ${resp.content}
    Log  ${resp.status_code}
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  Incorrect CAPTCHA response
