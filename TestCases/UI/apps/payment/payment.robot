*** Settings ***
Documentation    Creating a Customer and performing One time, Installment and Recurring Payment

Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary  
Library     DateTime                                                           
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
Test Teardown     Test Ui Teardown
Suite Teardown    Teardown Test Suite

*** Variables ***
${latency_time}  5s
#${card_processor_text}=        MONETRA
${card_processor_text}=        CYBERSOURCE

*** Keywords ***

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Payments')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV001
User Select Account Location
    Select Combobox Value JS       \#onetimepaymentcontainer > #accountlocationcombobox    Downtown

User Select Account Location in Settings tab
    Select Combobox Value JS    \#paymentsettingspanel > #accountlocationcombobox    Downtown

#User Select Account Location West Jordan
    #Select Combobox Value JS       \#onetimepaymentcontainer > #accountlocationcombobox    West Jordan

User clicks on Add customer button
    Click Ext Button JS     \#addcustomerbutton{isVisible(true)}  
    Wait Until Page Contains    Add New Customer      timeout=15s    
User clicks on create payment button  
    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
User Clicks Create Payment and Add more button
    Click Ext button JS    \#createpaymentandaddmorebutton{isVisible(true)}
Payment is successfully created
   Sleep    ${latency_time}
a Confirmation "Transaction has been processed successfully" appears
   Wait Until Page Contains     Transaction has been processed successfully!
   Click Ext button JS        \#closebutton{isVisible(true)}
Payment Schedule is successfully created 
    Wait Until Page Contains     The payment schedule was created successfully!       timeout=30 seconds    error=None 
Page Contains "The payment requested for today was processed successfully!"
    Page Should Contain        The payment requested for today was processed successfully!      loglevel=TRACE
    Click Ext button JS        \#closebutton{isVisible(true)}
    
Schdeule is created and "The payment schedule was created successfully!" appears 
    Wait Until Page Contains    The payment schedule was created successfully!      timeout=30 seconds    error=None 
    Click Ext button JS        \#closebutton{isVisible(true)}

User Selects Installment Tab and Select Account Location    
   Execute Javascript         var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
       ...                        installmentPaymentTab = Ext.ComponentQuery.query('#installmentpaymentcontainer')[0];
       ...                        tabPanel.setActiveTab(installmentPaymentTab);

   Select Combobox Value JS    \#installmentpaymentcontainer > #accountlocationcombobox    Downtown

     
User selects Recurring Tab and then Selects Account Location      
   Execute Javascript     var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
            ...               recurringPaymentTab = Ext.ComponentQuery.query('recurringpaymentcontainer')[0];
            ...               tabPanel.setActiveTab(recurringPaymentTab);
   
   Select Combobox Value JS    \#recurringpaymentcontainer > #accountlocationcombobox    Downtown
      
User creates an ACH customer
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                          ${customerid}
    ${first_name}=  First Name Male
    Set Textfield Value JS   \#addcustomerwindow #firstname                           ${first_name}John
    ${last_name}=  Last Name Male 
    Set Textfield Value JS   \#addcustomerwindow #lastname                            ${last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                            491 South Van
    Set Textfield Value JS   \#addcustomerwindow #city                                Wales   
    Set Textfield Value JS   \#addcustomerwindow #state                               FL
    Set Textfield Value JS   \#addcustomerwindow #postalcode                          24576-6642
    Sleep    ${latency_time}
    Set Textfield Value JS   \#addcustomerwindow #routingnumber                       011000015
    ${account_number}=  Generate Random String  length=10   chars=[NUMBERS]
    Set Textfield Value JS   \#addcustomerwindow #accountnumber                        ${account_number}
  
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    Sleep    ${latency_time}
    Set Textfield Value JS    \#addcustomerwindow #accountname                        UTF ACH Created ${month}${random_word}
    Set Textfield Value JS    \#addcustomerwindow #customername                       UTF ACH Created ${month}${random_word}
   ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                        ${phone_number}
    ${email_address}    Email    
    Set Textfield Value JS    \#addcustomerwindow #emailaddress                       ${email_address}
    Sleep    ${latency_time}
    Click Ext button JS    \#savebutton{isVisible(true)}
    Sleep    ${latency_time}
    Set Suite Variable    \${first_name}   ${first_name}John               

User creates a Business CC Customer     
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #business')[0].setValue(true);
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                        ${customerid}
    ${business_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #businessname                        ${business_name}Tom 
    Set Suite Variable    \${business_name}   ${business_name}Tom               
    ${contact_first_name}=  Name Female
    Set Textfield Value JS   \#addcustomerwindow #firstname                         ${contact_first_name}
    ${contact_last_name}=  Last Name Female    
    Set Textfield Value JS   \#addcustomerwindow #lastname                          ${contact_last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                          5800 NW 39th Avenue
    Set Textfield Value JS   \#addcustomerwindow #city                              Gainesville  
    Set Textfield Value JS   \#addcustomerwindow #state                             FL
    Set Textfield Value JS   \#addcustomerwindow #postalcode                        32606
    Sleep    ${latency_time}
    Select Combobox Value JS    \#addcustomerwindow #accounttypecombobox           Credit Card
    ${card_number}   Set Variable    4111111111111111
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #accountnumber')[1].setValue('${card_number}')
    Set Textfield Value JS    \#addcustomerwindow #expirymonth           11
    Set Textfield Value JS    \#addcustomerwindow #expiryyear            25
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${account_name}   Set Variable    UTF Card Created ${month}${random_word}
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #accountname")[1].setValue('${account_name}')
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #customername")[1].setValue('${account_name}')
    ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #emailaddress              ${email_address}@example.com
    Click Ext button JS    \#savebutton{isVisible(true)}
	Wait Until Page Contains                  Payment Information        timeout=20s
 

User creates CC Business customer with Invalid Address     
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #business')[0].setValue(true);
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                        ${customerid}
    ${business_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #businessname                        ${business_name}  
    Set Suite Variable    \${business_name}   ${business_name}                 
    ${contact_first_name}=  Name Female
    Set Textfield Value JS   \#addcustomerwindow #firstname                         ${contact_first_name}
    ${contact_last_name}=  Last Name Female    
    Set Textfield Value JS   \#addcustomerwindow #lastname                          ${contact_last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                          25 W. St Louis Drive
    Set Textfield Value JS   \#addcustomerwindow #city                              Miami   
    Set Textfield Value JS   \#addcustomerwindow #state                             FL
    Set Textfield Value JS   \#addcustomerwindow #postalcode                        33134
    Sleep    ${latency_time}
    Select Combobox Value JS    \#addcustomerwindow #accounttypecombobox           Credit Card
    ${card_number}   Set Variable    4111111111111111
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #accountnumber')[1].setValue('${card_number}')
    Set Textfield Value JS    \#addcustomerwindow #expirymonth           11
    Set Textfield Value JS    \#addcustomerwindow #expiryyear            25
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${account_name}   Set Variable    UTF Card Created ${month}${random_word}
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #accountname")[1].setValue('${account_name}')
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #customername")[1].setValue('${account_name}')
    ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #emailaddress              ${email_address}@example.com
    Click Ext button JS    \#savebutton{isVisible(true)}
	Wait Until Page Contains                  Payment Information        timeout=20s 
	
 User adds OTP details for an ACH Customer
    Sleep    ${latency_time}
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance    ${amount}.00
    Sleep    ${latency_time}
    Execute Javascript         Ext.ComponentQuery.query('#writtenauthorization')[0].setValue(true);
    Execute Javascript         Ext.ComponentQuery.query('#authorizationcheckbox')[0].setValue(true);
    

User adds ACH Payment Details for creating Weekly Installment schedule
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Weekly
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#installmentpaymentcontainer #beginningbalance    ${amount}.00
    Execute Javascript          Ext.ComponentQuery.query('#specialtytextfield')[1].setValue('10.00');
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[1].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[1].setValue(true);
	Sleep    ${latency_time}
    #Sleep    15s
    

User adds ACH Payment Details for creating 1st and 15th Installment schedule
    Sleep    ${latency_time}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency   1st and 15th
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#installmentpaymentcontainer #beginningbalance    ${amount}.00
    Execute Javascript          Ext.ComponentQuery.query('#specialtytextfield')[1].setValue('20.00');
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[1].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[1].setValue(true);
    

Add ACH Payment Details for Monthly
    Sleep    ${latency_time}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Monthly
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#installmentpaymentcontainer #beginningbalance    ${amount}.00
    Execute Javascript          Ext.ComponentQuery.query('#specialtytextfield')[1].setValue('30.00');
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[1].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[1].setValue(true);  
     
User adds Card Payment Details for creating Quarterly Installment schedule on a future date
    
    ${futureDate}     Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y  
    Sleep    ${latency_time}   
    Set Textfield Value JS    \#installmentpaymentcontainer #cvv              999
    Set Textfield Value JS    \#installmentpaymentcontainer #expirydate       11/25
    Set Textfield Value JS    \#installmentpaymentcontainer #paymentdate     ${futureDate}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Quarterly
    ${amount} =  Random Number    digits=3
    Sleep    ${latency_time}
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    ${amount}.00
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   30.00
    Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#installmentpaymentcontainer #taxamount          2  
	Sleep    ${latency_time}

 User adds Card Payment Details for creating Quarterly Recurring schedule
    Sleep    ${latency_time}
    Set Textfield Value JS    \#recurringpaymentcontainer #cvv              999
    Set Textfield Value JS    \#recurringpaymentcontainer #expirydate       11/25
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Quarterly
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2
	Sleep        15s
 User adds ACH Payment Details for creating Weekly Recurring schedule
    Sleep    ${latency_time}
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[2].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[2].setValue(true);  
	Sleep        15s
    
User adds Card Payment Details for Semi annually Recurring schedule
   Sleep    ${latency_time}
    Set Textfield Value JS    \#recurringpaymentcontainer #cvv               999
    Set Textfield Value JS    \#recurringpaymentcontainer #expirydate        11/25
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency       Semi-annually
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2  
    Sleep    ${latency_time}
User adds ACH Payment Details for 1st and 15th Recurring schedule
    ${amount} =  Random Number    digits=2
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency       1st and 15th
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2  
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[2].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[2].setValue(true);
    Sleep    ${latency_time}
User adds ACH Payment Details for Monthly Recurring schedule
    ${amount} =  Random Number    digits=2
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency       Monthly
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2  
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[2].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[2].setValue(true);
    Sleep    ${latency_time}
Add Card Payment Details for Annually
    Sleep    ${latency_time}
    Set Textfield Value JS    \#recurringpaymentcontainer #cvv                999
    Set Textfield Value JS    \#recurringpaymentcontainer #expirydate         11/25
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency        Annually
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber      111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder      11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2   

User adds Card Payment details for Annually Reccuring Schedule on a future date
    ${futureDate}     Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Sleep    ${latency_time}
    Set Textfield Value JS    \#recurringpaymentcontainer #cvv                999
    Set Textfield Value JS    \#recurringpaymentcontainer #expirydate         11/25
    Set Textfield Value JS     \#recurringpaymentcontainer #paymentdate    ${futureDate}
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency        Annually
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber      111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder      11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2 
    
User adds Card Payment Details for creating Semi-Annually Installment schedule
        
    Sleep    ${latency_time}   
    Set Textfield Value JS        \#installmentpaymentcontainer #cvv              999
    Set Textfield Value JS        \#installmentpaymentcontainer #expirydate       11/25
    Sleep    ${latency_time}
    Select Combobox Value JS      \#installmentpaymentcontainer #frequency      Semi-annually
    ${amount} =  Random Number    digits=3
    Sleep    ${latency_time}
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    ${amount}.00
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   100.00
    Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#installmentpaymentcontainer #taxamount          2 
User adds Card Payment Details for creating Annually Installment schedule  
    
    Sleep    ${latency_time}   
    Set Textfield Value JS    \#installmentpaymentcontainer #cvv              999
    Set Textfield Value JS    \#installmentpaymentcontainer #expirydate       11/25
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      Annually
    ${amount} =  Random Number    digits=3
    Sleep    ${latency_time}
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    ${amount}.00
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   100.00
    Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#installmentpaymentcontainer #taxamount          2

Users adds ACH OTP details for a future date
    ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Sleep    ${latency_time}
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance    ${amount}.00
    Set Textfield Value JS     \#onetimepaymentdate    ${futureDate}
    Set Textfield Value JS    \#onetimepaymentcontainer #invoicenumber      111
    Set Textfield Value JS    \\#onetimepaymentcontainer #purchaseorder      11
    Set Textfield Value JS    \\#onetimepaymentcontainer #taxamount          2 
    Sleep    ${latency_time}
    Execute Javascript         Ext.ComponentQuery.query('#writtenauthorization')[0].setValue(true);
    Execute Javascript         Ext.ComponentQuery.query('#authorizationcheckbox')[0].setValue(true);
    Sleep    ${latency_time}
    
User adds details for ACH monthly installment schedule on a future date
    ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Sleep    ${latency_time}
    Set Textfield Value JS     \#installmentpaymentcontainer #paymentdate    ${futureDate}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Monthly
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS      \#installmentpaymentcontainer #beginningbalance    ${amount}.00
    Execute Javascript          Ext.ComponentQuery.query('#specialtytextfield')[1].setValue('30.00');
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[1].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[1].setValue(true); 

User add OTP details for CC customer
    Sleep    ${latency_time}
    ${amount} =  Random Number    digits=3
    Set Textfield Value JS    \#onetimepaymentcontainer #cvv                999
    Set Textfield Value JS    \#onetimepaymentcontainer #expirydate         11/25
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance   ${amount}.00
    Set Textfield Value JS    \#onetimepaymentcontainer #invoicenumber      111
    Set Textfield Value JS    \\#onetimepaymentcontainer #purchaseorder      11
    Set Textfield Value JS    \\#onetimepaymentcontainer #taxamount          2 
    Sleep    15s
    #Sleep    ${latency_time}
    Click Ext button JS        \#createpaymentbutton{isVisible(true)}

User navigates to Settings tab 
    Select Navigation Tab    NV005
    	
User ensures Require CVV Check is enabled 	
    Wait Until Page Contains    Account Type Settings      timeout=30s   
    Sleep    ${latency_time} 
    ${condition}    Run Keyword And Return Status    Verify Checkbox Value    \#checkboxgroup #requirecvv    true
	Run Keyword If    ${condition} == False    Check Checkbox JS     \#checkboxgroup #requirecvv   
    Sleep    1s
	Click Ext Button JS    \#button > #savebutton{isVisible(true)}
	Wait Until Page Contains    Account type setting information saved successfully      timeout=10 seconds    error=None
	Click Ext Button JS    \#ok{isVisible(true)}
		
User ensures Require AVS Check is enabled 	
    Wait Until Page Contains    Account Type Settings      timeout=30s   
    Sleep    ${latency_time} 
    ${condition}    Run Keyword And Return Status    Verify Checkbox Value    \#checkboxgroup #requirecvv    true
	Run Keyword If    ${condition} == True    UnCheck Checkbox JS     \#checkboxgroup #requirecvv   
	${condition}    Run Keyword And Return Status   Verify Checkbox Value   \#checkboxgroup #requireavs    true
    Run Keyword If    ${condition} == False    Check Checkbox JS    \#checkboxgroup #requireavs
    Sleep    1s
	Click Ext Button JS    \#button > #savebutton{isVisible(true)}
	Wait Until Page Contains    Account type setting information saved successfully      timeout=10 seconds    error=None
	Click Ext Button JS    \#ok{isVisible(true)}

User navigates to Customers tab
	
	Select Navigation Tab    NV001
	Wait Until Page Contains    Customers    timeout=30s 
	

User adds OTP details for Invalid AVS Cybersource
    Sleep    ${latency_time}
	#Set Textfield Value JS    \#onetimepaymentcontainer #cvv                111
	Set Textfield Value JS    \#onetimepaymentcontainer #expirydate         11/25
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance  7005
    Set Textfield Value JS    \#onetimepaymentcontainer #invoicenumber      111
	Set Textfield Value JS    \\#onetimepaymentcontainer #purchaseorder      11
	Set Textfield Value JS    \\#onetimepaymentcontainer #taxamount          2 
	Sleep    ${latency_time}
	Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	
User adds OTP details for Invalid CVV Monetra 
    Sleep    ${latency_time}
	Set Textfield Value JS    \#onetimepaymentcontainer #cvv                111
	Set Textfield Value JS    \#onetimepaymentcontainer #expirydate         11/25
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance  100
    Set Textfield Value JS    \#onetimepaymentcontainer #invoicenumber      111
	Set Textfield Value JS    \\#onetimepaymentcontainer #purchaseorder      11
	Set Textfield Value JS    \\#onetimepaymentcontainer #taxamount          2 
	Sleep    ${latency_time}
	Click Ext button JS        \#createpaymentbutton{isVisible(true)}


User adds OTP details for Invalid CVV Cybersource
    Sleep    ${latency_time}
	Set Textfield Value JS    \#onetimepaymentcontainer #cvv                111
	Set Textfield Value JS    \#onetimepaymentcontainer #expirydate         11/25
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance  7005
    Set Textfield Value JS    \#onetimepaymentcontainer #invoicenumber      111
	Set Textfield Value JS    \\#onetimepaymentcontainer #purchaseorder      11
	Set Textfield Value JS    \\#onetimepaymentcontainer #taxamount          2 
	Sleep    ${latency_time}
	Click Ext button JS        \#createpaymentbutton{isVisible(true)}

User adds OTP details for Invalid AVS
    
    
    Run keyword if  '${card_processor_text}'=='MONETRA'        User add OTP details for CC customer
    ...   ELSE                                                 User adds OTP details for Invalid AVS Cybersource

User adds OTP details for Invalid CVV


    Run keyword if  '${card_processor_text}' == 'MONETRA'       User adds OTP details for Invalid CVV Monetra
    ...   ELSE                                                  User adds OTP details for Invalid CVV Cybersource

    
Payment gets declined
    Wait Until Page Contains    Payment Receipt    timeout=30s 
    Page Should Contain        Payment has been declined
    
Page Should contain response 'Address Verification Failed'
       Page Should Contain    Address Verification Failed        timeout=30s 
       Click Ext button JS        \#closebutton{isVisible(true)}  
                   
Page Should contain response 'Invalid Card Verification number'
       Page Should Contain    Invalid Card Verification Number (CVN).    timeout=30s 
       Click Ext button JS        \#closebutton{isVisible(true)}

User navigates to Customer tab
    
   Select Navigation Tab    NV002
   Wait Until Page Contains    Customers    timeout=10s  
   Sleep    20s  

User searches and selects ACH Customer
    
   Set Textfield Value JS    \#customercontainer #namesearchtextfield      ${first_name} 
   Sleep    5s
   Click Grid Row    \#customercontainer #customersgridpanel    firstname  ${first_name}
   
User searches and selects CC Customer
    Sleep    20s
    Set Textfield Value JS    \#customercontainer #namesearchtextfield      ${business_name} 
    Sleep    5s
    Click Grid Row    \#customercontainer #customersgridpanel    businessname  ${business_name} 

User selects an CC payment from the recent payments grid
    
    Click Grid Row Via Dom   \#recentpaymentsgridpanel    businessname       ${business_name} 
    Wait Until Page Contains   Transaction Details   timeout=10s 
    Sleep        3s

User selects an ACH payment from the recent payments grid  
    
   Click Grid Row Via Dom   \#recentpaymentsgridpanel    firstname       ${first_name}
   Wait Until Page Contains   Transaction Details   timeout=10s 
   Sleep        3s

User clicks void button
      
   Click Ext button JS   \button#voidbutton{isVisible(true)}
   Wait Until Page Contains    Are you sure? 
   Sleep    2s   

Payment gets successfully voided 
       
   Click Ext button JS           \button#ok{isVisible(true)}
   Wait Until Page Contains    Void    
   Sleep    2s
   Click Ext button JS        \#closebutton{isVisible(true)}
   Expand Panel     \#customercontainer #customersgridpanel
  
User selects payment tab 

  Select Navigation Tab    NV001
   

User navigates to Payments tab
	
	Wait Until Keyword Succeeds    15s    15s    Select Navigation Tab    NV001
	Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Customers    timeout=30s 


Converting to title-case
    ${Customfieldname}=    Convert To Lowercase    ${Customfieldname}
    ${Customfieldname}=    Convert To Title Case    ${Customfieldname}
    Log    ${Customfieldname}    console=yes 

Verifying the custom field   
    Sleep        3s
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${Customfieldname}    timeout=30s	

*** Test Cases ***

Create ACH One Time Payment
    [Tags]    Smoke    Regression
    Given User Select Account Location
	And User clicks on Add customer button
    And User creates an ACH customer
    And User adds OTP details for an ACH Customer
    When User clicks on create payment button  
    Then Payment is successfully created 
    And a Confirmation "Transaction has been processed successfully" appears
    
Create CC One Time Payment
    [Tags]    Smoke    Regression    
    Given User Select Account Location 
    And User clicks on Add customer button
    And User creates a Business CC Customer
    When User add OTP details for CC customer
    #When User clicks on create payment button  
    Then Payment is successfully created 
    And a Confirmation "Transaction has been processed successfully" appears

Void ACH Payment
   [Tags]    Smoke    Regression    

   Given User navigates to Customer tab 
   And User searches and selects ACH Customer
   And User selects an ACH payment from the recent payments grid
   When User clicks void button
   Then Payment gets successfully voided
   
Void CC Payment
    [Tags]    Smoke    Regression    

    Given User searches and selects CC Customer
    And User selects an CC payment from the recent payments grid 
    When User clicks void button
    Then Payment gets successfully voided
    
 Create future One Time Payment
    [Tags]        Regression
    Given User selects payment tab
    And User Select Account Location
    And User clicks on Add customer button
    And User creates an ACH customer
    And Users adds ACH OTP details for a future date
    When User clicks on create payment button  
    Then Payment is successfully created 
    And a Confirmation "Transaction has been processed successfully" appears
    
Decline Credit Card payment using Invalid CVV   
     [Tags]    Smoke    Regression	
	Given User Select Account Location
	And User navigates to Settings tab
    And User ensures Require CVV Check is enabled 
    And User navigates to Customers tab
    And User clicks on Add customer button
    And User creates a Business CC Customer 
	When User adds OTP details for Invalid CVV
    Then Payment gets declined
    And Page Should contain response 'Invalid Card Verification number' 

Decline Credit Card payment using Invalid AVS   
     [Tags]    Smoke    Regression
	Given User Select Account Location
	And User navigates to Settings tab
    And User ensures Require AVS Check is enabled 
    And User navigates to Customers tab
    And User clicks on Add customer button
    And User creates CC Business customer with Invalid Address
    When User adds OTP details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response 'Address Verification Failed'    

Create ACH Installment Payment - Weekly
    [Tags]    Smoke    Regression
    Given User Selects Installment Tab and Select Account Location
    And User clicks on Add customer button
    And User creates an ACH customer
    And User adds ACH Payment Details for creating Weekly Installment schedule
 	When User Clicks Create Payment and Add more button
 	Then Payment Schedule is successfully created 
 	And Page Contains "The payment requested for today was processed successfully!"

    #user will stay on payment page itself as we are using "Create payment and add more" option to do next payment.

Create ACH Installment Payment - 1st and 15th
    [Tags]    Smoke    Regression
   When User adds ACH Payment Details for creating 1st and 15th Installment schedule
   And User Clicks Create Payment and Add more button    
   Then Payment Schedule is successfully created 
   And Page Contains "The payment requested for today was processed successfully!"
    
Create ACH Installment Payment - Monthly(Future)
    [Tags]        Regression
    When User adds details for ACH monthly installment schedule on a future date
    And User clicks on create payment button   
    Then Schdeule is created and "The payment schedule was created successfully!" appears
    
Create CC Installment Payment - Quarterly (Future)
    [Tags]    Smoke    Regression
    
   Given User Selects Installment Tab and Select Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   When User adds Card Payment Details for creating Quarterly Installment schedule on a future date
   And User Clicks Create Payment and Add more button    
   Then Schdeule is created and "The payment schedule was created successfully!" appears    
 
Create CC Installment Payment - Semi-Annually
    [Tags]   Smoke     Regression
   
   When User adds Card Payment Details for creating Semi-Annually Installment schedule   
   And User Clicks Create Payment and Add more button    
   Then Schdeule is created and "The payment schedule was created successfully!" appears    

Create CC Installment Payment - Annually
    [Tags]   Smoke     Regression
    
   When User adds Card Payment Details for creating Annually Installment schedule   
   And User Clicks Create Payment and Add more button    
   Then Schdeule is created and "The payment schedule was created successfully!" appears 
    
Create ACH Reccuring Weekly 
     [Tags]        Regression
     Given User selects Recurring Tab and then Selects Account Location
     And User clicks on Add customer button
     And User creates an ACH customer
     And User adds ACH Payment Details for creating Weekly Recurring schedule
     When User Clicks Create Payment and Add more button
     Then Payment Schedule is successfully created 
     And Page Contains "The payment requested for today was processed successfully!"
     
Create ACH Reccuring 1st and 15th
    [Tags]        Regression
    When User adds ACH Payment Details for 1st and 15th Recurring schedule
    And User Clicks Create Payment and Add more button   
    Then Payment Schedule is successfully created 
    And Page Contains "The payment requested for today was processed successfully!"

Create ACH Reccuring Monthly
    [Tags]        Regression
    When User adds ACH Payment Details for Monthly Recurring schedule
    And User clicks on create payment button   
    Then Payment Schedule is successfully created 
    And Page Contains "The payment requested for today was processed successfully!"
    
Create Recurring CC Payment - Quarterly   
   [Tags]    Smoke    Regression
   Given User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   And User adds Card Payment Details for creating Quarterly Recurring schedule
   When User Clicks Create Payment and Add more button
   Then Payment Schedule is successfully created 
   And Page Contains "The payment requested for today was processed successfully!" 

Create Recurring CC Payment - Semi-annually 
   [Tags]    Smoke    Regression
  When User adds Card Payment Details for Semi annually Recurring schedule
  And User Clicks Create Payment and Add more button   
  Then Payment Schedule is successfully created 
  And Page Contains "The payment requested for today was processed successfully!"

Create Recurring CC Payment - Annually (Future)
   [Tags]    Smoke    Regression
   When User adds Card Payment details for Annually Reccuring Schedule on a future date
   And User clicks on create payment button   
   Then Schdeule is created and "The payment schedule was created successfully!" appears    
   

Verify Custom Data fields on One-Time Payment tab for Payment Information section 	
   [Tags]    Smoke    Regression
   Given User navigates to Settings tab
   When User Select Account Location in Settings tab
   And User Create Custom fields in payment Settings page
   When Converting to title-case
   And User navigates to Payments tab
   And User Select Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Verifying the custom field
   When User navigates to Settings tab   
   Then User Delete Custom field in Payment Settings Page
    
 

   
   
   


    