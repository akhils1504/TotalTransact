*** Settings ***
Documentation    Creating an Individual and a Business Customer with ACH and CC payment accounts and Search for a specific customer and multiple operations for scheduled payments

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
${latency_time}  20s
# ${refresh_btn}         (//span[@class="x-btn-icon-el x-tbar-loading "])[2]

*** Keywords ***

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Customers')]    timeout=30 seconds    error=None
    Select Navigation Tab  NV002

User Select Account Location
    Select Combobox Value JS    \#customercontainer > #accountlocationcombobox    Downtown
    
User navigates to Customers tab 
    
    Sleep    20s
 	Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Customers')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV002
    Sleep    20s
    
User selects a Customer
   Wait Until Page Contains    Customers    timeout=10s    
   Click Grid Row    \#customercontainer #customersgridpanel    firstname  ${first_name}

User enters firstname ${first_name} in the customer search box 
    
    Wait Until Page Contains    Customers    timeout=10s    
    Set Textfield Value JS    \#customercontainer #namesearchtextfield      ${first_name}
    Sleep        25s


User enters businessname ${business_name} in the customer search box
    
    Wait Until Page Contains    Customers    timeout=10s 
    Set Textfield Value JS    \#customercontainer #namesearchtextfield    ${business_name} 
    Sleep        25s
    
User selects the Customer with firstname ${first_name}
    Click Grid Row    \#customercontainer #customersgridpanel    firstname  ${first_name}
 
 
User selects the Customer with businessname ${business_name}
    Click Grid Row    \#customercontainer #customersgridpanel    businessname  ${business_name}           
        

             
User confirms that Customer with firstname ${first_name} exists
    Wait Until Keyword Succeeds    30s    200ms   Individual Customer Field Value Validation   ${first_name}
    Expand Panel     \#customercontainer #customersgridpanel
And User Wait Until Page Contains Customer Information
    Wait Until Page Contains   Customer Information
    Expand Panel     \#customercontainer #customersgridpanel
    
User selects a Business Customer
	Wait Until Page Contains    Customers    timeout=30s    
    Click Grid Row    \#customercontainer #customersgridpanel    businessname    ${business_name}
   
User clicks on Add customer button
    Wait Until Page Contains   Customers
	Click Ext Button JS     \#addcustomerbutton{isVisible(true)}
	Wait Until Page Contains   Add New Customer     timeout=30 seconds    error=None
User Clicks on "View all" Customers button
    Wait Until Page Contains    Customers   timeout=10s
    Click Ext button JS     \#viewcustomersbutton{isVisible(true)}
User Selects first customer from grid
    Click Grid Row First Element    \#customercontainer #customersgridpanel
    Wait Until Page Contains    Customer Information  timeout=10s
User is updated
    Click Ext button JS    button#ok{isVisible(true)}
A Confirmation "Changes Saved Successfully" appears
    Wait Until Page Contains    Changes Saved Successfully     timeout=10s
    # Sleep  ${latency_time}
    Expand Panel  \#customercontainer #customersgridpanel

	
User Add ACH Customer Information
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                          ${customerid}
    ${first_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #firstname                           ${first_name}
    Set Suite Variable    \${first_name}    ${first_name} 
    ${last_name}=  Generate Random String  length=10   chars=[LETTERS]    
    Set Textfield Value JS   \#addcustomerwindow #lastname                            ${last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                            10 W 600 N
    Set Textfield Value JS   \#addcustomerwindow #city                                Newton   
    Set Textfield Value JS   \#addcustomerwindow #state                               UT
    Set Textfield Value JS   \#addcustomerwindow #postalcode                          84041
    Set Textfield Value JS   \#addcustomerwindow #routingnumber                       011000015
    ${account_number}=  Generate Random String  length=10   chars=[NUMBERS]
    Set Textfield Value JS   \#addcustomerwindow #accountnumber                        ${account_number}
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${ach_account_name}   Set Variable    Selenium ACH Created ${month}${random_word}
    Set Textfield Value JS    \#addcustomerwindow #accountname                        Selenium ACH Created ${month}${random_word} 
    Set Textfield Value JS    \#addcustomerwindow #customername                       Selenium ACH Created ${month}${random_word}  
    Set Suite Variable     \${ach_account_name}    ${ach_account_name}    
    ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                        ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #emailaddress                       ${email_address}@example.com
    Sleep    2s
    Click Ext button JS       \#savebutton{isVisible(true)}
	
User Adds ACH Customer Information
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                          ${customerid}
    ${customer_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #firstname                           ${customer_name}
    Set Suite Variable    \${customer_name}    ${customer_name}  
    ${last_name}=  Generate Random String  length=10   chars=[LETTERS]    
    Set Textfield Value JS   \#addcustomerwindow #lastname                            ${last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                            10 W 600 N
    Set Textfield Value JS   \#addcustomerwindow #city                                Newton   
    Set Textfield Value JS   \#addcustomerwindow #state                               UT
    Set Textfield Value JS   \#addcustomerwindow #postalcode                          84041
    Set Textfield Value JS   \#addcustomerwindow #routingnumber                       011000015
    ${account_number}=  Generate Random String  length=10   chars=[NUMBERS]
    Set Textfield Value JS   \#addcustomerwindow #accountnumber                        ${account_number}
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${ach1_account_name}   Set Variable    Selenium ACH Created ${month}${random_word}
    Set Textfield Value JS    \#addcustomerwindow #accountname                        Selenium ACH Created ${month}${random_word} 
    Set Textfield Value JS    \#addcustomerwindow #customername                       Selenium ACH Created ${month}${random_word}  
    Set Suite Variable     \${ach1_account_name}    ${ach1_account_name}    
    ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                        ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #emailaddress                       ${email_address}@example.com
    Click Ext button JS       \#savebutton{isVisible(true)}
	Wait Until Page Contains       Payment Information        timeout=20s
 
    
User add CC Customer Information
   
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #customertyperadiogroup')[0].items.items.filter(i=> i.itemId === 'business')[0].setValue(true);
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                        ${customerid}
    ${business_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #businessname                      ${business_name}
    Set Suite Variable    \${business_name}    ${business_name}   
    ${contact_first_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #firstname                         ${contact_first_name}
    ${contact_last_name}=  Generate Random String  length=10   chars=[LETTERS]    
    Set Textfield Value JS   \#addcustomerwindow #lastname                          ${contact_last_name}
    Set Textfield Value JS   \#addcustomerwindow #address1                          491 South Van
    Set Textfield Value JS   \#addcustomerwindow #city                              Wales    
    Set Textfield Value JS   \#addcustomerwindow #state                             FL
    Set Textfield Value JS   \#addcustomerwindow #postalcode                        24576-6642
    Sleep  2s
    Select Combobox Value JS    \#addcustomerwindow #accounttypecombobox           Credit Card
    ${card_number}   Set Variable    4111111111111111
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #accountnumber')[1].setValue('${card_number}')
    Set Textfield Value JS    \#addcustomerwindow #expirymonth           11
    Set Textfield Value JS    \#addcustomerwindow #expiryyear            25
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${account_name}   Set Variable    Selenium Card Created ${month}${random_word}
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #accountname")[1].setValue('${account_name}')
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #customername")[1].setValue('${account_name}')
    Set Suite Variable     \${account_name}    ${account_name}
    ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #emailaddress              ${email_address}@example.com

User add ACH Payment Account
	Wait Until Page Contains   Customer Information    timeout=10s
	Click Ext button JS    \#addnewbutton{isVisible(true)}
	Wait Until Page Contains    Add Payment Account
	
User add CC Payment Account
	Wait Until Page Contains   Payment Accounts    timeout=10s
	#Clicking on Add Payment Account Button
	Click Ext button JS    \#addnewbutton{isVisible(true)}
	Wait Until Page Contains    Add Payment Account
		
ACH Payment Account is added successfully	
    
	Wait Until Page Contains    The payment account was added successfully
	Click Ext button JS    button#ok{isVisible(true)}
    Wait Until Page Contains    Payment Accounts
	#Validation against Payment Account
    Wait Until Page Contains   Payment Accounts    timeout=30s
		
CC Payment Account is added successfully
    		
	Wait Until Page Contains    The payment account was added successfully   timeout=30 seconds
	Click Ext button JS    button#ok{isVisible(true)}
	Wait Until Page Contains    Payment Accounts  timeout=10s

added ACH Payment Account is validated 	

	Click Grid Row Via Cellclick  \#achaccountsgridpanel      name    ${account_name}
	Wait Until Page Contains    Edit payment account
	Wait Until Keyword Succeeds    30s    200ms    ACH Payment Account Field Value Validation   ${account_name}
	Click Ext button JS     button#cancelbutton{isVisible(true)} 
	Sleep   10s
	Expand Panel     \#customercontainer #customersgridpanel
						
added CC Payment Account is validated 	
	
	#Validation against Payment Account
	Click Grid Row Via CellClick  \#ccaccountsgridpanel      name    ${account_name}
	Wait Until Page Contains    Edit payment account
	#Validating the field value
	Wait Until Keyword Succeeds    30s    200ms    CC Payment Account Field value Validation   ${account_name}
	Click Ext button JS     button#cancelbutton{isVisible(true)}
	Expand Panel     \#customercontainer #customersgridpanel
				
User Enter ACH Payment Details
    Set Textfield Value JS    \#routingnumber    011000015
    ${account_number}=  Generate Random String  length=10   chars=[NUMBERS]
    Set Textfield Value JS   \#accountnumber                        ${account_number}
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${account_name}   Set Variable    Selenium ACH Created ${month}${random_word}
    Set Textfield Value JS    \#accountname           Selenium ACH Created ${month}${random_word}
    Set Suite Variable     \${account_name}    ${account_name}
    Sleep  ${latency_time}
    Click Ext button JS      \#buttontoolbar #addbutton

User Enter CC Payment Details
    Sleep  ${latency_time}
    Select Combobox Value JS    \#accounttypecombobox           Credit Card
    ${card_number}   Set Variable    4111111111111111
    Execute Javascript    Ext.ComponentQuery.query('#accountnumber')[1].setValue('${card_number}')
    Sleep    2s
    ${month}=       Generate Random String  length=3  chars=[NUMBERS]
    ${random_word}=      Generate Random String  length=3  chars=[LETTERS]
    ${account_name}   Set Variable    Selenium Card Created ${month}${random_word}
    Sleep    2s
    Set Textfield Value JS    \#accountname           Selenium Card Created ${month}${random_word}
    Execute Javascript    Ext.ComponentQuery.query("#accountname")[1].setValue('${account_name}')
    Set Suite Variable     \${account_name}    ${account_name}  
    Sleep    2s
    Set Textfield Value JS    \#expirymonth           11
    Set Textfield Value JS    \#expiryyear            25
    Sleep    2s
    Click Ext button JS      \#buttontoolbar #addbutton  
    
 User Selects an ACH Payment Account
			
	Wait Until Page Contains   Payment Accounts    timeout=10s
    Click Grid Row Via CellClick  \#achaccountsgridpanel      name   ${ach_account_name}
 
User Updates the Name and Routing number of Payment Account
		
	Wait Until Page Contains    Edit payment account
	${name}    Name Male  #generating faker data for name
	Sleep   5s
	Set Textfield Value JS       \#checkingformpanel #customername     ${name}
	Set Textfield Value JS       \#checkingformpanel #routingnumber    011103093  
	Sleep        2s          
	Click Ext button JS           \#updatebutton{isVisible(true)}
	        
User Selects ACH Payment account 
    Wait Until Page Contains   Payment Accounts    timeout=10s
    Click Grid Row Via CellClick  \#achaccountsgridpanel      name   ${ach_account_name}
User waits until Page contains Edit payment account
     Wait Until Page Contains    Edit payment account
     Sleep        4s
 User Inactivates the payment account
    Select Combobox Value JS    \#paymentaccountstatus       InActive
    Sleep    2s
    Click Ext button JS           \#updatebutton{isVisible(true)}
Payment Account is scuccessfully Inactivated
    Wait Until Page Contains        Are You sure you want to deactivate this payment account?    timeout=30s
    Sleep    2s
    Click Ext button JS           \button#ok{isVisible(true)}
User updates Customer name and account number
    
    Wait Until Page Contains    Edit payment account
	${name}    Name Male  #generating faker data for name
	Sleep     5s
	Set Textfield Value JS       \#ccformpanel #customername             ${name}
	Set Textfield Value JS       \#ccformpanel #accountnumber            5454545454545454   
    #Set Textfield Value JS       \#ccformpanel #accountname              ${name}
    Sleep        2s          
	Click Ext button JS           \#updatebutton{isVisible(true)}
	
Then Payment Account is succcesfully edited
	
	Wait Until Page Contains        Are you sure?    timeout=10s
	Click Ext button JS           \button#ok{isVisible(true)}
				
a Confirmation "The payment account was updated successfully " appears
	
	Wait Until Page Contains        The payment account was updated successfully     timeout=40s
	# Sleep        10s
	Click Ext button JS           \button#ok{isVisible(true)}
	Expand Panel     \#customercontainer #customersgridpanel
	
User clicks on Save button
	
	Sleep      5s
	Click Ext button JS    \#savebutton{isVisible(true)}
	
	
Individual Customer Field Value Validation
    [Arguments]          ${expectedCustomerName}
    ${existingCustomerName}=    Get Textfield Value JS    \#customercontainer #firstname
    Should Be Equal      ${expectedCustomerName}          ${existingCustomerName}
    Pretty Print    ${expectedCustomerName}
    Pretty Print    ${existingCustomerName}
	
Individual customer is created succesfully
	
	Wait Until Page Contains    Created a Customer     timeout=10s
	Click Ext button JS    button#ok{isVisible(true)}
	Wait Until Page Contains    Customers     timeout=10s
				#Validation against created Customer - #To ensure created customer does exist
	Click Grid Row    \#customercontainer #customersgridpanel    firstname  ${first_name}
				#Validating whether the created customer name matches
	Wait Until Keyword Succeeds    30s    200ms   Individual Customer Field Value Validation   ${first_name}
	Pretty Print    ${first_name}
				#Returning to Customer GridPanel
	Expand Panel      \#customercontainer #customersgridpanel	

Business Customer Field Value Validation
    [Arguments]          ${expectedBusinessCustomerName}
    ${existingBusinessCustomerName}=    Get Textfield Value JS    \#customercontainer #businessname
    Should Be Equal      ${expectedBusinessCustomerName}          ${existingBusinessCustomerName}
    Pretty Print    ${expectedBusinessCustomerName}
    Pretty Print    ${existingBusinessCustomerName}
				
 business customer is created succesfully	
			 
	Wait Until Page Contains    Created a Customer    timeout=40s
	Click Ext button JS    button#ok{isVisible(true)}
    Wait Until Page Contains    Customers     timeout=10s
	#Validation against created Customer - #To ensure created customer does exist
	Click Grid Row    \#customercontainer #customersgridpanel    businessname    ${business_name}
	Wait Until Keyword Succeeds    30s    200ms   Business Customer Field Value Validation   ${business_name}
	Pretty Print    ${business_name}
	Expand Panel       \#customercontainer #customersgridpanel

    
CC Payment Account Field value Validation
    [Arguments]          ${expectedCCAccountName}
    ${currentCCAccountName}=    Get Textfield Value JS    \#accountname
    Should Be Equal      ${expectedCCAccountName}          ${currentCCAccountName}
    Pretty Print    ${expectedCCAccountName}
    Pretty Print    ${currentCCAccountName}
    Set Suite Variable     \${currentCCAccountName}        ${currentCCAccountName}
ACH Payment Account Field Value Validation
    [Arguments]          ${expectedACHAccountName}
    ${currentACHAccountName}=    Get Textfield Value JS    \#accountname
    Should Be Equal      ${expectedACHAccountName}          ${currentACHAccountName}
    Pretty Print    ${expectedACHAccountName}
    Pretty Print    ${currentACHAccountName}

User searches a Customer
    
	Wait Until Page Contains    Customers   timeout=10s
	Sleep    ${latency_time}
	Set Textfield Value JS    \#customercontainer #namesearchtextfield      ${first_name}
	
User selects the Customer and inactivates it
    
    Click Grid Row    \#customercontainer #customersgridpanel    firstname  ${first_name}
    Select Combobox Value JS    \#customercontainer customerinformationpanel #status        InActive
    Click Ext button JS    \#savechangesbutton{isVisible(true)}

Customer is inactivated
    
    Wait Until Page Contains    Are you Sure? All pending payments will process. Any Future scheduled payments will be cancelled;              
    Click Ext button JS    button#ok{isVisible(true)}
    Expand Panel  \#customercontainer #customersgridpanel
    
    
User verifies that Customer is InActive 
    
    User Select Account Location
    Wait Until Page Contains    Customers   timeout=10s
    Set Textfield Value JS    \#customercontainer #namesearchtextfield        ${first_name}
    Sleep            ${latency_time} 
    # Click Element    ${refresh_btn}      #refresh button
    Click Grid Row    \#customercontainer #customersgridpanel    firstname     ${first_name}
    Wait Until Keyword Succeeds    30s    200ms  Customer status   InActive
    Expand Panel  \#customercontainer #customersgridpanel

    
			    
User Updates Some fields of Customer
    ${street_name}    Street Address
    Set Textfield Value JS   \#customercontainer customerinformationpanel #address1                            ${street_name}
    ${city_text}    City
    Set Textfield Value JS   \#customercontainer customerinformationpanel #city                                ${city_text}      
    ${state_text}   State Abbr    
    Set Textfield Value JS   \#customercontainer customerinformationpanel #state                               ${state_text}
    ${zip_code_text}    Zipcode
    Set Textfield Value JS   \#customercontainer customerinformationpanel #postalcode                          ${zip_code_text}
    ${email_address_text}    Email    
    Set Textfield Value JS   \#customercontainer customerinformationpanel #emailaddress                        ${email_address_text}
    ${phone_number}    Generate Random String  length=10   chars=[NUMBERS]
    Set Textfield Value JS  \#customercontainer customerinformationpanel #phonenumber    ${phone_number}
    Click Ext button JS    \#customercontainer #savechangesbutton{isVisible(true)} 
    Sleep  4s
    
Customer is successfully updated 
    
   # Sleep   ${latency_time}
   Click Ext button JS    button#ok{isVisible(true)}
 A Confirmation 'Changes Saved Successfully' appears
    Wait Until Page Contains    Changes Saved Successfully     timeout=20s
    Sleep  1s
    Expand Panel  \#customercontainer #customersgridpanel
    
Customer status
    [Arguments]          ${ExpectedStatus}
    ${CurrentStatus}=    Execute Javascript   return Ext.ComponentQuery.query('#customercontainer customerinformationpanel #status')[0].getRawValue()
    Should Be Equal      ${ExpectedStatus}          ${CurrentStatus}
    
User Selects CC payment account 
    Wait Until Page Contains   Payment Accounts    timeout=10s
    Click Grid Row Via CellClick  \#ccaccountsgridpanel       name   ${currentCCAccountName} 

 User navigates to Payments tab
    
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Payments')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV001
    
User Waits Until Page Contains Scheduled Payments Information 
	
	Sleep    ${latency_time}   
    Wait Until Page Contains   Scheduled Payments   timeout=10s
    

User selects the scheduled payment
    Click Grid Row Via Dom   \#scheduledpaymentsgridpanel    paymentaccount       ${ach_account_name} 
    Wait Until Page Contains   Payment Schedule Details   timeout=10s 
    Sleep    ${latency_time}



User clicks on Update next payment date button
	
    Click Ext button JS           \#updatenextpaymentdatebutton{isVisible(true)}


	
User modifies the next scheduled payment date 
	
     ${today}      Get Current Date    result_format=%m/%d/%Y
     ${modified_date}  Add Time To Date   ${today}   9d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
     Sleep    ${latency_time} 
     Execute Javascript    Ext.ComponentQuery.query('#nextpaymentdatewindow #nextpaymentdate')[0].setValue('${modified_date}');
	 
    
User clicks on modify button
       
    Sleep    ${latency_time} 
    Click Ext button JS       \#buttontoolbar #modifybutton{isVisible(true)}
    
User click on ok button 
	
     Sleep    ${latency_time} 
     Wait Until Page Contains   Confirm   timeout=10s
     Click Ext button JS        \#ok{isVisible(true)}
     
a Confirmation "Your requested schedule dates have been updated" appears	 
     Sleep    ${latency_time} 
     Wait Until Page Contains   Your requested schedule dates have been updated.  timeout=30 seconds    error=None 
     Click Ext button JS        \#ok{isVisible(true)}
     # Click Ext button JS        \#closebutton{isVisible(true)}
     
User clicks on Add extra payment button
	
        Sleep   ${latency_time}
        Click Ext button JS           \#addextrapaymentbutton{isVisible(true)}
        
User enters Extra Payment Amount for CC Schedule
         
        #${amount} =  Random Number    digits=2
        ${amount}=  Generate Random String  length=2   chars=[NUMBERS]
        Set Textfield Value JS      \#extrapaymentwindow #cvv   999
        Set Textfield Value JS       \#extrapaymentwindow #amount   ${amount}.00
        Sleep   10s
User enters Extra Payment Amount
         
        #${amount} =  Random Number    digits=2
        ${amount}=  Generate Random String  length=2   chars=[NUMBERS]
        Set Textfield Value JS       \#extrapaymentwindow #amount   ${amount}.00
        Sleep   ${latency_time}
 
User enters Extra Payment Amount for future date
    
        ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
        ${amount}=  Generate Random String  length=1   chars=[NUMBERS]
        Set Textfield Value JS       \#extrapaymentwindow #amount   ${amount}.00
        Set Textfield Value JS     \#extrapaymentwindow #paymentdate    ${futureDate}
        Sleep   ${latency_time}
     
User enters Extra Payment Amount for future date for CC Schedule
    
        ${futureDate}    Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
        ${amount}=  Generate Random String  length=1   chars=[NUMBERS]
        Set Textfield Value JS      \#extrapaymentwindow #cvv   999
        Set Textfield Value JS       \#extrapaymentwindow #amount   ${amount}.00
        Set Textfield Value JS     \#extrapaymentwindow #paymentdate    ${futureDate}
        Sleep   ${latency_time}
         
Extra Payment is created for Schedule 
        
        Sleep   10s
        Click Ext button JS         \button#createextrapaymentbutton{isVisible(true)}
        Wait Until Page Contains   Extra Payment Receipt   timeout=10s 
        Sleep  ${latency_time}
        Wait Until Keyword Succeeds    20s  20ms            Wait Until Ext Element Is Enabled    \#closebutton
        Click Ext button JS         \#extrapaymentreceiptid #closebutton{isVisible(true)}
  
User clicks on Create Extra Payment button 
        Click Ext button JS         \button#createextrapaymentbutton{isVisible(true)}
        Wait Until Page Contains   Extra Payment Receipt   timeout=10s 
        Sleep  ${latency_time}
        Wait Until Keyword Succeeds    20s  20ms            Wait Until Ext Element Is Enabled    \#closebutton
        Click Ext button JS         \#extrapaymentreceiptid #closebutton{isVisible(true)}   
              
User clicks on Extra Payment button
    
        Sleep   10s
        Click Ext button JS         \button#createextrapaymentbutton{isVisible(true)}
        Sleep   10s 
        Click Ext button JS         \button#ok{isVisible(true)}
        #Wait Until Page Contains   Extra Payment Receipt   timeout=10s 


a confirmation that extra payment has been successfully scheduled appears
        Wait Until Page Contains   Extra Payment    timeout=10s
        Sleep  ${latency_time}
        #Wait Until Keyword Succeeds    20s  20ms            Wait Until Ext Element Is Enabled    \#closebutton
        #Click Ext button JS         \#extrapaymentreceiptid #closebutton{isVisible(true)}
         Click Ext button JS    \button#ok{isVisible(true)}
            
     
User Selects Installment Tab and Select Account Location
    
     Execute Javascript         var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
       ...                        installmentPaymentTab = Ext.ComponentQuery.query('#installmentpaymentcontainer')[0];
       ...                        tabPanel.setActiveTab(installmentPaymentTab);
    Select Combobox Value JS       \#installmentpaymentcontainer> #accountlocationcombobox   Downtown
   

User adds ACH Payment Details for creating Weekly Installment schedule
    Wait Until Page Contains       Payment Information        timeout=20s
    Sleep    ${latency_time}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Weekly
    #${amount} =  Random Number    digits=3
    ${amount}=  Generate Random String  length=3   chars=[NUMBERS]
    Set Textfield Value JS      \#installmentpaymentcontainer #beginningbalance    ${amount}.00
    Execute Javascript          Ext.ComponentQuery.query('#specialtytextfield')[1].setValue('50.00');
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[1].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[1].setValue(true);
	Sleep    ${latency_time}
User clicks on create payment button  
    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
    Sleep    ${latency_time}

User Clicks Create Payment and Add more button
    Sleep    ${latency_time}
    Click Ext button JS    \#createpaymentandaddmorebutton{isVisible(true)}

Payment Schedule is successfully created 
    Wait Until Page Contains     The payment schedule was created successfully!       timeout=30 seconds    error=None 

Page Contains "The payment requested for today was processed successfully!"
    Page Should Contain        The payment requested for today was processed successfully!      loglevel=TRACE
    Click Ext button JS        \#closebutton{isVisible(true)}
    Sleep        15s
User adds ACH Payment Details for creating Weekly Recurring schedule
    
  
    Sleep    ${latency_time}
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency     Weekly
    ${amount} =  Random Number    digits=3
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[2].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[2].setValue(true);  
	Sleep        15s


User selects Recurring Tab and then Selects Account Location      
   Execute Javascript     var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
            ...               recurringPaymentTab = Ext.ComponentQuery.query('recurringpaymentcontainer')[0];
            ...               tabPanel.setActiveTab(recurringPaymentTab);
   
   Select Combobox Value JS    \#recurringpaymentcontainer > #accountlocationcombobox    Downtown
   
 Given User is on Payment schedule details window
     Sleep        3s
User clicks on Inactivate Schedule button	
    Wait Until Page Contains    Inactivate Schedule or Undo Inactivation    timeout=30s    
    Click Ext button JS           \#inactivateschedulebutton{isVisible(true)}
    Sleep    2s
User enters a future Inactivation date
    ${futureDate}     Add Time To Date   ${today}    5d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y  
     Set Textfield Value JS      \#inactivatedatefield     ${futureDate} 

 User Clicks on Update button
    Sleep    2s
    Click Ext button JS    \#inactivatebutton{isVisible(true)}
    Wait Until Page Contains    Are You sure you want to deactivate this Payment?    
    Click Ext button JS    button#ok{isVisible(true)} 

 Payment schedule Inactivation is scheduled for a future date
    Wait Until Page Contains    Payments before the final payment date will process.   
    Sleep    2s 
    Click Ext button JS    button#ok{isVisible(true)} 
 User clicks on Cancel Termination button
   Sleep    2s
   Click Ext button JS    \#cancelterminationbutton{isVisible(true)}
   Wait Until Page Contains    Cancel the future inactivation and return the future payments to pending.  
   Click Ext button JS    button#ok{isVisible(true)} 

Future payment schedule Inactivation is cancelled  
    Wait Until Page Contains    The future payments have been reverted to pending status    
    Sleep    2s
    Click Ext button JS    button#ok{isVisible(true)}
 User clicks Inactivate Now button
    Sleep    2s
    Click Ext button JS         \#inactivatenowbutton{isVisible(true)}
    Wait Until Page Contains    Are You sure you want to deactivate this Payment? All pending payments will process.Any Future scheduled payments will be cancelled    
    Click Ext button JS    button#ok{isVisible(true)} 

All future payments of the schedule is terminated
     Wait Until Page Contains    All future payments for this schedule have been terminated, and the schedule was marked as inactive.
     Sleep    2s
     Click Ext button JS    button#ok{isVisible(true)}
     Click Ext button JS        \#closebutton{isVisible(true)}
     Sleep  10s
 
 
User creates a Business CC Customer     
    Execute Javascript    Ext.ComponentQuery.query('#addcustomerwindow #business')[0].setValue(true);
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                         ${customerid}
    ${business_name}=  Generate Random String  length=10   chars=[LETTERS]
    Set Textfield Value JS   \#addcustomerwindow #businessname                        ${business_name}  
    Set Suite Variable    \${business_name}   ${business_name}                 
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
    Set Suite Variable    \${account_name}    ${account_name} 
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #accountname")[1].setValue('${account_name}')
    Execute Javascript    Ext.ComponentQuery.query("#addcustomerwindow #customername")[1].setValue('${account_name}')
    ${phone_number}=  Generate Random String   length=10  chars=[NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #phonenumber                ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Set Textfield Value JS    \#addcustomerwindow #emailaddress              ${email_address}@example.com
    Click Ext button JS    \#savebutton{isVisible(true)}
	Wait Until Page Contains                  Payment Information        timeout=20s
 
 
 
User adds Card Payment Details for creating Quarterly Installment schedule on a future date
    
    ${futureDate}     Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y  
    Sleep    ${latency_time}   
    Set Textfield Value JS    \#installmentpaymentcontainer #cvv              999
    Set Textfield Value JS    \#installmentpaymentcontainer #expirydate       11/25
    Set Textfield Value JS    \#installmentpaymentcontainer #paymentdate     ${futureDate}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Quarterly
    #${amount} =  Random Number    digits=3
    ${amount}=  Generate Random String  length=3   chars=[NUMBERS]
    Sleep    ${latency_time}
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    ${amount}.00
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   30.00
    Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#installmentpaymentcontainer #taxamount          2  
	Sleep    ${latency_time}
 

User selects the scheduled CC payment
    Click Grid Row Via Dom   \#scheduledpaymentsgridpanel    paymentaccount       ${account_name}
    Wait Until Page Contains   Payment Schedule Details   timeout=10s 
    Sleep    ${latency_time} 

 User clicks on View Installment Schedule
    
     
        Click Ext button JS   \button#viewamortizationschedulebutton{isVisible(true)}
        Wait Until Page Contains   Installment Schedule   timeout=10s 
            
User clicks on Update Fee button
    Click Ext button JS    button#updateScheduleFeeButton{isVisible(true)}
    
User adds Card Payment Details for creating Weekly Recurring schedule
    Sleep    5s
    Set Textfield Value JS    \#recurringpaymentcontainer #cvv              999
    Set Textfield Value JS    \#recurringpaymentcontainer #expirydate       11/25
    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Weekly
    #${amount} =  Random Number    digits=2
	${amount}=  Generate Random String  length=3   chars=[NUMBERS]
    Sleep    ${latency_time}
    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00   
    Set Textfield Value JS    \#recurringpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#recurringpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#recurringpaymentcontainer #taxamount          2
	Sleep        15s   

User selects the Credit Card Fee Schedule
 
    
    Select Combobox Value JS     \updatefeewindow #feeschedule        Cc Fee
    Sleep  10s


User selects the ACH Fee Schedule
    
    Select Combobox Value JS     \updatefeewindow #feeschedule        Ach Fee
    Sleep  10s

User clicks on the Update button
    Click Ext button JS    \#buttontoolbar #updatebutton{isVisible(true)}
    Sleep    ${latency_time}   
    Wait Until Page Contains   Update Fees   timeout=10s
    Click Ext button JS           \button#ok{isVisible(true)}
    
User closes the Update Fee window
    Click Ext button JS        \#closebutton{isVisible(true)}
    

        
# User clicks on OK button
    

        # Click Ext button JS         \button#createextrapaymentbutton{isVisible(true)}
        # #Wait Until Page Contains   Extra Payment Receipt   timeout=10s 
        # Sleep  ${latency_time}
        # #Wait Until Keyword Succeeds    20s  20ms            Wait Until Ext Element Is Enabled    \#closebutton
        # #Click Ext button JS         \#extrapaymentreceiptid #closebutton{isVisible(true)}
         # Click Ext button JS    \button#ok{isVisible(true)}
        
 User closes the Window
        Sleep    2s
         Click Ext button JS         \#closebutton{isVisible(true)}
        

User clicks on Skip Payment Button
        Sleep    ${latency_time}  
        Click Ext button JS    \button#skipunskippaymnentbutton{isVisible(true)}      

    
User closes the Installment Schedule window    
        Sleep    ${latency_time}
        Click Ext button JS    \#amortizationschedulewindow #closebutton{isVisible(true)}  
        #Click Ext button JS        \#closebutton{isVisible(true)}
           
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
    
User selects the recent ACH transaction
    
    Click Grid Row Via Dom   \#recentpaymentsgridpanel    paymentaccount       ${ach_account_name} 
    Sleep    ${latency_time}
    
User selects the recent CC transaction 
    
    Click Grid Row Via Dom   \#recentpaymentsgridpanel    paymentaccount       ${account_name}
    Sleep    ${latency_time}


User views the details of the recent transaction
		
        Sleep    ${latency_time}
		Wait Until Page Contains   Transaction Details   timeout=10s 
		Sleep    ${latency_time}
		
User views the Payment Schedule Details 
    
       Wait Until Keyword Succeeds    20s  20ms            Wait Until Ext Element Is Enabled    \#researchtransactiondetails #scheduledetailsbutton
	   Click Ext button JS  \#researchtransactiondetails #scheduledetailsbutton{isVisible(true)}
	   Wait Until Page Contains   Payment Schedule Details   timeout=10s
	   Sleep   20s

User closes the Payment Schedule window	
	
		Click Ext button JS    \#scheduledpaymentwindow #closebutton{isVisible(true)}
		Sleep    ${latency_time}
		
User is on the Transaction Details window 

		Wait Until Page Contains   Transaction Details  timeout=10s 
		
User views the customer details on the Transaction Details window
	 
		Click Ext button JS        button\#customerdetailsbutton{isVisible(true)} 
		Sleep    ${latency_time}
	
User closes the Extra Payment window	
         Click Ext button JS        \#closebutton{isVisible(true)} 
         
*** Test Cases ***

Create Individual Customer with ACH Payment Account and Confirm Customer Exist
    [Tags]    Smoke    Regression
    Given User Select Account Location
	And User clicks on Add customer button
	And User add ACH Customer Information
	#When User clicks on Save button
	Then Individual customer is created succesfully
	
Create Business Customer with CC Payment Account and Confirm Customer Exist
    [Tags]    Smoke    Regression
    Given User Select Account Location
	And User clicks on Add customer button
	And User add CC Customer Information
	When User clicks on Save button
	Then business customer is created succesfully
#Adding another payment account type for the same individual customer
Adding CC Payment Account for the Newly Created Individual Customer and Confirm Payment Account Exist
    [Tags]    Smoke    Regression 
    Given User Select Account Location
	And User selects a Customer 
	And User add CC Payment Account
	When User Enter CC Payment Details
	Then CC Payment Account is added successfully
	And added CC Payment Account is validated 
	
Updating Created CC Payment Account for Individual Customer
    [Tags]    Smoke    Regression  
    Given User Select Account Location
    And User selects a Customer       #user slects a customer and updates the CC payment account associated with it.
    And User Selects CC payment account
    When User updates Customer name and account number
    Then Payment Account is succcesfully edited
    And A Confirmation "The payment account was updated successfully " appears    
    
	
Adding ACH Payment Account for the Newly Created Business Customer and Confirm Payment Account Exist
    [Tags]    Smoke    Regression
	Given User Select Account Location
	And User selects a Business Customer 
	And User add ACH Payment Account
	When User Enter ACH Payment Details
	Then ACH Payment Account is added successfully	
	And added ACH Payment Account is validated 
	
Updating Created ACH Payment Account for Business Customer
    [Tags]    Smoke    Regression
	Given User Select Account Location
	And User selects a Customer
	And User Selects an ACH Payment Account                #user slects a customer and updates the ACH payment account associated with it.
    And User Updates the Name and Routing number of Payment Account
    Then Payment Account is succcesfully edited
	And A Confirmation "The payment account was updated successfully " appears	   

InActivating CC Payment Account
    
    [Tags]    Smoke    Regression
    Given User Select Account Location
    And User selects a Customer
    And User Selects CC payment account     #user selects CC payment account assocaiated with that customer
    And User waits until Page contains Edit payment account
    When User Inactivates the payment account
    Then Payment Account is scuccessfully Inactivated
    And A Confirmation "The payment account was updated successfully " appears
    
InActivating ACH Payment Account
    
    [Tags]    Smoke    Regression
    Given User Select Account Location
   	And User selects a Customer
    And User Selects ACH Payment account  #user selects ACH payment account assocaiated with that customer
    And User waits until Page contains Edit payment account
    When User Inactivates the payment account
    Then Payment Account is scuccessfully Inactivated
    And A Confirmation "The payment account was updated successfully " appears
	
Search and Select Created Individual Customer Using Search Button and Confirm they Exist   #Searching and selecting a customer and validating it
    [Tags]    Smoke    Regression
    Given User Select Account Location
    When User enters firstname ${first_name} in the customer search box  #searching and selecting a customer with ${first_name}             
    Then User selects the Customer with firstname ${first_name}  #user selects the retrieved Individual customer ${first_name}
    And User confirms that Customer with firstname ${first_name} exists

Search and Select Created Business Customer Using Search Button   #Searching and selecting a customer to ensure business customer does exist
    [Tags]    Smoke    Regression
    Given User Select Account Location
    When User enters businessname ${business_name} in the customer search box
    Then User selects a Business Customer        #user selects the retrieved business customer ${business_name}
    And User Wait Until Page Contains Customer Information

Inactivate Customer	
    [Tags]    Smoke    Regression	     
    Given User Select Account Location
	When User searches a Customer      #user searching and selecting a customer ${first_name}
	And User selects the Customer and inactivates it  
	Then Customer is inactivated   #User inactivates the customer
	And User verifies that Customer is InActive     

View All Customers and Update Information of First Customer   
    [Tags]    Smoke    Regression   
   Given User Select Account Location
   And User Clicks on "View all" Customers button    #user seleting the first customer from the list of customers.
   And User Selects first customer from grid
   When User Updates Some fields of Customer    #updates address,city,state,zipcode,email etc.
   Then Customer is successfully updated 
   And A Confirmation 'Changes Saved Successfully' appears  
   
View Transactions Details for CC Recurring Payment of Customer
         [Tags]    Smoke    Regression  

    Sleep    10s
    #Given User navigates to Payments tab
    And User selects Recurring Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer
    And User adds Card Payment Details for creating Weekly Recurring schedule
    And User clicks on create payment button  
 	And Payment Schedule is successfully created 
 	And Page Contains "The payment requested for today was processed successfully!"
	And User Select Account Location
	And User navigates to Customers tab  
    And User enters businessname ${business_name} in the customer search box
    Sleep    55s
	And User selects the Customer with businessname ${business_name} 
    #And User Waits Until Page Contains Scheduled Payments Information 
    Then User selects the recent CC transaction  
    And User views the details of the recent transaction 
 
    
View Schedule Details for CC Recurring Payment of Customer 
         [Tags]    Smoke    Regression  

    Then User views the Payment Schedule Details
    And User closes the Payment Schedule window	   


View Customer Details for CC Recurring Payment of Customer 
     [Tags]    Smoke    Regression  

    When User is on the Transaction Details window     
    Then User views the customer details on the Transaction Details window
 
View Installment Schedule for Scheduled CC Installment Payment of Customer
    [Tags]    Smoke    Regression  
    
    Given User navigates to Payments tab
    And User Selects Installment Tab and Select Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    And User adds Card Payment Details for creating Quarterly Installment schedule on a future date
    And User clicks on create payment button  
 	And Payment Schedule is successfully created 
 	And Page Contains "The payment requested for today was processed successfully!"
	And User Select Account Location
	When User navigates to Customers tab 
	And User enters businessname ${business_name} in the customer search box 
	Sleep  55s
	And User selects the Customer with businessname ${business_name}  
    And User Waits Until Page Contains Scheduled Payments Information 
    Then User selects the scheduled CC payment
    And User clicks on View Installment Schedule
    Then User closes the Installment Schedule window 
     
# # Skip payment schedule for Scheduled CC Installment Payment of Customer
     # # [Tags]    Smoke    Regression  
     
   # # Given User is on Payment schedule details window 
   # # When User clicks on Skip Payment Button
   # # Then User closes the Installment Schedule window    
       
        
        
         
            
Update Payment Date for Scheduled CC Installment Payment of Customer
   [Tags]    Smoke    Regression 
   
   
    And User clicks on Update next payment date button
    Then User modifies the next scheduled payment date
    And User clicks on modify button
    And User click on ok button
    And a Confirmation "Your requested schedule dates have been updated" appears
    #user stays on payment schedule details window for executing next testcase  
      
Update Fee for Scheduled CC Installment Payment of Customer
   [Tags]    Smoke    Regression 
   
    And User clicks on Update Fee button
    And User selects the Credit Card Fee Schedule
    And User clicks on the Update button
    Sleep    ${latency_time} 

Inactivate Installment Schedule after a future date for CC Installment
     [Tags]    Smoke    Regression 
    
    And User clicks on Inactivate Schedule button
	And User enters a future Inactivation date
    When User Clicks on Update button
    Then Payment schedule Inactivation is scheduled for a future date
    

Cancel scheduled Inactivation for CC Installment
     [Tags]    Smoke    Regression 
     
   Given User is on Payment schedule details window
   And User clicks on Inactivate Schedule button
   When User clicks on Cancel Termination button
   Then Future payment schedule Inactivation is cancelled
    
Inactivate Schedule Now for CC Installment

     [Tags]    Smoke    Regression 
     
    Given User is on Payment schedule details window
    And User clicks on Inactivate Schedule button
    When User clicks Inactivate Now button
    Then All future payments of the schedule is terminated 
    



View Transactions Details for ACH Recurring Payment of Customer
         [Tags]    Smoke    Regression  


    Sleep    10s
    Given User selects Recurring Tab and then Selects Account Location
    And User clicks on Add customer button
    And User Add ACH Customer Information
    And User adds ACH Payment Details for creating Weekly Recurring schedule
    Sleep    10s
    And User clicks on create payment button 
    And Payment Schedule is successfully created 
    And Page Contains "The payment requested for today was processed successfully!" 
    And User Select Account Location
	And User navigates to Customers tab  
	And User enters firstname ${first_name} in the customer search box
    Sleep   55s
	And User selects the Customer with firstname ${first_name} 
    #And User Waits Until Page Contains Scheduled Payments Information  
    Then User selects the recent ACH transaction 
    And User views the details of the recent transaction 
 
    
View Schedule Details for ACH Recurring Payment of Customer 
         [Tags]    Smoke    Regression  

    Then User views the Payment Schedule Details
    And User closes the Payment Schedule window	   


View Customer Details for ACH Recurring Payment of Customer 
     [Tags]    Smoke    Regression  

    When User is on the Transaction Details window     
    Then User views the customer details on the Transaction Details window
    




    
Update Payment Date for Scheduled ACH Recurring Payment of Customer
      [Tags]    Smoke    Regression 
    
    # # # Given User selects Recurring Tab and then Selects Account Location
    # # # And User clicks on Add customer button
    # # # And User Add ACH Customer Information
    # # # And User adds ACH Payment Details for creating Weekly Recurring schedule
    # # # And User clicks on create payment button 
    # # # And Payment Schedule is successfully created 
    # # # And Page Contains "The payment requested for today was processed successfully!" 
    # # # And User Select Account Location
	# # # And User navigates to Customers tab  
	# # # And User enters firstname ${first_name} in the customer search box 
	# # # And User selects the Customer with firstname ${first_name} 
    And User Waits Until Page Contains Scheduled Payments Information 
    And User selects the scheduled payment
    And User clicks on Update next payment date button
    When User modifies the next scheduled payment date
    And User clicks on modify button
    And User click on ok button
    Then a Confirmation "Your requested schedule dates have been updated" appears
    

Add Extra payment for Scheduled ACH Recurring Payment of Customer
    [Tags]    Smoke    Regression 
       
    Given User clicks on Add extra payment button
	When User enters Extra Payment Amount
    Then User clicks on Create Extra Payment button 
    And User closes the Extra Payment window	


View Installment Schedule for Scheduled ACH Installment Payment of Customer
     [Tags]    Smoke    Regression  
    
    Given User navigates to Payments tab
    And User Selects Installment Tab and Select Account Location
    And User clicks on Add customer button
    And User Add ACH Customer Information
    And User adds ACH Payment Details for creating Weekly Installment schedule
 	And User clicks on create payment button  
 	And Payment Schedule is successfully created 
 	And Page Contains "The payment requested for today was processed successfully!"
	And User Select Account Location
	And User navigates to Customers tab  
	And User enters firstname ${first_name} in the customer search box 
	Sleep   55s
	And User selects the Customer with firstname ${first_name} 
    And User Waits Until Page Contains Scheduled Payments Information 
    And User selects the scheduled payment
    And User clicks on View Installment Schedule
    Then User closes the Installment Schedule window  
     
# Skip payment schedule for Scheduled ACH Installment Payment of Customer
      # [Tags]    Smoke    Regression  
     
   # Given User is on Payment schedule details window 
   # When User clicks on Skip Payment Button
   # Then User closes the Installment Schedule window  
   
Update Payment Date for Scheduled ACH Installment Payment of Customer
   [Tags]    Smoke    Regression 
   
    # # Given User navigates to Payments tab
    # # And User Selects Installment Tab and Select Account Location
    # # And User clicks on Add customer button
    # # And User Add ACH Customer Information
    # # And User adds ACH Payment Details for creating Weekly Installment schedule
 	# # And User clicks on create payment button  
 	# # And Payment Schedule is successfully created 
 	# # And Page Contains "The payment requested for today was processed successfully!"
	# # And User Select Account Location
	# # And User navigates to Customers tab  
	# # And User enters firstname ${first_name} in the customer search box 
	# # And User selects the Customer with firstname ${first_name} 
    # And User Waits Until Page Contains Scheduled Payments Information 
    # And User selects the scheduled payment
    # Sleep  ${latency_time}
    And User clicks on Update next payment date button
    Then User modifies the next scheduled payment date
    And User clicks on modify button
    And User click on ok button
    And a Confirmation "Your requested schedule dates have been updated" appears
    # #user stays on payment schedule details window for executing next testcase    

    
   
   

Add Extra Payment for Scheduled ACH Installment Payment of Customer for future date
   [Tags]    Smoke    Regression 
    
    # # Given User navigates to Payments tab
    # # And User Selects Installment Tab and Select Account Location
    # # And User clicks on Add customer button
    # # And User Add ACH Customer Information
    # # And User adds ACH Payment Details for creating Weekly Installment schedule
 	# # And User clicks on create payment button  
 	# # And Payment Schedule is successfully created 
 	# # And Page Contains "The payment requested for today was processed successfully!"
	# # And User Select Account Location
	# # And User navigates to Customers tab  
	# # And User enters firstname ${first_name} in the customer search box 
	# # And User selects the Customer with firstname ${first_name} 
    # # And User Waits Until Page Contains Scheduled Payments Information 
    # # And User selects the scheduled payment
    When User clicks on Add extra payment button
	And User enters Extra Payment Amount for future date
    Then User clicks on Extra Payment button
    #And a confirmation that extra payment has been successfully scheduled appears
    

    
Update Fee for Scheduled ACH Installment Payment of Customer
    [Tags]    Smoke    Regression 
  
    And User clicks on Update Fee button
    And User selects the ACH Fee Schedule
    And User clicks on the Update button
   
        
Inactivate Installment Schedule after a future date
     [Tags]    Smoke    Regression 
    
    And User clicks on Inactivate Schedule button
	And User enters a future Inactivation date
    When User Clicks on Update button
    Then Payment schedule Inactivation is scheduled for a future date
    

Cancel scheduled Inactivation
     [Tags]    Smoke    Regression 
     
   Given User is on Payment schedule details window
   And User clicks on Inactivate Schedule button
   When User clicks on Cancel Termination button
   Then Future payment schedule Inactivation is cancelled
    
Inactivate Schedule Now 
     [Tags]    Smoke    Regression 
     
    Given User is on Payment schedule details window
    And User clicks on Inactivate Schedule button
    When User clicks Inactivate Now button
    Then All future payments of the schedule is terminated 
    



    
Add Extra Payment for Scheduled CC Recurring Payment of Customer for future date
      [Tags]    Smoke    Regression 
      
    Given User navigates to Payments tab
    And User selects Recurring Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer
    And User adds Card Payment Details for creating Weekly Recurring schedule
    And User clicks on create payment button  
 	And Payment Schedule is successfully created 
 	And Page Contains "The payment requested for today was processed successfully!"
	And User Select Account Location
	And User navigates to Customers tab  
    And User enters businessname ${business_name} in the customer search box
    Sleep  55s
    And User selects the Customer with businessname ${business_name} 
    And User Waits Until Page Contains Scheduled Payments Information 
    And User selects the scheduled CC payment
    When User clicks on Add extra payment button
    And User enters Extra Payment Amount for future date for CC Schedule
    Then User clicks on Extra Payment button
    #And a confirmation that extra payment has been successfully scheduled appears

        
    
Update Payment Date for CC reccuring schedule
      [Tags]    Smoke    Regression 
    When User clicks on Update next payment date button
    And User modifies the next scheduled payment date
    And User clicks on modify button
    And User click on ok button
    Then a Confirmation "Your requested schedule dates have been updated" appears
    #user stays on payment schedule details window for executing next testcase  
Inactivate Installment Schedule after a future date for CC Reccuring
     [Tags]    Smoke    Regression 
    
    And User clicks on Inactivate Schedule button
	And User enters a future Inactivation date
    When User Clicks on Update button
    Then Payment schedule Inactivation is scheduled for a future date
    

Cancel scheduled Inactivation for CC Reccuring
     [Tags]    Smoke    Regression 
     
   Given User is on Payment schedule details window
   And User clicks on Inactivate Schedule button
   When User clicks on Cancel Termination button
   Then Future payment schedule Inactivation is cancelled
    
Inactivate Schedule Now for CC Reccuring
     [Tags]    Smoke    Regression 
     
    Given User is on Payment schedule details window
    And User clicks on Inactivate Schedule button
    When User clicks Inactivate Now button
     Then All future payments of the schedule is terminated



