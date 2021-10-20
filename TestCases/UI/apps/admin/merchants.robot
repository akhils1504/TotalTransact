*** Settings ***
Documentation    Verify merchant creation and edit
Library    SeleniumLibrary    timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library    String             #In TotalTransact > Roboto Standard Libraries > String    
Library    FakerLibrary       locale=en_US
Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource
Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Test UI Setup
Suite Teardown    Teardown Test Suite
*** Variables ***
#${disable_credit_card_tests}=        True
*** Keywords ***
Test UI Setup
    Login to Admin Portal Through UI
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Merchants')]    
    #populate variables for use by the following tests
    Populate Merchant Variables
    Populate Acccount Location Variables
    Populate ACH Account Access Variables
    Populate Card Account Access Variables
Enter Merchant Data
    ${logout_path}=             Set Variable                                  ${website_text}${website_return_text}
    ${random_word}=             Word
    ${co_suffix}=               Company Suffix
    ${merchant_name}=           Set Variable                                  ${random_word} Selenium ${co_suffix}
    Set Suite Variable          \${merchant_name}                             ${merchant_name}
    Select Combobox Value JS    \#resellerid{isVisible(true)}                 Sapphire Reseller                        #${user_picked_reseller}    #Need to Create
    Set Textfield Value JS      \#merchantname{isVisible(true)}               ${merchant_name}                         #${merchant_name_text}      #Need to Create
    Set Textfield Value JS      \#address{isVisible(true)}                    479 Mckinley Junction                    #${address_text}
    Set Textfield Value JS      \#city{isVisible(true)}                       ${city_text}
    Set Textfield Value JS      \#state{isVisible(true)}                      ${state_text}
    Set Textfield Value JS      \#zipcode{isVisible(true)}                    53889-3506                               #${zip_code_text}
    Set Textfield Value JS      \#phone{isVisible(true)}                      555-517-8019                             #${phone_text}
    Set Textfield Value JS      \#fax{isVisible(true)}                        555-517-8019                             #${fax_text}                #Need to Create
    Select Combobox Value JS    \#merchantTimeZone{isVisible(true)}           ${merchant_time_zone_default}            #Need to Create
    Set Textfield Value JS      \#contactfirstname{isVisible(true)}           ${first_name_text}
    Set Textfield Value JS      \#contactlastname{isVisible(true)}            Edwards                                  #${last_name_text}
    Set Textfield Value JS      \#contactphone{isVisible(true)}               555-517-8019                             #${phone_text}
    Set Textfield Value JS      \#contactemail{isVisible(true)}               ethan@example.com                        #${email_address_text}
    Set Textfield Value JS      \#merchantwebsite{isVisible(true)}            http://merchantwebsite.com               #${website_text}
    Set Textfield Value JS      \#billingroutingnumber{isVisible(true)}       ${routing_number}                        
    Set Textfield Value JS      \#billingaccountnumber{isVisible(true)}       ${account_number}                        
    Set Textfield Value JS      \#logoutreturnpath{isVisible(true)}           burnettairline.org                       #${logout_path}
    Set Textfield Value JS      \#merchantreferencenumber{isVisible(true)}    ${merchant_reference_number_text}        #Need to Create
    Set Textfield Value JS      \#externalid{isVisible(true)}                 ${external_id_text}                      #Need to Create
Enter Account Location Data
    ${random_word}=         Word
    ${city_suffix}=         City Suffix
    #${random_name}=     Set Variable        ${random} Selenium
    ${account_location}=    Set Variable            Selenium${random_word}${city_suffix}
    Set Suite Variable      \${account_location}    ${account_location}
    Set Textfield Value JS      \#accountlocationname{isVisible(true)}        ${account_location}                     #${account_location_text}        #Need to Create
    Set Textfield Value JS      \#address{isVisible(true)}                    319 W Hoover Plz                        #${address_text}
    Set Textfield Value JS      \#city{isVisible(true)}                       ${city_text}
    Select Combobox Value JS    \#state                                       Montana                                 #${state_text}
    Set Textfield Value JS      \#zipcode{isVisible(true)}                    ${zip_code_text}
    Set Textfield Value JS      \#phone{isVisible(true)}                      555-753-7016                            #${phone_text}
    Set Textfield Value JS      \#fax{isVisible(true)}                        555-753-7016                            #${fax_text}                     #Need to Create    
    Select Combobox Value JS    \#country{isVisible(true)}                    United States                           #${country_default}              #Need to Create
    Set Textfield Value JS      \#contactfirstname{isVisible(true)}           ${first_name_text}
    Set Textfield Value JS      \#contactlastname{isVisible(true)}            Cummings                                #${last_name_text}
    Set Textfield Value JS      \#contactphone{isVisible(true)}               555-753-7016                            #${phone_text}
    Set Textfield Value JS      \#contactemail{isVisible(true)}               madison@example.com                     #${email_address_text}
    Set Textfield Value JS      \#accountreferencenumber{isVisible(true)}     ${account_reference_number_text}        
    Set Textfield Value JS      \#merchantwebsite{isVisible(true)}            http://merchantwebsite.com              #${website_text}
    Set Textfield Value JS      \#maxcreditperday{isVisible(true)}            999999.99                               #${max_credit_per_day_text}
    Set Textfield Value JS      \#maxcreditpermonth{isVisible(true)}          999999.99                               #${max_credit_per_month_text}
    Select Combobox Value JS    \#accountLocationTimeZone{isVisible(true)}    ${account_location_timezone_default}
Enter ACH Access Data
    Check Checkbox JS           \#acceptAch{isVisible(true)}                     
    Expand Panel JS             \#addmerchant \#achdepositaccountform 
    Select Combobox Value JS    \#endpoint                                       ${endpoint_text}
    Set Textfield Value JS      \#achdepositrouting{isVisible(true)}             091000019           #${routing_number}
    Set Textfield Value JS      \#achdepositaccountnumber{isVisible(true)}       5405222222222226    #${account_number}
    ${random_word}=             Word
    Set Textfield Value JS      \#nameonachdeposit{isVisible(true)}              BarbDoe             #${random_word}                         #${fullname_default}
    Set Textfield Value JS      \#nametoapperincustomer{isVisible(true)}         watch               #${random_word}                         #${fullname_default}
    Set Textfield Value JS      \#companyid{isVisible(true)}                     1234678903          #${company_id}
    Set Textfield Value JS      \#reserverate{isVisible(true)}                   25                  #${reserve_rate_percentage_text}
    Set Textfield Value JS      \#reservemax{isVisible(true)}                    88043               #${reserve_rate_max_text}
    Set Textfield Value JS      \#maxtransactionlimit{isVisible(true)}           75.20               #${max_transaction_limit_text}
    Set Textfield Value JS      \#maxdailynumberofpayments{isVisible(true)}      99999999            #${max_daily_number_payments_text}
    Set Textfield Value JS      \#maxmonthlynumberofpayments{isVisible(true)}    99999999            #${max_monthly_number_payments_text}
    Set Textfield Value JS      \#maxmonthlytransactionlimit{isVisible(true)}    999999.99           #${max_monthly_transactions_text}
    Set Textfield Value JS      \#maxdailytransactionlimit{isVisible(true)}      999999.99           #${max_daily_transactions_text}
Enter Card Access Data
    Expand Panel JS      \#accountlocationform{isVisible(true)}
    Check Checkbox JS    \#acceptCreditcard{isVisible(true)}                       
    Expand Panel JS      \#addmerchant #carddepositaccountform{isVisible(true)}
    Sleep                10s                                                       #this needs to be fixed in the UI code
    Set Textfield Value JS      \#cardpresentprofilename{isVisible(true)}        ${card_present_profile_name_text}
    Check Checkbox JS           \#cardnotpresent{isVisible(true)}                
    Select Combobox Value JS    \#cardprocessor{isVisible(true)}                 ${card_processor_default}
    Wait Until Keyword Succeeds    10x    1s    Execute Javascript    var endpointCombobox = Ext.ComponentQuery.query('#cardprocessor{isVisible(true)}')[0];
    ...    if (endpointCombobox.getStore().isLoading()) {
    ...    throw("Combobox is loading");
    ...    }
    ...    var record = endpointCombobox.findRecordByDisplay('${card_processor_default}');
    ...    endpointCombobox.select(record);
    ...    endpointCombobox.fireEvent('select', endpointCombobox, '${card_processor_default}');
    Select Combobox Value JS    \#cardinstitution{isVisible(true)}    ${card_institution_default}
    Select Combobox Value JS    \#gatewayTimeZone{isVisible(true)}          ${gateway_timezone_default}
    Select Combobox Value JS    \#cardinstitution{isVisible(true)}          ${card_institution_default}
    Set Textfield Value JS      \#cardbatchcutofftime{isVisible(true)}      ${card_batch_cutoff_time_text}
    Set Textfield Value JS      \#cardbatchcutoffminute{isVisible(true)}    ${card_batch_cutoff_minute_text}
    Check Checkbox JS    \#acceptvisa          
    Check Checkbox JS    \#acceptmastercard    
    Check Checkbox JS    \#acceptamex          
    Check Checkbox JS    \#acceptdiscover      
    Check Checkbox JS    \#requirecvv{isVisible(true)}
    Check Checkbox JS    \#avscheck{isVisible(true)}
*** Test Cases ***
Create Merchant and Account Location with ACH and Card Access
    [Documentation]                    Creates a new merchant and account location. 
    ...
    ...                                Credit card parameters may be prevented from being used by setting the variable disable_credit_card_tests to True.
    [Tags]                             Regression
    Select Navigation Tab              NV091                                                                                                                 #Merchants
    Confirm Combobox Has Records JS    \#reseller
    Select Combobox Value JS           \#reseller                                                                                                            ${reseller_default}    #Sapphire Reseller
    Click Ext Button JS            \#addnewmerchant
    Wait Until Page Contains       Add New Merchant                                             30 seconds
    Enter Merchant Data
    Expand Panel JS                \#addmerchant accountlocationdetailform
    Enter Account Location Data
    Enter ACH Access Data
    ${card_access_execute}=    Get Variable Value    ${disable_credit_card_tests}
    ${is set}=      Set Variable If    """${card_access_execute}""" != 'None'        ${False}   ${True}
    #Log                            disable_credit_card_tests is ${disable_credit_card_tests}
    Run Keyword If   ${card_access_execute} != True    Enter Card Access Data
    Click Ext Button JS    \#savebutton{isVisible(true)}
    Wait Until Page Contains    Added successfully    ${wait_time_default}
    Confirm Combobox Has Records JS    \#reseller
    Select Combobox Value JS           \#reseller          ${reseller_default}
    Set Textfield Value JS             \#search            ${merchant_name}
    Wait Until Page Contains           ${merchant_name}    ${wait_time_default}
Edit Merchant and Account Location with ACH and Card Access
    [Documentation]    Opens the merchant from the previous test for editing. Changes the name by adding ten random numbers.
    ...                Saves the merchant with the changed name and verifies 
    ...                upon searching for the original name that the new one is shown on the page (in the grid).
    [Tags]             Regression
    ${randomMerchantNameNumbers}=    Generate Random String                                  length=10                                       chars=[NUMBERS]
    Click Grid Row                   \#viewallmerchantgrid                                   merchantname                                    ${merchant_name}
    Wait Until Page Contains         Billing Account Number
    #change the merchant name
    Sleep                            2
    Set Textfield Value JS           \#merchantdetailpanel #merchantname{isVisible(true)}    ${merchant_name}${randomMerchantNameNumbers}
    Click Ext button JS              \#merchantdetailpanel #savebutton 
    Sleep                            2                                                       
    Expand Panel JS                  \#merchantpanel
    #search for the original merchant name as a partial search
    Set Textfield Value JS           \#search                                                ${merchant_name}
    #to verify, make sure the updated merchant name is displayed
    Wait Until Page Contains         ${merchant_name}${randomMerchantNameNumbers}
