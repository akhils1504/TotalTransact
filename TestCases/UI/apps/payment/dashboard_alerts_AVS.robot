*** Settings ***
# Documentation    Searching for Transaction(s) in Specified Enviornment

Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary                                                             locale=en_US
Library     DateTime  
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
                  ...                 AND                 Ensure Require AVS Check is enabled and CVV is disabled                

Test Teardown     Test Ui Teardown
                       
Suite Teardown    Teardown Test Suite

*** Variables ***
${latency_time}  5s
#${card_processor_text}=        MONETRA
${card_processor_text}=        CYBERSOURCE
${cybersource_failure_amount}    7005
  

*** Keywords ***
Checking AVS option
    Select Account Location
    User ensures Require AVS Check is enabled

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot   
    Reload Page  

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV005
User unchecks Level 2 Data Field checkbox in self-service settings page
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#displaylevel2fields")[0];
            ...               w.setValue(false);      
Unchecking Require CVV checkbox
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#requirecvv")[0];
            ...               w.setValue(false);  
Checking Require AVS checkbox
    Wait Until Keyword Succeeds    15s    15s    Execute Javascript    var w=Ext.ComponentQuery.query("#requireavs")[0];
            ...               w.setValue(true);
Select Account Location
    Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymentsettingspanel > #accountlocationcombobox    Downtown

Ensure Require AVS Check is enabled and CVV is disabled 	
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Account Type Settings      timeout=30s   
    #Sleep    ${latency_time} 
    Wait Until Keyword Succeeds    15s    15s    Select Account Location
    Wait Until Keyword Succeeds    15s    15s    Unchecking Require CVV checkbox
    #Sleep    ${latency_time} 
    Wait Until Keyword Succeeds    15s    15s    Checking Require AVS checkbox
    #Sleep    ${latency_time} 
    Wait Until Keyword Succeeds    15s    15s    User unchecks Level 2 Data Field checkbox in self-service settings page
    #Sleep    ${latency_time} 
    # Sleep    1s
	Wait Until Keyword Succeeds    15s    15s    Click Ext Button JS    \#button > #savebutton{isVisible(true)}
	Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Account type setting information saved successfully      timeout=10 seconds    error=None
	Wait Until Keyword Succeeds    15s    15s    Click Ext Button JS    \#ok{isVisible(true)}
	
User selects Recurring Tab and then Selects Account Location      
   Execute Javascript     var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
            ...               recurringPaymentTab = Ext.ComponentQuery.query('recurringpaymentcontainer')[0];
            ...               tabPanel.setActiveTab(recurringPaymentTab);
   
   Select Combobox Value JS    \#recurringpaymentcontainer > #accountlocationcombobox    Downtown
   
User selects Installment Tab and then Selects Account Location
       Wait Until Keyword Succeeds    15s    15s    Execute Javascript         var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
       ...                        installmentPaymentTab = Ext.ComponentQuery.query('#installmentpaymentcontainer')[0];
       ...                        tabPanel.setActiveTab(installmentPaymentTab);

   Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer > #accountlocationcombobox    Downtown
User selects OTP Tab and then Selects Account Location
       # Wait Until Keyword Succeeds    15s    15s    Execute Javascript         var tabPanel = Ext.ComponentQuery.query('#tier2tabpanel')[0],
       # ...                        installmentPaymentTab = Ext.ComponentQuery.query('#installmentpaymentcontainer')[0];
       # ...                        tabPanel.setActiveTab(installmentPaymentTab);

   Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer > #accountlocationcombobox    Downtown   
User navigates to Payments tab
	
	Wait Until Keyword Succeeds    15s    15s    Select Navigation Tab    NV001
	Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Customers    timeout=30s    
	
User clicks on Add customer button
    Wait Until Keyword Succeeds    15s    15s    Click Ext Button JS     \#addcustomerbutton{isVisible(true)}  
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Add New Customer      timeout=15s 
    
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
User adds Installment details for Invalid AVS Monetra 
  Sleep    ${latency_time}
    
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    100
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   10
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}


User adds Installment details for Invalid AVS Cybersource
    Sleep    ${latency_time}
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #beginningbalance    10000
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#installmentpaymentcontainer #paymentinformationformpanel #specialtytextfield   7005.00
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	
User adds Installment details for Invalid AVS


    Run keyword if  '${card_processor_text}' == 'MONETRA'       User adds Installment details for Invalid AVS Monetra
    ...   ELSE                                                  User adds Installment details for Invalid AVS Cybersource

User adds Recurring details for Invalid AVS Monetra 
    Sleep    ${latency_time}
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
    ${amount} =  Random Number    digits=2
    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${amount}.00  
	Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}
	
User adds Recurring details for Invalid AVS Cybersource
    Sleep    ${latency_time}
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
    
     Press Keys    (//*[@name="beginningbalance"][@class='x-form-field x-form-text'])[2]    0000
    

    Wait Until Keyword Succeeds    15s    15s    Set Textfield Value JS      \#recurringpaymentcontainer #beginningbalance    ${cybersource_failure_amount}  
    Sleep    ${latency_time}
	Wait Until Keyword Succeeds    15s    15s    Click Ext button JS        \#createpaymentbutton{isVisible(true)}

User adds Recurring details for Invalid AVS


    Run keyword if  '${card_processor_text}' == 'MONETRA'       User adds Recurring details for Invalid AVS Monetra
    ...   ELSE                                                      User adds Recurring details for Invalid AVS Cybersource
    
Payment gets declined
    Wait Until Page Contains    The payment schedule was created successfully!    timeout=30s 
    Page Should Contain        Payment has been declined!
    
Page Should contain response Address Verification Failed 
       Page Should Contain    Address Verification Failed    timeout=30s 
       Click Ext button JS        \#closebutton{isVisible(true)}

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
Selecting frequency as weekly for recurring payments
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Weekly
Selecting frequency as 1st and 15th for recurring payments
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      1st and 15th
Selecting frequency as monthly for recurring payments    
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Monthly
Selecting frequency as quarterly for recurring payments   
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Quarterly
Selecting frequency as semi-annually for recurring payments   
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Semi-annually
Selecting frequency as annually for recurring payments  
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#recurringpaymentcontainer #frequency      Annually
     
Selecting frequency as weekly for installment payments
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      Weekly
Selecting frequency as 1st and 15th for installment payments
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      1st and 15th
Selecting frequency as monthly for installment payments payments    
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      Monthly
Selecting frequency as quarterly for installment payments   
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      Quarterly
Selecting frequency as semi-annually for installment payments   
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      Semi-annually
Selecting frequency as annually for installment payments 
     Sleep        3s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment Information
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#installmentpaymentcontainer #frequency      Annually
Payment has been declined and verifying AVS error message
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Payment has been declined!      timeout=30 seconds    error=None 
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Declined      timeout=30 seconds    error=None 
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Address Verification Failed      timeout=30 seconds    error=None 
    Click Ext button JS        \#closebutton{isVisible(true)}
    
Switching to dashboard tab
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Dashboard')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV000
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Alerts      timeout=30 seconds    error=None 
    
Clicking the new alert and verifying the AVS alert text
    # ${alert_element}=  Execute Javascript  return Ext.ComponentQuery.query('grid#homepagealertgrid')[0];
    # Set Suite Variable    \${alert_element}   ${alert_element}                 
    # Click Grid Row First Element    ${alert_element}
    Click Grid Row Via Dom    grid#homepagealertgrid    customername    ${business_name} 
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Address Verification Failed      timeout=30 seconds    error=None
     Execute Javascript    var a=Ext.ComponentQuery.query("#closebutton")[0];
            ...               a.fireEvent("click",a);

    
*** Test Cases ***
Declining Recurring CC Payment - Weekly using AVS
   [Tags]    Smoke    Regression

   Given User navigates to Payments tab
   When User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Selecting frequency as weekly for recurring payments
   When User adds Recurring details for Invalid AVS
   Then Payment has been declined and verifying AVS error message
   When Switching to dashboard tab
   Then Clicking the new alert and verifying the AVS alert text
    
Declining Recurring CC Payment - 1st and 15th using AVS
   [Tags]    Regression    

   Given User navigates to Payments tab
   When User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Selecting frequency as 1st and 15th for recurring payments
   When User adds Recurring details for Invalid AVS
   Then Payment has been declined and verifying AVS error message
   When Switching to dashboard tab
   Then Clicking the new alert and verifying the AVS alert text
   
Declining Recurring CC Payment - Monthly using AVS
       [Tags]    Regression   

   Given User navigates to Payments tab
   When User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Selecting frequency as monthly for recurring payments
   When User adds Recurring details for Invalid AVS
   Then Payment has been declined and verifying AVS error message
   When Switching to dashboard tab
   Then Clicking the new alert and verifying the AVS alert text
   
Declining Recurring CC Payment - Quarterly using AVS
   [Tags]    Regression    

   Given User navigates to Payments tab
   When User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Selecting frequency as quarterly for recurring payments
   When User adds Recurring details for Invalid AVS
   Then Payment has been declined and verifying AVS error message
   When Switching to dashboard tab
   Then Clicking the new alert and verifying the AVS alert text
   
Declining Recurring CC Payment - Semi-Annually using AVS
   [Tags]    Regression    

   Given User navigates to Payments tab
   When User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Selecting frequency as semi-annually for recurring payments
   When User adds Recurring details for Invalid AVS
   Then Payment has been declined and verifying AVS error message
   When Switching to dashboard tab
   Then Clicking the new alert and verifying the AVS alert text
   
Declining Recurring CC Payment - Annually using AVS
   [Tags]    Regression    

   Given User navigates to Payments tab
   When User selects Recurring Tab and then Selects Account Location
   And User clicks on Add customer button
   And User creates a Business CC Customer
   Then Selecting frequency as annually for recurring payments
   When User adds Recurring details for Invalid AVS
   Then Payment has been declined and verifying AVS error message
   When Switching to dashboard tab
   Then Clicking the new alert and verifying the AVS alert text
   
##    ===================================================================================================================================================

Declining Installment CC Payment - Weekly using AVS
    [Tags]     Smoke   Regression

    Given User navigates to Payments tab
    When User selects Installment Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    Then Selecting frequency as weekly for installment payments
	When User adds Installment details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response Address Verification Failed  
    When Switching to dashboard tab
    Then Clicking the new alert and verifying the AVS alert text
    
Declining Installment CC Payment - 1st and 15th using AVS
    [Tags]    Regression        
    
    Given User navigates to Payments tab
    When User selects Installment Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    Then Selecting frequency as 1st and 15th for installment payments
	When User adds Installment details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response Address Verification Failed  
    When Switching to dashboard tab
    Then Clicking the new alert and verifying the AVS alert text

Declining Installment CC Payment - Monthly using AVS
    [Tags]     Regression   
    
    Given User navigates to Payments tab
    When User selects Installment Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    Then Selecting frequency as monthly for installment payments payments
	When User adds Installment details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response Address Verification Failed  
    When Switching to dashboard tab
    Then Clicking the new alert and verifying the AVS alert text
    
Declining Installment CC Payment - Quarterly using AVS
    [Tags]     Regression   
    
    Given User navigates to Payments tab
    When User selects Installment Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    Then Selecting frequency as quarterly for installment payments
	When User adds Installment details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response Address Verification Failed  
    When Switching to dashboard tab
    Then Clicking the new alert and verifying the AVS alert text

 Declining Installment CC Payment - Semi-Annually using AVS
    [Tags]     Regression   
    
    Given User navigates to Payments tab
    When User selects Installment Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    Then Selecting frequency as semi-annually for installment payments
	When User adds Installment details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response Address Verification Failed  
    When Switching to dashboard tab
    Then Clicking the new alert and verifying the AVS alert text    

 Declining Installment CC Payment - Annually using AVS
    [Tags]    Regression
    
    Given User navigates to Payments tab
    When User selects Installment Tab and then Selects Account Location
    And User clicks on Add customer button
    And User creates a Business CC Customer 
    Then Selecting frequency as annually for installment payments
	When User adds Installment details for Invalid AVS
    Then Payment gets declined
    And Page Should contain response Address Verification Failed  
    When Switching to dashboard tab
    Then Clicking the new alert and verifying the AVS alert text 








