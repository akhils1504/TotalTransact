*** Settings ***
Documentation       Creating A Customer in Specified Enviornment

Library     DatabaseLibrary
Library     SeleniumLibrary                                                          timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library     String                                                                   #In TotalTransact > Roboto Standard Libraries > String    
Library     FakerLibrary   
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Delete custom fields
                  ...                 AND                 A User Login to Payment Portal clicks on Settings tab
                  
Test Setup        Run Keyword And Ignore Error    Login the user    

Test Teardown     Run keywords    Test Ui Teardown
...               AND             Deleting Any Failed TC Custom Fields
...               AND             Logging out the user when user is already logged in 

Suite Teardown    Run keywords    Delete custom fields   
                  ...                 AND                 Close Browser

*** Variables ***
${browser}    chrome
${fees}    10
${f_name}    Akhil
${l_name}    Kumar
${email}    akhil.kumar@finastraa.com
${routing_no}    011000015
${acc_no}    123456
${phone_no}    55539594787
${message_area_text}    A blue fox went to the park
${disclaimer_text}    Terms and condition sample text
${footer_message_text}    footer sample text message
${hperlink_text}    Click here to view the terms and conditions
*** Keywords ***
Delete custom fields
    Connect database
    Search account and delete custom field data
    Disconnect database
   
Search account and delete custom field data
    ${query}  Set Variable    select ID from ent_processing_account where name='${processing_account_search_string}'
    Log to console  ${query}
    ${query_result}    Query    ${query} 
    ${processing_account_id}   Convert To String    ${query_result[0][0]}
    ${query}  Set Variable    delete from ENT_PRC_ACCOUNT_CUSTOM_FIELD where PROCESSING_ACCOUNT_ID='${processing_account_id}'
    Log to console  ${query}
    Execute Sql String    ${query}   

Deleting Any Failed TC Custom Fields
    Run Keyword And Ignore Error        Finalizing which keyword to run 
       
Finalizing which keyword to run
        
    Run Keyword    Get the window title
    ${decision}=    Set Variable    ${win_title}
    log    ${decision}
    Run Keyword If   '${decision}' == 'Hosted Payment Page'    Final Call from HPP
    Run Keyword If    '${decision}' == 'Small Business Payment Suite'    Failing in Payment Settings Page     

Final Call from HPP
    Run Keyword If Test Failed    Deleting the custom field on failure in HPP  

Deleting the custom field on failure in HPP
    Get the window title
    ${status}    Run Keyword And Return Status    Run Keyword If    '${win_title}' == 'Hosted Payment Page'    Failing in the Hpp page    
    Run Keyword If    '${status}' == 'True'    Deleting all the existing custom    
       
Failing in the Hpp page
    ${browser_window}    Run Keyword And Return Status    Page Should Contain    Tell Us About Yourself                      
    # Run Keyword If    '${browser_window}' == 'True'    Close Window
     Run Keyword If    '${browser_window}' == 'True'    Closing Hosted Payment page and switching to main window
     Logging out the user when user is already logged in
    # # And A user login with new session   
     # A user login with new session    
    # Run Keyword If    '${browser_window}' == 'True'    Switch Window    locator=NEW  
    # Reload Page
    # Run Keyword If    '${browser_window}' == 'True'    Logging out the user when user is already logged in    
    
Deleting all the existing custom
    # A User Login to Payment Portal clicks on Settings tab   ===>
    A user login with new session 
    User select Account Location
    User Delete Custom field in Payment Settings Page
    # ${t_count}=  Execute Javascript    return Ext.ComponentQuery.query("#savedcustomdatagridpanel")[0].getStore().count();
    # Set Suite Variable    \${t_count}  ${t_count}    
    # Log    ${t_count}
    # ${status}    Set Variable    True
    # ${status_ret}    Set Variable    0
    
    # FOR    ${status_ret}    IN RANGE    0    ${t_count}
    # \    Log    ${status_ret}   
    # \    User Delete Custom field in Payment Settings Page 
    # END  
Failing in Payment Settings Page
    Run Keyword If Test Failed    Failing in payment page             

Failing in payment page
    Reload page
    Get the window title
    ${browser_window}    Run Keyword And Return Status    Should Be Equal    ${win_title}    Small Business Payment Suite    ignoreCase=True
    Run Keyword If    '${browser_window}' == 'True'    Delete Customs    
Delete Customs    
    User select Payment Settings tab
    User select Account Location
    User Delete Custom field in Payment Settings Page
        
Login the user    
    Run Keywords    Logging out the user when user is already logged in
                  ...                 AND                 A user login with new session
          
Get the window title
     ${win_title}=  Execute Javascript  return Ext.query('title')[0].innerHTML;
    Set Suite Variable    \${win_title}  ${win_title}   

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

A User Login to Payment Portal clicks on Settings tab
    Login to Payment Portal Using UI
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV005
    
A user login with new session
    Input Text                           username        ${username}
    Input Text                           password        ${password}
    Click Button                         submit
    Wait Until Page Contains Element      xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Settings')]    timeout=30 seconds    error=None
    Select Navigation Tab    NV005

User select Account Location
    Select Combobox Value JS    \#paymentsettingspanel > #accountlocationcombobox    Downtown
    Sleep    10s   #Dont remove failing  TC  

User select Account Location in Hosted Payment settings page
    Sleep    10s
    Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#hostedpaymentpagepanel > #accountlocationcombobox    Downtown
    # Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Downtown
    Sleep    10s   #Dont remove failing  TC     
    
User select Hosted Payment tab
    Sleep    3s    
    Execute Javascript    var tabPanel = Ext.ComponentQuery.query('#tier2settingstabpanel')[0],
            ...               hppTab = Ext.ComponentQuery.query('#hostedpaymentpagepanel')[0];
            ...               tabPanel.setActiveTab(hppTab);

    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields

User select Payment Settings tab
     Execute Javascript    var tabPanel = Ext.ComponentQuery.query('#tier2settingstabpanel')[0],
            ...               paymentTab = Ext.ComponentQuery.query('#paymentsettingspanel')[0];
            ...               tabPanel.setActiveTab(paymentTab);
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Settings
            
Extracting HPP URL
    Sleep    2s     
    ${hpp_url}=  Execute Javascript  return Ext.ComponentQuery.query('#paymentpageurl')[0].getEl().down('a').dom.href
    Set Suite Variable    \${hpp_url}  ${hpp_url}    
               
User clicks on Save button on self-service settings page
    Execute Javascript    var btn=Ext.ComponentQuery.query("#buttontoolbar #savebutton")[0];
            ...               btn.fireEvent("click",btn); 
   
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Self-Service settings saved.
    Wait Until Ext Element Is Enabled    \#ok
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok
            
User unchecks Level 2 Data Field checkbox in self-service settings page
    Execute Javascript    var w=Ext.ComponentQuery.query("#displaylevel2datafields[boxLabel='Display Level 2 Data Fields']")[0];
            ...               w.setValue(false);    
   
User checks Level 2 Data Field checkbox in self-service settings page
    Execute Javascript    var w=Ext.ComponentQuery.query("#displaylevel2datafields[boxLabel='Display Level 2 Data Fields']")[0];
            ...               w.setValue(true);    
    
User enter data in the Receipt and Message Area and click save button
    Set Textfield Value JS    \#custommessagearea    ${message_area_text}
    Check Checkbox JS    \#displayreceiptmessage
    Wait Until Ext Element Is Enabled    \#receiptandmessage > \#buttontoolbar > \#savebutton[text=Save]   
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#receiptandmessage > \#buttontoolbar > \#savebutton[text=Save]
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Receipt and Message settings saved.    timeout=30 seconds   
    Sleep    5s     
    Wait Until Keyword Succeeds    15s    15s    Wait Until Ext Element Is Enabled    \#ok
    Sleep    5s 
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#ok
      
    
Checking all the checkbox options if its not selected
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Email"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Email"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing Address"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing Address"]    
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing City"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing City"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing State"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing State"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing Postal Code"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing Postal Code"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Payment Account"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Payment Account"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Expiration Date"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Expiration Date"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Authorization Code"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Authorization Code"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Phone"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Phone"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Name on Account"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Name on Account"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Account Type"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Account Type"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Transaction Id"]    true
    Run Keyword If    '${ret_code}' == 'False'    Check Checkbox JS    \#receiptandmessage checkbox[boxLabel="Transaction Id"]
    
Unchecking all the checkbox options if its selected
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Email"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Email"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing Address"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing Address"]    
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing City"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing City"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing State"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing State"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Billing Postal Code"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Billing Postal Code"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Payment Account"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Payment Account"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Expiration Date"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Expiration Date"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Authorization Code"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Authorization Code"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Phone"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Phone"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Name on Account"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Name on Account"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Account Type"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Account Type"]
    ${ret_code}    Run Keyword And Return Status    Verify Checkbox Value    \#receiptandmessage checkbox[boxLabel="Transaction Id"]    true
    Run Keyword If    '${ret_code}' == 'True'    Uncheck Checkbox JS    \#receiptandmessage checkbox[boxLabel="Transaction Id"]
    
Clicking on the Receipt and Message Save button
    Sleep    3s     #Removing causing failure  
    Click Ext button JS    \#receiptandmessage \#savebutton
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Receipt and Message settings saved.
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    OK 
    Sleep    5s      #Removing causing failure        
    Click Ext button JS    \#ok
    Sleep    3s    #Removing causing failure

    
Entering details in Tell Us About Yourself section in Hosted Payment Page
    Extracting HPP URL
    Execute Javascript    window.open("${hpp_url}");
    Switch Window    locator=NEW    
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Tell Us About Yourself    
    Set Textfield Value JS    textfield[name=firstname]    ${f_name}
    Set Textfield Value JS    textfield[name=lastname]    ${l_name}
    Set Textfield Value JS    textfield[name=address]    MedicalCollege
    Set Textfield Value JS    textfield[name=city]    Trivandrum
    Set Textfield Value JS    textfield[name=state]    CA
    Set Textfield Value JS    textfield[name=postalcode]    12345
    Set Textfield Value JS    textfield[name=email]    ${email}
    Set Textfield Value JS    textfield[name=phonenumber]    ${phone_no}
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#informationnextbutton  
    
Entering details in Payment Information section in Hosted Payment Page with Checking Account    # checking option selection
 
    Set Textfield Value JS    textfield[name=amount]    ${fees}
    Set Textfield Value JS    textfield[name=nameonaccount]    ${f_name}
    Set Textfield Value JS    textfield[name=routingnumber]    ${routing_no}
    Set Textfield Value JS    textfield[name=accountnumber]    ${acc_no}
    Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymenttype    CHECKING
    Wait Until Keyword Succeeds    15s    15s    Wait Until Ext Element Is Enabled    \#paymentnextbutton
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#paymentnextbutton
    
Entering details in Payment Information section in Hosted Payment Page with Savings Account      # saving option selection
  
    Set Textfield Value JS    textfield[name=amount]    ${fees}
    Set Textfield Value JS    textfield[name=nameonaccount]    ${f_name}
    Set Textfield Value JS    textfield[name=routingnumber]    ${routing_no}
    Set Textfield Value JS    textfield[name=accountnumber]    ${acc_no}
    #sleep    1s   ##Removing causes altrenate failure
    Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymenttype    SAVINGS
    #sleep    1s   ##Removing causes altrenate failure
    Wait Until Keyword Succeeds    15s    15s    Click Ext button JS    \#paymentnextbutton
    
Entering details in Payment Information section in Hosted Payment Page with Credit Card Account     # CC option selection
  
    Set Textfield Value JS    textfield[name=amount]    ${fees}
    Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymenttype    Credit Card
    Set Textfield Value JS    textfield[name=nameoncard]    ${f_name}
    Set Textfield Value JS    textfield[name=routingnumber]    ${routing_no}
    Set Textfield Value JS    textfield[name=accountnumber]    ${acc_no}
    Set Textfield Value JS    textfield[name=cardnumber]    4111111111111111
    Set Textfield Value JS    textfield[name=cvv]    999
    Set Textfield Value JS    textfield[name=expirationdate]    12/25
    Set Textfield Value JS    textfield[name=invoicenumber]    123
    Set Textfield Value JS    textfield[name=purchaseorder]    12345
    Set Textfield Value JS    textfield[name=taxamount]    1
    
     # Execute Javascript  return Ext.ComponentQuery.query("#usebillingaddress[name=usebillingaddress]")
   # Check Checkbox JS   \#usebillingaddress
    # Check Checkbox JS    \#paymentnextbutton[name=usebillingaddress]  
      
Entering details in Review and Submit section in Hosted Payment Page
    # sleep    1s
    Wait Until Keyword Succeeds    15s    15s    Check Checkbox JS    \#agreementofterms  
    Bypassing the Captcha code
      
Entering details in Payment Information section in Hosted Payment Page with Checking Account with an Invoice Custom field
   
    ${field_name}=    Convert To Lowercase    ${Customfieldname}
    # Log    ${field_name}
    ${field_name}=    Convert To Title Case    ${field_name}
    # Log    ${field_name}     
    Wait Until Keyword Succeeds    30s    15s    Wait Until Page Contains    ${field_name}    timeout=30s
    Set Textfield Value JS    textfield[name=amount]    ${fees}
    # Log    ${Customfieldname}    
    # Wait Until Keyword Succeeds    30s    15s
    # Wait Until Page Contains    ${field_name}    timeout=30s
    # Log    ${field_name}    
    # Wait Until Page Contains    ${field_name}    timeout=30s
    Set Textfield Value JS    textfield[name=nameonaccount]    ${f_name}
    Set Textfield Value JS    textfield[name=routingnumber]    ${routing_no}
    Set Textfield Value JS    textfield[name=accountnumber]    ${acc_no}
    # Wait Until Keyword Succeeds    15s    15s    Should Be Equal    ${Customfieldname}    ${Customfieldname}    ignore_case=True  
    Execute Javascript    Ext.ComponentQuery.query("[customFieldType=TEXT][customFieldType=TEXT]")[0].setValue("trial");
    Select Combobox Value JS    \#paymenttype    CHECKING
    Click Ext button JS    \#paymentnextbutton
           
Check Uncheck Chekbox
    [Arguments]    ${rowKey}    ${rowVal}    ${columnLocator}    ${checkVal}    ${index_value}    ${checkcolname}    
    Execute Javascript    var chkcol = Ext.ComponentQuery.query('${columnLocator}')[${index_value}];
            ...               Ext.ComponentQuery.query('${columnLocator}')[${index_value}].up('grid').getStore().findRecord('${rowKey}', '${rowVal}').set('${checkcolname}', ${checkVal});     
            ...               chkcol.fireEvent('checkchange', chkcol, chkcol.up('grid').getStore().find('${rowKey}', '${rowVal}'), ${checkVal});
 
# Verifying the created custom feild in Hosted Payment Settings page
    # Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${Customfieldname}
     
Bypassing the Captcha code
    Execute Javascript    var button =  Ext.ComponentQuery.query('#reviewpanel #submitbutton')[0],    form = button.up('#layout').getForm(),             
            ...               controller = HPP.getApplication().getHostedPaymentController(),   
            ...               recaptchaResponseField = Ext.get('g-recaptcha-response'),
            ...               recaptchaResponseValue = !Ext.isEmpty(recaptchaResponseField) ? recaptchaResponseField.getValue(): null,
            ...               fieldContainer = Ext.ComponentQuery.query('#customdata')[0],
            ...               customData = {};
            ...               if(!Ext.isEmpty(fieldContainer)){
            ...               Ext.Array.forEach(Ext.ComponentQuery.query('field', fieldContainer), function (field) {
            ...               var rawValue = encodeURIComponent(field.getRawValue());
            ...               if (rawValue) {customData[field.getItemId()] = {
            ...               label: field.customFieldName,
            ...               value: rawValue }; } });};
            ...               form.submit({
            ...               url: sbpsutil.contextPath+'/payment/save/'+sbpsutil.hostpageId,
            ...               waitMsg: 'Waiting...',
            ...               params: {
            ...               'ignoreCaptcha': true,
            ...               'recaptcha_response_field': recaptchaResponseValue,
            ...               'hostpageid': sbpsutil.hostpageId,
            ...               'entProcessingAccountId': sbpsutil.accountLocationId,
            ...               'isRequireCaptcha': sbpsutil.isRequireCaptcha,
            ...               'usertz': Ext.Date.getGMTOffset(new Date()),
            ...               'customdata': customData?Ext.encode(customData):null},
            ...               success: function (form, action) {var jsonData = Ext.decode(action.response.responseText);
            ...               if (jsonData.success === true) {
            ...               var windowPanel = Ext.create('HPP.view.ReceiptWindow');
            ...               controller.populateReceipt(windowPanel, jsonData);}
            ...               else{
            ...               Message.alert(jsonData.errors[0], messages.MS000.Error());  }},
            ...               failure: function (form, action) {
            ...               var jsonData = Ext.decode(action.response.responseText);
            ...               if (jsonData.success === false) {
            ...               Message.alert(jsonData.errors[0], messages.MS000.Error()); }
            ...               console.log('server-side failure with jason value ' + jsonData);}});

Confirming the text entered in the Message Settings area
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${message_area_text}    timeout=15s    
    Close Window
    Switch Window    locator=MAIN   
    
User is Logged Out
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Logout    
    Wait Until Keyword Succeeds    15s    15s    Click Element    //*[@class="x-component x-fit-item x-component-default"]/a[1]    
  
Logging out the user when user is already logged in 
    ${status}    Run Keyword And Return Status    Wait Until Page Contains    Logout
    Wait Until Keyword Succeeds    15s    15s    Run Keyword If    '${status}' == 'True'    User is Logged Out 

Closing Hosted Payment page and switching to main window
   Wait Until Keyword Succeeds    15s    15s    Close Window
   Wait Until Keyword Succeeds    15s    15s    Switch Window    locator=MAIN      

Enter Message text in the Message text in Self Service payent settinsg area
    ${footer_text}    Set Variable    ABCD
    Sleep    3s   
    Execute Javascript    Ext.ComponentQuery.query("#optouttext[fieldLabel=Message Text]")[0].setValue("ABCD");
    Set Suite Variable    \${footer_text}  ${footer_text}  
    ${get_foot_text}=  Execute Javascript    return Ext.ComponentQuery.query("#optouttext[fieldLabel=Message Text]")[0].getValue();
    Set Suite Variable    \${get_foot_text}  ${get_foot_text}
    Should Be Equal As Strings    ${footer_text}    ${get_foot_text}    
    # Set Textfield Value JS    \#optouttext[fieldLabel=Message Text]    ${footer_message_text}
    # Wait Until Page Contains    ${footer_message_text}  
    
Verifying the created Custom Field in Payment Settings
   Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${Customfieldname}    timeout=15s 
       
      
Verifying the created Custom Field in Hosted Payment Settings page
        Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${Customfieldname}    timeout=15s
     
Verifying the created Custom Field in Hosted Payment page
    # Checking inside HPP Page
    ${converted}=    Convert To Lowercase    ${Customfieldname}
    ${converted}=    Convert To Title Case    ${converted}
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${converted}    timeout=15s    
    
Selecting the Active on page checkbox
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields    timeout=15s    
    Check Uncheck Chekbox    customFieldName    ${Customfieldname}    \#existingcustomdatafields checkcolumn    true    0    isHostPageEnabled

Selecting the Include in Receipt checkbox
    Sleep    5s    
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields    timeout=15s 
    Check Uncheck Chekbox    customFieldName    ${Customfieldname}    \#existingcustomdatafields checkcolumn    true    1    isHostPageIncludeInReceipt  

Selecting the Required checkbox
      Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields    timeout=15s 
      Check Uncheck Chekbox    customFieldName    ${Customfieldname}    \#existingcustomdatafields checkcolumn    true    2    isHostPageRequired   

Unselecting the Active on page checkbox
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields    timeout=15s 
    Check Uncheck Chekbox    customFieldName    ${Customfieldname}    \#existingcustomdatafields checkcolumn    false    0    isHostPageEnabled

Unselecting the Include in Receipt checkbox
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields    timeout=15s 
    Check Uncheck Chekbox    customFieldName    ${Customfieldname}    \#existingcustomdatafields checkcolumn    false    1    isHostPageIncludeInReceipt  

Unselecting the Required checkbox
      Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Custom Data Fields    timeout=15s 
      Check Uncheck Chekbox    customFieldName    ${Customfieldname}    \#existingcustomdatafields checkcolumn    false    2    isHostPageRequired   

Checking whether the AVS checkbox in checked state
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Self-Service Payment Settings    timeout=15s
    ${bool_stat}=  Execute Javascript  return Ext.ComponentQuery.query("#cardprocessingsettings #requireavs")[0].value; 
    should be equal    True    true    ignore_case=True
    
Checking whether the CVV checkbox in checked state
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Self-Service Payment Settings    timeout=15s
    ${bool_stat}=  Execute Javascript  return Ext.ComponentQuery.query("#cardprocessingsettings #requirecvv")[0].value; 
    should be equal    True    true    ignore_case=True
    

User Create Custom fields in payment Settings page
    CommonUIKeywordsAndVariables.User Create Custom fields in payment Settings page
    
User Delete Custom field in Payment Settings Page
    CommonUIKeywordsAndVariables.User Delete Custom field in Payment Settings Page
    
User create new fees
    Create fees in the Payment Settings
    
User deletes the fees
    Delete fees from payemnt Settings

Opening the Hosted Payment Page and checking the title
    Extracting HPP URL
    Execute Javascript    window.open("${hpp_url}");
    Switch Window    locator=NEW    
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Tell Us About Yourself  
    ${title}=    Get Title  
    Should Be True    '${title}'=='Hosted Payment Page'    


    
     
Verifying the Level Data 2 extra fields is not present
     Set Textfield Value JS    textfield[name=amount]    ${fees}
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymenttype    Credit Card
     Set Textfield Value JS    textfield[name=nameoncard]    ${f_name}
     Set Textfield Value JS    textfield[name=routingnumber]    ${routing_no}
     Set Textfield Value JS    textfield[name=accountnumber]    ${acc_no}
     Set Textfield Value JS    textfield[name=cardnumber]    4111111111111111
     Set Textfield Value JS    textfield[name=cvv]    999
     Set Textfield Value JS    textfield[name=expirationdate]    12/25
     Wait Until Keyword Succeeds    15s    15s    Element Should Not Be Visible    //*[@id="invoicenumber"]       
     Wait Until Keyword Succeeds    15s    15s    Element Should Not Be Visible    //*[@id="purchaseorder"]   
     Wait Until Keyword Succeeds    15s    15s    Element Should Not Be Visible    //*[@id="taxamount"]   
     Closing Hosted Payment page and switching to main window
    
Verifying the Level Data 2 extra fields is present
     Set Textfield Value JS    textfield[name=amount]    ${fees}
     Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymenttype    Credit Card
     Wait Until Keyword Succeeds    15s    15s    Page should Contain    Invoice Number 
     Wait Until Keyword Succeeds    15s    15s    Page Should Contain    Purchase Order
     Wait Until Keyword Succeeds    15s    15s    Page Should Contain    Tax Amount
     Close Window
     Switch Window    locator=MAIN  
     
Verifying the fees in Payment Information section in Hosted Payment Page with Checking Account

    
     Press Keys    //*[@id="amount"]    ${fees}
     Set Textfield Value JS    textfield[name=nameonaccount]    ${f_name}
     Set Textfield Value JS    textfield[name=routingnumber]    ${routing_no}
     Set Textfield Value JS    textfield[name=accountnumber]    ${acc_no}
     # Wait Until Keyword Succeeds    15s    15s    Select Combobox Value JS    \#paymenttype    CHECKING
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    $10.20    timeout=20s
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    $20.20    timeout=20s
    
Selecting the newly created fee
    
    ${created_fees}=  Execute Javascript    return Ext.ComponentQuery.query("selfservicepaymentsettings #feeschedule")[0].getStore().data.items[0].data.description;
    Set Suite Variable    \${created_fees}  ${created_fees}
    log    ${created_fees}
    Execute Javascript    var fee_combobox = Ext.ComponentQuery.query('selfservicepaymentsettings #feeschedule')[0];
            ...               var store = fee_combobox.getStore();
            ...               var fee_value = store.findRecord('name', '${created_fees}');
            ...               fee_combobox.setValue(fee_value);

Changing the fees to default value
    
    Execute Javascript    var fee_combobox = Ext.ComponentQuery.query('selfservicepaymentsettings #feeschedule')[0];
            ...               var store = fee_combobox.getStore();
            ...               var fee_value = store.findRecord('name', 'ZERO FEE SCHEDULE');
            ...               fee_combobox.setValue(fee_value);
User deletes the created fees
    
    log    ${created_fees}
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${created_fees}  
    Execute Javascript    var grid = Ext.ComponentQuery.query('#savedfeesgridpanel')[0];
            ...               var store = grid.getStore(),
            ...               record = store.findRecord('name', '${created_fees}');
            ...               var model = grid.getSelectionModel(); model.select(record);
            ...               var removebutton = Ext.ComponentQuery.query('#removebutton')[2]; removebutton.fireEvent('click', removebutton)
    Wait Until Page Contains    Are you sure       timeout=30 seconds    error=None
    Click Ext Button JS     button#ok{isVisible(true)}
    
Verifying the created fees is removed 
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Does Not Contain    ${created_fees}       
     
Selecting the Top of page radio button
    Execute Javascript    var a=Ext.ComponentQuery.query("#topofpage")[0];
            ...               a.setValue(true); 
              
Selecting the Bottom of page radio button
    Execute Javascript    var a=Ext.ComponentQuery.query("#bottomofpage")[0];
            ...               a.setValue(true); 
           
Selecting the Dont display radio button
    Execute Javascript    var a=Ext.ComponentQuery.query("#dontdisplay")[0];
            ...               a.setValue(true); 
              
Checking the Contact us area is present
     Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Contact Us
     
Checking the Contact us area is not present
     Wait Until Keyword Succeeds    15s    15s    Element Should Not Be Visible   //*[contains(text(),'Contact Us')]
        
Entering text in Disclaimer textbox
    
    Execute Javascript    var a=Ext.ComponentQuery.query("#disclaimertext")[0];
            ...               a.setValue("${disclaimer_text}");  
Checking the Agree to terms checkbox
    Execute Javascript    var a=Ext.ComponentQuery.query("#requireusertoagreetoterms[boxLabel='Require User to agree to terms']")[0];
            ...               a.setValue(true);       
Verifying the terms and condition text
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    Terms and Conditions
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${disclaimer_text}
Entering text in Footer message textbox
    Execute Javascript    var a=Ext.ComponentQuery.query("#optouttext")[0];
            ...               a.setValue("${footer_message_text}");  
 
Verifying the footer text in Hosted payment page
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${footer_message_text}
    
Verifying the Terms and condition hyperlink is available
    Wait Until Keyword Succeeds    15s    15s    Wait Until Page Contains    ${hperlink_text} 
        
 Clicking on the Terms and Condtions hyperlink
    Click Element    //b[text()='Click here to view the terms and conditions']   

        
*** Test Cases ***
       
To Verify Save Button for Display Level 2 data fields Settings in Self-Service Payment Settings section when Level 2 data checkbox is not checked
    [Tags]    Smoke    Regression
   
    Given User select Hosted Payment tab
    And User select Account Location in Hosted Payment settings page
    When User unchecks Level 2 Data Field checkbox in self-service settings page
    And Changing the fees to default value
    And User clicks on Save button on self-service settings page
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    Then Verifying the Level Data 2 extra fields is not present
     

To Verify “Save Button” for Display Level 2 data fields Settings in Self-Service Payment Settings section when Level 2 data checkbox is checked
    [Tags]    Smoke    Regression
 
    Given User select Hosted Payment tab
    And User select Account Location in Hosted Payment settings page
    When User checks Level 2 Data Field checkbox in self-service settings page
    And Changing the fees to default value
    And User clicks on Save button on self-service settings page
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    Then Verifying the Level Data 2 extra fields is present
      
To Verify “Require CVV” and “Require AVS” check box displayed disable and selected by default
    [Tags]    Smoke    Regression
    
    Given User select Hosted Payment tab
    When User select Account Location in Hosted Payment settings page
    Then Checking whether the CVV checkbox in checked state
    And Checking whether the AVS checkbox in checked state
    
To Verify Save button for Fee Schedule in Self-Service Payment Settings section
    [Tags]    Smoke    Regression
     
    Given User select Payment Settings tab
    And User select Account Location
    When User create new fees
    And User select Hosted Payment tab
    And User select Account Location in Hosted Payment settings page
    Then Selecting the newly created fee 
    And User clicks on Save button on self-service settings page
    When Entering details in Tell Us About Yourself section in Hosted Payment Page    
    Then Verifying the fees in Payment Information section in Hosted Payment Page with Checking Account
    When Closing Hosted Payment page and switching to main window    
    And Logging out the user when user is already logged in    
    And A user login with new session
    And User select Hosted Payment tab
    And User select Account Location in Hosted Payment settings page
    Then Changing the fees to default value
    And User clicks on Save button on self-service settings page
    When User select Payment Settings tab
    And User select Account Location
    And User deletes the created fees
    Then Verifying the created fees is removed

To Verify functionality of Radio Button and Save button for Display Contact Info 1 section in Self-Service Payment settings section
     [Tags]    Smoke    Regression
     
     Given User select Hosted Payment tab
     And User select Account Location in Hosted Payment settings page
     When Selecting the Top of page radio button
     And User clicks on Save button on self-service settings page
     And Entering details in Tell Us About Yourself section in Hosted Payment Page
     Then Checking the Contact us area is present
     And Closing Hosted Payment page and switching to main window
     
# To Verify functionality of Radio Button and Save button for Display Contact Info 2 section in Self-Service Payment settings section-----> There is an open Bug Wont work
     #[Tags]    Smoke    Regression
     
     # User select Hosted Payment tab
     # User select Account Location in Hosted Payment settings page
     # Selecting the Top of page radio button
     # User clicks on Save button on self-service settings page
     # Entering details in Tell Us About Yourself section in Hosted Payment Page
     # Checking the Contact us area is present
     # Closing Hosted Payment page and switching to main window
     
To Verify functionality of Radio Button and Save button for Display Contact Info 3 section in Self-Service Payment settings section
     [Tags]    Smoke    Regression
     
     Given User select Hosted Payment tab
     And User select Account Location in Hosted Payment settings page
     When Selecting the Dont display radio button
     And User clicks on Save button on self-service settings page
     And Entering details in Tell Us About Yourself section in Hosted Payment Page
     Then Checking the Contact us area is not present
     And Closing Hosted Payment page and switching to main window
     

To Verify Declaimer Text / Terms and Conditions text box and select “Require User to agree to Terms” check box
      [Tags]    Smoke    Regression
    
      Given User select Hosted Payment tab
      And User select Account Location in Hosted Payment settings page
      When Entering text in Disclaimer textbox
      And Checking the Agree to terms checkbox
      And Changing the fees to default value
      And User clicks on Save button on self-service settings page
      And Entering details in Tell Us About Yourself section in Hosted Payment Page
      And Entering details in Payment Information section in Hosted Payment Page with Checking Account
      Then Verifying the Terms and condition hyperlink is available
      And Clicking on the Terms and Condtions hyperlink
      Then Verifying the terms and condition text
      And Closing Hosted Payment page and switching to main window
      
To Verify Footer message textbox in the HPP page
      [Tags]    Smoke    Regression
    
      Given User select Hosted Payment tab       
      And User select Account Location in Hosted Payment settings page
      When Entering text in Footer message textbox
      Then User clicks on Save button on self-service settings page
      When Entering details in Tell Us About Yourself section in Hosted Payment Page
      And Entering details in Payment Information section in Hosted Payment Page with Checking Account      
      Then Verifying the Terms and condition hyperlink is available
      And Clicking on the Terms and Condtions hyperlink
      And Verifying the footer text in Hosted payment page
      And Closing Hosted Payment page and switching to main window
     

To Verify Payment Page URL
    [Tags]    Smoke    Regression
    
    Given User select Hosted Payment tab
    When User select Account Location in Hosted Payment settings page
    Then Opening the Hosted Payment Page and checking the title 
    And Closing Hosted Payment page and switching to main window 

# ##################################################################################################################################################      

To Verify Custom Data Fields added from Payment settings are displayed in Custom Data Fields section 
    
    [Tags]    Smoke    Regression 
    Given User select Payment Settings tab   
    And User select Account Location   
    When User Create Custom fields in payment Settings page
    And User select Hosted Payment tab
    Then Verifying the created Custom Field in Payment Settings
    When User select Payment Settings tab
    Then User Delete Custom field in Payment Settings Page
    
Verify the functionality of select/deselect of checkbox
    [Tags]    Smoke    Regression    
    Given User select Payment Settings tab
    And User select Account Location   
    When User Create Custom fields in payment Settings page
    And User select Hosted Payment tab
    Then Verifying the created Custom Field in Payment Settings
    When Selecting the Active on page checkbox
    And Selecting the Include in Receipt checkbox
    And Selecting the Required checkbox
    When Unselecting the Active on page checkbox
    And Unselecting the Include in Receipt checkbox
    And Unselecting the Required checkbox
    And User select Payment Settings tab
    Then User Delete Custom field in Payment Settings Page
    
Verify functionality of “Custom Data Field” section of Active on Page checkbox 
    
    [Tags]    Smoke    Regression
    # Given Logging out the user when user is already logged in
    # When A user login with new session
    Given User select Payment Settings tab
    And User select Account Location   
    When User Create Custom fields in payment Settings page
    And User select Hosted Payment tab
    And Selecting the Active on page checkbox
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    Then Verifying the created Custom Field in Hosted Payment page  
    When Closing Hosted Payment page and switching to main window
    And Logging out the user when user is already logged in
    And A user login with new session
    And User select Payment Settings tab
    And User select Account Location
    Then User Delete Custom field in Payment Settings Page
   

Verify functionality of “Custom Data Field” section of Include in Receipt checkbox
    #This TC will fail if any other required custom field is present in the page.
    [Tags]    Smoke    Regression
    # Given Logging out the user when user is already logged in
    # When A user login with new session
    Given User select Payment Settings tab
    And User select Account Location   
    When User Create Custom fields in payment Settings page
    Then Verifying the created Custom Field in Payment Settings     
    When User select Hosted Payment tab
    And Selecting the Include in Receipt checkbox
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    Then Entering details in Payment Information section in Hosted Payment Page with Checking Account with an Invoice Custom field
    When Entering details in Review and Submit section in Hosted Payment Page  ##Receipt cant be verified due to Captcha issue 
    And Closing Hosted Payment page and switching to main window
    And Logging out the user when user is already logged in
    And A user login with new session
    And User select Account Location
    Then User Delete Custom field in Payment Settings Page
   
Verify functionality of “Custom Data Field” section of Required checkbox
    ##This TC will fail if any other required field is present in the page.
    [Tags]    Smoke    Regression
    # Given Logging out the user when user is already logged in
    # When A user login with new session
    # User select Payment Settings tab
    Given User select Account Location   
    And User Create Custom fields in payment Settings page
    When User select Hosted Payment tab
    Then Verifying the created Custom Field in Hosted Payment Settings page     
    When User select Hosted Payment tab
    And Selecting the Required checkbox
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    Then Entering details in Payment Information section in Hosted Payment Page with Checking Account with an Invoice Custom field 
    When Closing Hosted Payment page and switching to main window
    And Logging out the user when user is already logged in
    And A user login with new session
    And User select Account Location
    Then User Delete Custom field in Payment Settings Page    

# # ##################################################################################################################    

To Verify functionality of Check boxes and Save button on Receipt and Message section  
    
    [Tags]    Smoke    Regression
    Given User select Hosted Payment tab
    And User select Account Location
    When Checking all the checkbox options if its not selected
    Then Clicking on the Receipt and Message Save button
    When Unchecking all the checkbox options if its selected
    Then Clicking on the Receipt and Message Save button  

To Verify “Custom Message Area” and “Display Receipt Message” check box using Checking Account in Hosted Payment Page
    
    [Tags]    Smoke    Regression       
    # Given Logging out the user when user is already logged in
    # And A user login with new session
    Given User select Hosted Payment tab
    And User select Account Location
    When Checking all the checkbox options if its not selected
    And User enter data in the Receipt and Message Area and click save button
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    And Entering details in Payment Information section in Hosted Payment Page with Checking Account
    Then Entering details in Review and Submit section in Hosted Payment Page
    And Confirming the text entered in the Message Settings area

  
        
Verify user is able to create Hosted Payment with ACH Savings payment account
    
    [Tags]    Smoke    Regression    
    # Given Logging out the user when user is already logged in
    # And A user login with new session
    Given User select Hosted Payment tab
    And User select Account Location
    When Checking all the checkbox options if its not selected
    And User enter data in the Receipt and Message Area and click save button
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    And Entering details in Payment Information section in Hosted Payment Page with Savings Account
    Then Entering details in Review and Submit section in Hosted Payment Page
    And Confirming the text entered in the Message Settings area 

    
Verify user is able to create Hosted Payment with CC payment account
    
    [Tags]    Smoke    Regression
    # Given Logging out the user when user is already logged in
    # And A user login with new session
    Given User select Hosted Payment tab
    And User select Account Location
    When Checking all the checkbox options if its not selected
    And User enter data in the Receipt and Message Area and click save button    
    And Entering details in Tell Us About Yourself section in Hosted Payment Page
    And Entering details in Payment Information section in Hosted Payment Page with Credit Card Account
    And Entering details in Review and Submit section in Hosted Payment Page  
    Then Confirming the text entered in the Message Settings area  