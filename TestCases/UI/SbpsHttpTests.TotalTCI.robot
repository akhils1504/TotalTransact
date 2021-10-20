# coding: utf-8
*** Settings ***
Documentation     An example of Login
Library           Collections
Library           RequestsLibrary
Library           JsonpathLibrary
Library           OperatingSystem
Library           String
Library           XML
          
*** Variables ***
${url}=  https://totalt-custint.netdeposit.com 
${username}=  admin
${password}=  pass2  #Finastra1!
${merchant_search_string}=  SLC
${processing_account_search_string}=  MST-CI
# ${url}=  https://totalt-custint.netdeposit.com 
# ${username}=  admin
# ${password}=  pass2  #Finastra1!
# ${merchant_search_string}=  SLC
# ${processing_account_search_string}=  MST-CI

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

*** Test Cases ***
Authenticate to the server   
    Set Log Level  debug
    Create Session  adminSession  ${url}  debug=3
    ${params}=  Create Dictionary  j_username  ${username}  j_password  ${password}
    ${resp}=  POST Request  adminSession  /sbps/j_spring_security_check  params=${params}
    Log  ${resp.content}
    ${session_id}=  Get Regexp Matches  ${resp.content}  sbpsutil.sessionid = "(.*?)"  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]}  

Get Merchant Detail (Cannot be called later because it sets the merchant too. This requires fixing.)
    ${params}  Create Dictionary  sessionid  ${session_id}
    ${resp}=  Get Request  adminSession  /sbps/header/xGetMerchantDetail  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    
Retrieve Merchant List and Select Merchant (version > 2.4 only)a
    ${params}  Create Dictionary  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  50
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Get Request  adminSession  /sbps/header/xRetrieveMerchantList  params=${params}
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
    ${params}  Create Dictionary  orgId  ${merchant__org_id}
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Get Request  adminSession  /sbps/header/xUpdateMerchant  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
         
Read Account Location Id
    ${params}  Create Dictionary  page  1 
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  50
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Get Request  adminSession  /sbps/accountLocation/xRead  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${processing_account_id}  Get Items By Path  ${resp.content}  $..accountlocations[?(@.accountlocationname=='${processing_account_search_string}')].id
    Log  ${processing_account_id}
    Set Suite Variable  \${processing_account_id}  ${processing_account_id}

Create API Key
    ${api_key}=  Generate Random String  length=10  chars=[LETTERS]
    ${params}  Create Dictionary   name  ${api_key} 
    Set To Dictionary  ${params}  processingAccountId  ${processing_account_id}
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Get Request  adminSession  /sbps/settings/xCreateApiKey  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${api_key}=  Get Regexp Matches  ${resp.content}  "apikey":"(.*?)","  1
    ${api_key_id}=  Get Regexp Matches  ${resp.content}  "prcacctapiid":"?(.*?)"?,"  1                                               
    Log  ${api_key[0]}
    Set Suite Variable  \${api_key}  ${api_key[0]}   
    Log  ${api_key_id[0]}
    Set Suite Variable  \${api_key_id}  ${api_key_id[0]}   

Create Customer With ACH Account
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${params}=  Create Dictionary  customertype  person
    Set To Dictionary  ${params}  entprocessingaccount_id  ${processing_account_id}
    Set To Dictionary  ${params}  city  Kaysville
    Set To Dictionary  ${params}  customerid  ${customer_name_uniqueifier}
    Set To Dictionary  ${params}  emailaddress  monte.wingle${customer_name_uniqueifier}@dh.com
    Set To Dictionary  ${params}  firstname  firstname${customer_name_uniqueifier}
    Set To Dictionary  ${params}  lastname  lastname${customer_name_uniqueifier}
    Set To Dictionary  ${params}  phonenumber  (555)555-5555 
    Set To Dictionary  ${params}  state  UT 
    Set To Dictionary  ${params}  street1  10 W 600 N 
    Set To Dictionary  ${params}  zip  84041 
    Set To Dictionary  ${params}  entbankaccounttype  1 
    Set To Dictionary  ${params}  pa_accountnumber  111111111111 
    Set To Dictionary  ${params}  pa_nameonaccount  firstname lastname
    Set To Dictionary  ${params}  pa_routingnumber  021000021 
    Set To Dictionary  ${params}  pa_name  JPMORGAN CHASE BANK CHECKING xxxxx1111 
    Set To Dictionary  ${params}  billingaddressstreet  10 W 600 N 
    Set To Dictionary  ${params}  billingcity  Kaysville 
    Set To Dictionary  ${params}  billingstate  UT 
    Set To Dictionary  ${params}  billingzip  84041 
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Post Request  adminSession  /sbps/addCustomers/xCreate  params=${params}
    Log  ${resp.content}
    ${ach_created_customer_id}=  Get Regexp Matches  ${resp.content}  customers":\\[{"id":"?(.*?)"?,  1                                               
    Log  ${ach_created_customer_id[0]}
    Set Suite Variable  \${ach_created_customer_id}  ${ach_created_customer_id[0]}

Read New Customer
    ${params}  Create Dictionary   customerorgid  ${ach_created_customer_id} 
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Get Request  adminSession  /sbps/customerOrganization/xGetCustomer  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  

Create ACH Payment Account
    ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${params}=  Create Dictionary  customertype  person
    Set To Dictionary  ${params}  paymentaccounts  [{"customer_id":"${ach_created_customer_id}","name":"${payment_account_name}","entbankaccounttype":1,"datecreated":"","lastupdated":"","nameonaccount":"a081726588","routingnumber":"021000021","achabart":"","achaccountnumber":"","accountnumber":"0626","nameoncard":"","cardnumber":"","expirymonth":"","expiryyear":"","isactive":"","entcreditcardtype":"","accounttype":1,"pa_nameonaccount":"a081726588","pa_nameoncard":"","pa_cardnumber":"","billingaddress":"","billingaddressstreet":"","billingcity":"","billingstate":"","billingpostalcode":"","billingzip":"","requirecvv":"","user_id":""}]
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Post Request  adminSession  /sbps/paymentAccount/xCreate  params=${params}
    Log  ${resp.content}
    Should Contain  ${resp.content}  ${ach_created_customer_id}
    ${ach_pmt_acct_id}  Get Items By Path  ${resp.content}  $..paymentaccounts.id
    Log  ${ach_pmt_acct_id}
    Set Suite Variable  \${ach_pmt_acct_id}  ${ach_pmt_acct_id}

Get ACH Payment Accounts
    ${params}  Create Dictionary  customer_id  ${ach_created_customer_id} 
    Set To Dictionary  ${params}  sessionid  ${session_id}
    Set To Dictionary  ${params}  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  50
    Set To Dictionary  ${params}  filter  [{"property":"customer_id","value":"${ach_created_customer_id}"]
    ${resp}=  Get Request  adminSession  /sbps/paymentAccount/xListAchAccount  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    
Create Customer with Card Payment Account
    ${payment_account_name}=  Generate Random String  length=20  chars=[LETTERS]
    ${params}=  Create Dictionary    customertype  person
    Set To Dictionary  ${params}  entprocessingaccount_id  ${processing_account_id}
    Set To Dictionary  ${params}  city  Kaysville
    Set To Dictionary  ${params}  customerid  0000081326636
    Set To Dictionary  ${params}  emailaddress  monte.wingle${payment_account_name}@dh.com
    Set To Dictionary  ${params}  firstname  firstname0000081326636
    Set To Dictionary  ${params}  lastname  lastname0000081326636
    Set To Dictionary  ${params}  phonenumber  %28801%29+540-7447
    Set To Dictionary  ${params}  state  UT
    Set To Dictionary  ${params}  street1  10+W+600+N
    Set To Dictionary  ${params}  zip  84041
    Set To Dictionary  ${params}  billingaddressstreet  10+W+600+N
    Set To Dictionary  ${params}  billingcity  Kaysville
    Set To Dictionary  ${params}  billingstate  UT
    Set To Dictionary  ${params}  billingzip  84041
    Set To Dictionary  ${params}  entcreditcardtype  6
    Set To Dictionary  ${params}  expirymonth  11
    Set To Dictionary  ${params}  expiryyear  23
    Set To Dictionary  ${params}  pa_cardnumber  4111111111111111
    Set To Dictionary  ${params}  cardnumber  4111111111111111
    Set To Dictionary  ${params}  name  VISAxxxxx1111
    Set To Dictionary  ${params}  pa_nameoncard  MonteWingle
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Post Request  adminSession  /sbps/addCustomers/xCreate  params=${params}
    Log  ${resp.content}  
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
    ${params}=  Create Dictionary    achAmount  1
    Set To Dictionary  ${params}  achPercent  1
    Set To Dictionary  ${params}  ccAmount  1
    Set To Dictionary  ${params}  ccPercent  1
    Set To Dictionary  ${params}  description  Autogenerated
    Set To Dictionary  ${params}  entProcessingAccountId  ${processing_account_id}
    Set To Dictionary  ${params}  sortOrder  4
    Set To Dictionary  ${params}  isDefault  false
    Set To Dictionary  ${params}  name  ${fee_schedule_name}
    Set To Dictionary  ${params}  sessionid  ${session_id}
    ${resp}=  Post Request  adminSession  sbps/configuration/xCreateFeeSchedule  params=${params}
    Log  ${resp.content}  
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${fee_schedule_id}=  Get Items By Path  ${resp.content}  $..entFeeScheduleId
    ${fee_schedule_id}=  Remove String  ${fee_schedule_id}  "
    Set Suite Variable  \${fee_schedule_id}  ${fee_schedule_id}
    
Read Fee Schedule
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  50
    Set To Dictionary  ${params}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
    ${resp}=  Get Request  adminSession  /sbps/configuration/xReadFeeSchedule  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${fee_schedule_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${fee_schedule_id[0]} 
    ${zero_fee_schedule_id}=  Get Items By Path  ${resp.content}  $..feeSchedules[?(@.name=='Zero Fee Schedule')].id
    Set Suite Variable  \${zero_fee_schedule_id}  ${zero_fee_schedule_id} 

Calculate Payment Total
    #ACH OneTime
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  achamount  ""  
    Set To Dictionary  ${params}  achbeginningbal  6.02
    Set To Dictionary  ${params}  achfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${params}  achnumberpayments  ""  
    Set To Dictionary  ${params}  entbankaccounttype  1
    Set To Dictionary  ${params}  paymenttype  OneTime
    ${resp}=  Get Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${totalAmount}  Get Items By Path  ${resp.content}  $..totalamount 
    Should Be Equal  ${totalAmount}  $7.08 
    ${feeAmount}  Get Items By Path  ${resp.content}  $..feeamount 
    Should Be Equal  ${feeAmount}  $1.06 
    #CC OneTime
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  ccamount  ""  
    Set To Dictionary  ${params}  ccbeginningbal  6.02
    Set To Dictionary  ${params}  ccfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${params}  ccnumberpayments  ""
    Set To Dictionary  ${params}  entcreditcardtype  4
    Set To Dictionary  ${params}  paymenttype  OneTime
    ${resp}=  Get Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${totalAmount}  Get Items By Path  ${resp.content}  $..totalamount 
    Should Be Equal  ${totalAmount}  $7.08 
    ${feeAmount}  Get Items By Path  ${resp.content}  $..feeamount 
    Should Be Equal  ${feeAmount}  $1.06 
    #ACH Installment
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  achamount  13.14
    Set To Dictionary  ${params}  achbeginningbal  257
    Set To Dictionary  ${params}  achfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${params}  achnumberpayments  "" 
    Set To Dictionary  ${params}  entbankaccounttype  1
    Set To Dictionary  ${params}  paymenttype  Installment
    ${resp}=  Get Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  params=${params}
    Log  ${resp.content}
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
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  ccamount  13.14 
    Set To Dictionary  ${params}  ccbeginningbal  257
    Set To Dictionary  ${params}  ccfeescheduleid  ${fee_schedule_id}
    Set To Dictionary  ${params}  ccnumberpayments  "" 
    Set To Dictionary  ${params}  entcreditcardtype  4
    Set To Dictionary  ${params}  paymenttype  Installment
    ${resp}=  Get Request  adminSession  /sbps/paymentAccount/calculatePaymentTotal  params=${params}
    Log  ${resp.content}
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
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":12,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}    

# Create Card Payment - Authorized based on $12.01 amount
#     ${params}  Create Dictionary  sessionid  ${session_id} 
#     Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":12.01,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
#     ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
#     Log  ${resp.content}
#     ${success}=  Get Items By Path  ${resp.content}  $..success
#     Should Be Equal  ${success}  true  
#     ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
#     Should Be Equal  ${paymentStatus}  Authorized 
#     ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
#     Log  ${payment_id[0]}  

# Create Card Payment - Authorized based on $2.60 amount
#     ${params}  Create Dictionary  sessionid  ${session_id} 
#     Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":2.60,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
#     ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
#     Log  ${resp.content}
#     ${success}=  Get Items By Path  ${resp.content}  $..success
#     Should Be Equal  ${success}  true  
#     ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
#     Should Be Equal  ${paymentStatus}  Authorized 
#     ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
#     Log  ${payment_id[0]}  

# Create Card Payment - Authorized based on $9.12 amount
#     ${params}  Create Dictionary  sessionid  ${session_id} 
#     Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":9.12,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
#     ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
#     Log  ${resp.content}
#     ${success}=  Get Items By Path  ${resp.content}  $..success
#     Should Be Equal  ${success}  true  
#     ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
#     Should Be Equal  ${paymentStatus}  Authorized 
#     ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
#     Log  ${payment_id[0]}  

Create Card Payment - Authorized based on $11.00 amount
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":11,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}  

Create Card Payment - Authorized based on $15 amount
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":15.0,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${paymentStatus}  Authorized 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]}  

# Create Card Payment - Authorized based on $15.01 amount
#     ${params}  Create Dictionary  sessionid  ${session_id} 
#     Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":15.01,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
#     ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
#     Log  ${resp.content}
#     ${success}=  Get Items By Path  ${resp.content}  $..success
#     Should Be Equal  ${success}  true  
#     ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
#     Should Be Equal  ${paymentStatus}  Authorized 
#     ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
#     Log  ${payment_id[0]}  

# Create Card Payment - Declined based on $6.32 amount (For CyberSource)
#     ${params}  Create Dictionary  sessionid  ${session_id} 
#     Set To Dictionary  ${params}  paymentTransactions  [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","ccAmount":6.32,"dispositionType":"","paymentType":"","achinvoicenumber":"","ccinvoicenumber":null,"achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achAmount":"","cvv":"999","achfeeschedule":"","ccfeeschedule":"${fee_schedule_id}","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","entcreditcardtype":4,"entbankaccounttype":"","routingnumber":"","expirydate":"12/20","ccpaymentdate":"08/29/2018","achpaymentdate":"","authCode":"","status":"","source":"","privileged":"","browserdate":"08/28/2018","achAuthType":"","customdata":{},"nameonaccount":"","nameoncard":"Card payal","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]
#     ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
#     Log  ${resp.content}
#     ${success}=  Get Items By Path  ${resp.content}  $..success
#     Should Be Equal  ${success}  true  
#     ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
#     Should Be Equal  ${paymentStatus}  Declined 
#     ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
#     Log  ${payment_id[0]} 

Create ACH Installment Payment
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  schedulepaymenttransactions  [{"paymentdate":"09/06/2018","lastUpdated":"","cardType":"","accountType":"","ccamount":"","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${ach_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Richard Rich","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":8,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":25,"ccbeginningbal":"","achbeginningbal":200,"achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","achtxnfrequencytype":1,"cctxnfrequencytype":"","firstpaymentwithfee":25,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":1,"entcreditcardtype":"","achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":200,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"09/06/2018","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    Log  ${params}
    ${resp}=  Post Request  adminSession  /sbps/paymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 

Create Installment Large ACH
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  schedulepaymenttransactions   [{"paymentdate":"09/06/2018","lastUpdated":"","cardType":"","accountType":"","ccamount":"","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${ach_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"Richard Rich","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":8,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":91999990,"ccbeginningbal":"","achbeginningbal":91999999,"achentfeeschedule":"${fee_schedule_id}","ccentfeeschedule":"","achtxnfrequencytype":1,"cctxnfrequencytype":"","firstpaymentwithfee":1999990,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":1,"entcreditcardtype":"","achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":91999999,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"09/06/2018","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 
    
Create CC Installment Payment for $6
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  schedulepaymenttransactions    [{"paymentdate":"09/06/2018","lastUpdated":"","cardType":"","accountType":"","ccamount":"10","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":2,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":10,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":1,"firstpaymentwithfee":6,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":10,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"09/06/2018","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 

Create CC Installment Payment for $5/Payment Expect Failure
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  schedulepaymenttransactions     [{"paymentdate":"09/06/2018","lastUpdated":"","cardType":"","accountType":"","ccamount":"100","dispositionType":"","paymentType":"","achinvoicenumber":null,"ccinvoicenumber":"","ccponumber":"","achponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","cvv":"","nameoncard":"","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","noofpayment":"","lastpaymentwithfee":"","paymentamount":"","achtotalamount":"","cctotalamount":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","recurrencetype":"Installment","txnachpayment_id":"","startdate":"","paymentspaid":"","totalpaymentstopay":20,"taxamountperpayment":"","feepercent":"","balanceamount":"","orginalamount":"","achamount":"","ccbeginningbal":100,"achbeginningbal":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","achtxnfrequencytype":"","cctxnfrequencytype":1,"firstpaymentwithfee":5,"achnumberpayments":"","ccnumberpayments":"","lastpayment":"","entbankaccounttype":"","entcreditcardtype":4,"achpaymentdate":"","ccpaymentdate":"","expirydate":"","totalamount":100,"authCode":"","fee":"","onetimeid":"","enteredby":"","txnCcPaymentStatus":"","browserdate":"09/06/2018","achAuthType":"written","customdata":{},"firstpaymentdate":"","billingstate":"","billingcity":"","billingaddress":"","billingpostalcode":"","declinedMessage":""}]
    ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${paymentStatus}  Get Items By Path  ${resp.content}  $..status 
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

Get Amortization Schedule
    ${stripped_payment_schedule_id}=  Remove String  ${payment_schedule_id}  "
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  50
    Set To Dictionary  ${params}  scheduleId  ${stripped_payment_schedule_id}
    ${resp}=  Get Request  adminSession  /sbps/paymentTransaction/xSchedulePaymentAmortizationDetails  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${status}=  Get Items By Path  ${resp.content}  $..status 
    Should Be Equal  ${status}  Declined
    
Get Payment Alerts
    ${stripped_payment_schedule_id}=  Remove String  ${payment_schedule_id}  "
    ${params}  Create Dictionary  sessionid  ${session_id} 
    ${resp}=  Get Request  adminSession  /sbps/home/xPaymentAlertSummary  params=${params}
    Log  ${resp.content}
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
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  id  ${stripped_payment_id} 
    Set To Dictionary  ${params}  paymenttxntype  CC
    Set To Dictionary  ${params}  externalid  ${stripped_payment_external_id} 
    ${resp}=  Get Request  adminSession  /sbps/paymentTransaction/xReadTransactionDetail  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${alertid_in}=  Get Items By Path  ${resp.content}  $..alertid 
    Should Be Equal  ${alertid_in}  ${alertid}  
    ${alertstatus_in}=  Get Items By Path  ${resp.content}  $..alertstatus 
    Should Be Equal  ${alertstatus_in}  2  
    ${processingaccountid_in}=  Get Items By Path  ${resp.content}  $..processingaccountid 
    Should Be Equal  ${processingaccountid_in}  ${processing_account_id}  
    
Create Recurring Payment    
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  schedulepaymenttransactions      [{"dateCreated":"","lastUpdated":"","cardType":"","accountType":"","amount":"","dispositionType":"","paymentType":"","achponumber":"","ccponumber":null,"taxamount":null,"paymentAccount_id":"${cc_pmt_acct_id}","achamount":"","cvv":"","achtxnfrequencytype":"","cctxnfrequencytype":1,"nameoncard":"Angela Gilbert","achmemo":"","ccmemo":"","achnotes":"","ccnotes":"","nameonaccount":"","orginalamount":"","balanceamount":"","feepercent":"","taxamountperpayment":"","totalpaymentstopay":1,"paymentspaid":"","startdate":"","achinvoicenumber":"","ccinvoicenumber":null,"emailnotes":"","isactive":"","lastpaymentid":"","netpaymentdate":"","externalid":"","audituserid":"","paymentdate":"09/06/2018","recurrencetype":"Recurring","paymentAccount":"","entfeeschedule":"","txnachpayment_id":"","entcreditcardtype":4,"entbankaccounttype":"","ccamount":"","ccpaymentdate":"","achpaymentdate":"","achentfeeschedule":"","ccentfeeschedule":"${fee_schedule_id}","expirydate":"11/19","firstpaymentwithfee":10,"browserdate":"09/06/2018","achAuthType":"","customdata":{},"firstpaymentdate":"","billingstate":null,"billingcity":null,"billingaddress":null,"billingpostalcode":null,"declinedMessage":""}]   ${resp}=  Post Request  adminSession  /sbps/installmentPaymentTransaction/xCreate  params=${params}
    ${resp}=  Get Request  adminSession  /sbps/recurringPaymentTransaction/xCreate  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    ${payment_id}=   Get Regexp Matches  ${resp.content}  "id":"?(.*?)"?,  1
    Log  ${payment_id[0]} 
    
Read Payment Schedules for ACH Customer
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  customer_id  ${ach_created_customer_id}
    Set To Dictionary  ${params}  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  10
    Set To Dictionary  ${params}  filter  [{"property":"customer_id","value":"${ach_created_customer_id}"}]
    ${resp}=  Get Request  adminSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactions  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  

Read Payment Schedules for CC Customer
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  customer_id  ${cc_created_customer_id}
    Set To Dictionary  ${params}  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  10
    Set To Dictionary  ${params}  filter  [{"property":"customer_id","value":"${cc_created_customer_id}"}]
    ${resp}=  Get Request  adminSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactions  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
                    
Update Payment Account
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  cardnumber  xxxxxxxxxxxx1111
    Set To Dictionary  ${params}  nameonaccount  Richard Richs
    Set To Dictionary  ${params}  accountname  Visa xxxxx1111
    Set To Dictionary  ${params}  expirymonth  11
    Set To Dictionary  ${params}  expiryyear  19
    Set To Dictionary  ${params}  paymentaccountid  ${cc_pmt_acct_id}
    Set To Dictionary  ${params}  status  Active
    Set To Dictionary  ${params}  accounttype  3
    ${resp}=  Get Request  adminSession  /sbps/paymentTransaction/xDataSchedulePaymentTransactions  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
                        
Read Customers
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  page  1
    Set To Dictionary  ${params}  start  0
    Set To Dictionary  ${params}  limit  10
    Set To Dictionary  ${params}  filter  [{"property":"entprocessingaccount_id","value":"${processing_account_id}"}]
    ${resp}=  Get Request  adminSession  /sbps/customerOrganization/xListCustomers  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true 

Display Email Settings
    ${params}  Create Dictionary  sessionid  ${session_id} 
    ${resp}=  Get Request  adminSession  /sbps/settings/xDisplayEmailSettings  params=${params}
    Log  ${resp.content}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    ${body}=  Get Json Response
    ${payment_receipt_emails_api}  Get Items By Path  ${resp.content}  $..merchants[?(@.name=='DHL Express')]
     Log  ${payment_receipt_emails_api}
    Should Contain  ${payment_receipt_emails_api}  PAYMENT_RECEIPT_EMAILS_API

Delete API Key
    ${params}  Create Dictionary  sessionid  ${session_id} 
    Set To Dictionary  ${params}  prcacctapiid  ${api_key_id}
    Set To Dictionary  ${params}  entProcessingAccountId  ${processing_account_id}
    ${resp}=  Get Request  adminSession  /sbps/settings/xDeleteApiKey  params=${params}
    ${success}=  Get Items By Path  ${resp.content}  $..success
    Should Be Equal  ${success}  true  
    Should Contain  ${resp.content}   "success":true,"errors"
    
Logout
    ${resp}=  Get Request  adminSession  /sbps/j_spring_security_logout
    ${body}=  Decode Bytes To String  ${resp.content}  UTF-8
    Should Contain  ${body}  Password