*** Settings ***
Documentation    Creating and Deleting the Account Type Settings, Custom Data and Fee Settings

Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary                                                             locale=en_US
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
Test Teardown     Test Ui Teardown
Suite Teardown    Close Browser


*** Variables ***
${latency_time}  5s

*** Keywords ***

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV005
User navigates to Settings tab
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Wait Until Keyword Succeeds    15s    15s    Select Navigation Tab    NV005
        
User Select Account Location
    Select Combobox Value JS    \#paymentsettingspanel > #accountlocationcombobox    Downtown
User navigates to Payments tab
	
	Wait Until Keyword Succeeds    15s    15s    Select Navigation Tab    NV001
	Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Customers    timeout=30s  
	
Checking Require CVV checkbox
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#requirecvv")[0];
            ...               w.setValue(true);  

Unchecking Require CVV checkbox
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#requirecvv")[0];
            ...               w.setValue(false);  

Unchecking Require AVS checkbox
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#requireavs")[0];
            ...               w.setValue(false);

Checking Require AVS checkbox
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#requireavs")[0];
            ...               w.setValue(true);            
User unchecks Level 2 Data Field checkbox in self-service settings page
    Execute Javascript    var w=Ext.ComponentQuery.query("#displaylevel2fields")[0];
            ...               w.setValue(false);

User checks Level 2 Data Field checkbox in self-service settings page
    Execute Javascript    var w=Ext.ComponentQuery.query("#displaylevel2fields")[0];
            ...               w.setValue(true);
User clicks on the save button
    Wait Until Keyword Succeeds    15s    15s    Click Ext Button JS    \#button > #savebutton{isVisible(true)}
	Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Account type setting information saved successfully      timeout=10 seconds    error=None
	Wait Until Keyword Succeeds    15s    15s    Click Ext Button JS    \#ok{isVisible(true)}
	
Verifying all the textbox in the Account Type Settings area
    Wait Until Keyword Succeeds    15s    15s    page should contain    Account Type Settings
    Wait Until Keyword Succeeds    15s    15s    page should contain    Display Level 2 Data Fields
    Wait Until Keyword Succeeds    15s    15s    page should contain    Require CVV
    Wait Until Keyword Succeeds    15s    15s    page should contain    Require AVS
    Wait Until Keyword Succeeds    15s    15s    page should contain    Save
Verifying all the details in Custom Data Settings area    
    Wait Until Keyword Succeeds    15s    15s    page should contain    Field Name
    Wait Until Keyword Succeeds    15s    15s    page should contain    Field Type
    Wait Until Keyword Succeeds    15s    15s    page should contain    Add
    
Verifying all the details in Fees Settings area 
    Wait Until Keyword Succeeds    15s    15s    page should contain    ACH Fees
    Wait Until Keyword Succeeds    15s    15s    page should contain    Credit Card Fees
    Wait Until Keyword Succeeds    15s    15s    page should contain    Fee Name
    Wait Until Keyword Succeeds    15s    15s    page should contain    Txn Fee ($)
    Wait Until Keyword Succeeds    15s    15s    page should contain    Percent Fee(%)
    Wait Until Keyword Succeeds    15s    15s    page should contain    Txn Fee ($)
    Wait Until Keyword Succeeds    15s    15s    page should contain    Percent Fee(%)
    Wait Until Keyword Succeeds    15s    15s    page should contain    Add
User selects Recurring Tab and then Selects Account Location      
   Execute Javascript     var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
            ...               recurringPaymentTab = Ext.ComponentQuery.query('recurringpaymentcontainer')[0];
            ...               tabPanel.setActiveTab(recurringPaymentTab);
   
   Select Combobox Value JS    \#recurringpaymentcontainer > #accountlocationcombobox    Downtown    

User selects Installment Tab and then Selects Account Location
       Execute Javascript         var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
       ...                        installmentPaymentTab = Ext.ComponentQuery.query('#installmentpaymentcontainer')[0];
       ...                        tabPanel.setActiveTab(installmentPaymentTab);

   Select Combobox Value JS    \#installmentpaymentcontainer > #accountlocationcombobox    Downtown    
User clicks on Add customer button
    Wait Until Keyword Succeeds    15s    15s    Click Ext Button JS     \#addcustomerbutton{isVisible(true)}  
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Add New Customer      timeout=15s         

Selecting frequency as weekly for recurring payments
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Weekly

User creates a Business CC Customer     
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
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS    \#addcustomerwindow #phonenumber                ${phone_number}
    ${email_address}    Generate Random String  length=5  chars=[LETTERS][NUMBERS]
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS    \#addcustomerwindow #emailaddress              ${email_address}@example.com
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#savebutton{isVisible(true)}
	Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains                  Payment Information        timeout=20s
	# Sleep    ${latency_time}
    	
Changing the fees to default value
    
    Execute Javascript    var fee_combobox = Ext.ComponentQuery.query('selfservicepaymentsettings #feeschedule')[0];
            ...               var store = fee_combobox.getStore();
            ...               var fee_value = store.findRecord('name', 'ZERO FEE SCHEDULE');
            ...               fee_combobox.setValue(fee_value);
           
User creates an ACH customer
    ${customerid}=   Generate Random String   length=10
    Set Textfield Value JS   \#addcustomerwindow #customerid                          ${customerid}
    ${first_name}=  First Name Male
    Set Textfield Value JS   \#addcustomerwindow #firstname                           ${first_name}
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


 User adds ACH Payment Details for creating Weekly Installment schedule on a current date with new fees and custom data
    Sleep    ${latency_time}
    ${amount} =  Random Number    digits=2
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Weekly
    Set Textfield Value JS      \#installmentpaymentcontainer #beginningbalance    ${amount}.00
    Execute Javascript          Ext.ComponentQuery.query('#specialtytextfield')[1].setValue('30.00'); 
    # Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    # Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    # Set Textfield Value JS    \#installmentpaymentpaymentcontainer #taxamount          2
    Execute Javascript    var a=Ext.ComponentQuery.query("#feeschedule")[1].getStore().data.items[0].raw.name;
                     ...  Ext.ComponentQuery.query('#feeschedule')[1].setValue(a);
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    Ext.ComponentQuery.query('installmentpaymentcontainer paymentinformationformpanel #customdata')[0].down().setValue('1');        
	#Sleep        15s
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[1].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[1].setValue(true);  
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#closebutton{isVisible(true)}
	
User adds Card Payment Details for creating Weekly Installment schedule on a current date with new fees and custom data
    
    # ${futureDate}     Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y  
    # Sleep    ${latency_time}   
    Set Textfield Value JS    \#installmentpaymentcontainer #cvv              999
    Set Textfield Value JS    \#installmentpaymentcontainer #expirydate       11/25
    # Set Textfield Value JS    \#installmentpaymentcontainer #paymentdate     ${futureDate}
    Select Combobox Value JS    \#installmentpaymentcontainer #frequency     Weekly
    ${amount} =  Random Number    digits=3
    Sleep    ${latency_time}
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    ${amount}.00
    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   30.00
    Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#installmentpaymentcontainer #taxamount          2 
    
    Execute Javascript    var a=Ext.ComponentQuery.query("#feeschedule")[1].getStore().data.items[0].raw.name;
                     ...  Ext.ComponentQuery.query('#feeschedule')[1].setValue(a);
      
 
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    Ext.ComponentQuery.query('installmentpaymentcontainer paymentinformationformpanel #customdata')[0].down().setValue('1');  
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#closebutton{isVisible(true)}
	
User adds Card Payment Details for creating OTP on a current date with new fees and custom data
        # ${futureDate}     Add Time To Date   ${today}    3d    result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y  
    Sleep    ${latency_time}   
    Set Textfield Value JS    \#installmentpaymentcontainer #cvv              999
    Set Textfield Value JS    \#installmentpaymentcontainer #expirydate       11/25
    # Set Textfield Value JS    \#installmentpaymentcontainer #paymentdate     ${futureDate}
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance    ${amount}.00
    Set Textfield Value JS    \#installmentpaymentcontainer #invoicenumber     111
    Set Textfield Value JS    \#installmentpaymentcontainer #purchaseorder     11
    Set Textfield Value JS    \#installmentpaymentcontainer #taxamount          2 
    
    Execute Javascript    var a=Ext.ComponentQuery.query("#feeschedule")[0].getStore().data.items[0].raw.name;
                     ...  Ext.ComponentQuery.query('#feeschedule')[0].setValue(a);
      
 
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    Ext.ComponentQuery.query("paymentinformationformpanel #customdata")[0].down().setValue('1');  
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#closebutton{isVisible(true)}	
	
User adds ACH Payment Details for creating OTP on a current date with new fees and custom data
        Sleep    ${latency_time}
    ${amount} =  Random Number    digits=2
    Set Textfield Value JS     \#onetimepaymentcontainer #beginningbalance    ${amount}.00
    Sleep    ${latency_time}
    Execute Javascript    var a=Ext.ComponentQuery.query("#feeschedule")[0].getStore().data.items[0].raw.name;
                     ...  Ext.ComponentQuery.query('#feeschedule')[0].setValue(a);
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    Ext.ComponentQuery.query("paymentinformationformpanel #customdata")[0].down().setValue('1');  
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#closebutton{isVisible(true)}	              

Then User adds Card Payment Details for creating Weekly Recurring schedule on a current date with new custom data
   Selecting frequency as weekly for recurring payments 
   User adds Recurring details
   
User adds Recurring details
    Sleep    ${latency_time}
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
    
     Press Keys    (//*[@name="beginningbalance"][@class='x-form-field x-form-text'])[2]    0000
    
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    Ext.ComponentQuery.query('recurringpaymentcontainer paymentinformationformpanel #customdata')[0].down().setValue('1'); 
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    1      
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#closebutton{isVisible(true)}

Then User adds ACH Payment Details for creating Weekly Recurring schedule on a current date with new custom data
    User adds ACH Recurring details

User adds ACH Recurring details
    Sleep    ${latency_time}
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
    
     Press Keys    (//*[@name="beginningbalance"][@class='x-form-field x-form-text'])[2]    0000
    
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    Ext.ComponentQuery.query('recurringpaymentcontainer paymentinformationformpanel #customdata')[0].down().setValue('1'); 
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    1  
    Sleep    ${latency_time}
    Execute Javascript          Ext.ComponentQuery.query('#writtenauthorization')[2].setValue(true);
    Execute Javascript          Ext.ComponentQuery.query('#authorizationcheckbox')[2].setValue(true);  
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#closebutton{isVisible(true)}

    
*** Test Cases ***

Verify Payment Settings sub tab at Settings tab
    [Tags]     Smoke   Regression
    When User Select Account Location
    Then Verifying all the textbox in the Account Type Settings area
    Then Verifying all the details in Custom Data Settings area
    Then Verifying all the details in Fees Settings area
    
Verify user is able to manage the Account Type Settings by checking all the checkboxes
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User checks Level 2 Data Field checkbox in self-service settings page 
    And Checking Require CVV checkbox
    When Checking Require AVS checkbox
    Then User clicks on the save button

Verify user is able to manage the Account Type Settings by unchecking all the checkboxes
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button
    
Verify user is able to Add Custom data field
    [Tags]     Smoke   Regression
    When User Select Account Location
    Then User Create Custom fields in payment Settings page
    # [Tags]     Smoke   Regression
    # Select Account Location
    # ${Customfieldname}=    Generate Random String    length=5           chars=[LETTERS]
    # Set Textfield Value JS    \#additemcontainer > [name=customFieldName]    ${Customfieldname}
    # Select Combobox Value JS    \#additemcontainer > #fieldtype    Text
    # Select Combobox Value JS    \#additemcontainer > #ruletype     InvoiceNumber
    # Click Ext Button JS      button#addbutton{isVisible(true)}
    # Set Suite Variable     \${Customfieldname}    ${Customfieldname}

Delete Custom Fields
    [Tags]     Smoke   Regression
    When User Select Account Location
    Then User Delete Custom field in Payment Settings Page
    # Select Account Location
    # Click Grid Row       \#savedcustomdatagridpanel    customFieldName    ${Customfieldname}
    # ${removebutton}      Set Variable     Ext.getCmp(Ext.ComponentQuery.query("#paymentsettingscustomdata")[0].getEl().down('.adjusted').id)      #Ext.ComponentQuery.query('#savedcustomdatagridpanel #removebutton')[2]
    # Execute Javascript         ${removebutton}.fireEvent('click',${removebutton});
    # Wait Until Page Contains    Are you sure         timeout=30 seconds    error=None
    # Click Ext Button JS      button#ok{isVisible(true)}
    # Sleep  2s
    

Create Fees
    [Tags]     Smoke   Regression
    When User Select Account Location
    Then Create fees in the Payment Settings
    # Select Account Location
    # ${feename}=    Generate Random String    length=5           chars=[LETTERS]
    # Set Textfield Value JS    \#feename      ${feename}
    # Set Textfield Value JS    \#achfees > #amount      10.00
    # Set Textfield Value JS  \#achfees > #percentage     2
    # Set Textfield Value JS    \#cardfees > #amount      10.00
    # Set Textfield Value JS  \#cardfees > #percentage     2
    # ${addbutton}     Set Variable    Ext.ComponentQuery.query('#addbutton')[1]
    # Execute Javascript         ${addbutton}.fireEvent('click',${addbutton});
    # Set Suite Variable     \${feename}    ${feename}
 

Delete Fees
    [Tags]     Smoke   Regression
    When User Select Account Location
    Then Delete fees from payment Settings
    # Select Account Location
    # Click Grid Row       \#savedfeesgridpanel    name    ${feename}
    # ${feeremovebutton}      Set Variable    Ext.getCmp(Ext.ComponentQuery.query("#paymentsettingsfees")[0].getEl().down('.adjusted').id)      #Ext.ComponentQuery.query('#savedfeesgridpanel #removebutton')[1]
    # Execute Javascript         ${feeremovebutton}.fireEvent('click',${feeremovebutton}); 
    # Wait Until Page Contains    Are you sure       timeout=30 seconds    error=None
    # Click Ext Button JS     button#ok{isVisible(true)}


Verify user is able to create CC OTP with newly added Custom data and fees.
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button    
    When User Create Custom fields in payment Settings page
    And Create fees in the Payment Settings
    And User navigates to Payments tab
    And User Select Account Location    
    And User clicks on Add customer button
    And User creates a Business CC Customer
    Then User adds Card Payment Details for creating OTP on a current date with new fees and custom data
    When User navigates to Settings tab   
    Then User Delete Custom field in Payment Settings Page
    Then Delete fees from Payment Settings
   
Verify user is able to create ACH OTP with newly added Custom data and fees.
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button    
    When User Create Custom fields in payment Settings page
    And Create fees in the Payment Settings
    And User navigates to Payments tab
    And User Select Account Location    
    And User clicks on Add customer button
    And User creates a Business CC Customer
    Then User adds ACH Payment Details for creating OTP on a current date with new fees and custom data
    When User navigates to Settings tab   
    Then User Delete Custom field in Payment Settings Page
    Then Delete fees from Payment Settings

Verify user is able to create CC IP with newly added Custom data and fees.
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button    
    When User Create Custom fields in payment Settings page
    And Create fees in the Payment Settings
    And User navigates to Payments tab
    And User selects Installment Tab and then Selects Account Location    
    And User clicks on Add customer button
    And User creates a Business CC Customer
    Then User adds Card Payment Details for creating Weekly Installment schedule on a current date with new fees and custom data
    When User navigates to Settings tab   
    Then User Delete Custom field in Payment Settings Page
    Then Delete fees from Payment Settings
    
Verify user is able to create ACH IP with newly added Custom data and fees.
     [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button    
    And User Create Custom fields in payment Settings page
    And Create fees in the Payment Settings
    And User navigates to Payments tab
    And User selects Installment Tab and then Selects Account Location    
    And User clicks on Add customer button
    And User creates an ACH customer
    Then User adds ACH Payment Details for creating Weekly Installment schedule on a current date with new fees and custom data
    When User navigates to Settings tab   
    Then User Delete Custom field in Payment Settings Page
    Then Delete fees from Payment Settings   
   

Verify user is able to create CC RP with newly added Custom data 
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button    
    And User Create Custom fields in payment Settings page   
    And User navigates to Payments tab
    And User selects Recurring Tab and then Selects Account Location    
    And User clicks on Add customer button
    And User creates a Business CC Customer
    Then User adds Card Payment Details for creating Weekly Recurring schedule on a current date with new custom data
    When User navigates to Settings tab   
    Then User Delete Custom field in Payment Settings Page


Verify user is able to create ACH RP with newly added Custom data
    [Tags]     Smoke   Regression
    Given User Select Account Location
    When User unchecks Level 2 Data Field checkbox in self-service settings page 
    And Unchecking Require CVV checkbox
    And Unchecking Require AVS checkbox
    Then User clicks on the save button    
    And User Create Custom fields in payment Settings page
    And User navigates to Payments tab
    And User selects Recurring Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates an ACH customer
    Then User adds ACH Payment Details for creating Weekly Recurring schedule on a current date with new custom data
    When User navigates to Settings tab
    Then User Delete Custom field in Payment Settings Page


