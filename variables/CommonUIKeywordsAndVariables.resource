*** Settings ***
Documentation    Variables defining user inputted information 
...
...        Contains variables used exclusively by the UI tests.
...        Contains keywords used by UI tests.
Library    SeleniumLibrary                                         timeout=10                                                implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library    String                                                  #In TotalTransact > Roboto Standard Libraries > String    
Library    FakerLibrary                                            locale=en_US
Library    TotaltUtilities

*** Variables ***

${manual}                Manual
${automted}              Automted
${valid}                 Valid
${invalid}               Invalid
${authorized}            Authorized
${environemnt}           Environment Default
${current}               Current
${future}                Future
${ach}                   ACH
${card}                  Card
${one_time}              One Time
${installment}           Installment
${recurring}             Recurring              
${amount_string}         _amount 
${number_string}         _number
${amount_string_text}    Amount Per Payment
${number_string_text}    Number of Payments


#${date_time_today_to_fugure}=    Date Time Between now 4y


${pament_account_default}    MASTERCARD xxxxx2226    #WELLS FARGO BANK NA CHECKING xxxxx5454

${add_new}           Add New
${account_number}    021000021           
${routing_number}    091000019
${card_number}       4111111111111111
${cvv}               999
${notes}=            Catch Phrase
${memo}=             Paragraph

${user_test_amount_text}=     User Submitted Payment Amount
${test_valid_amount_text}=    Valid Payment Amount
${invalid_amount_text}=       Declined Card Pyment Amount


${weekly}=            Weekly
${first_and_15th}=    1st and 15th
${monthly}=           Monthly
${quarterly}=         Quarterly
${semi_annually}=     Semi-Annually
${annually}=          Annually

#${research_transaction_sub_navigation}    text: "Transaction"

${hpp_customer_information_panel}    tellusaboutyourself
${hpp_payment_information_panel}     paymentinformation
${hpp_review_panel}                  reviewpanel


${payment_information_panel}       paymentinformationformpanel
${payment_sucess_response_text}    Transaction has been processed successfully!
${payment_denied_response_text}    Payment has been declined!

${customer_payment_accounts_panel}             customerpaymentaccountspanel
${customer_payment_accounts_ach_gridpanel}     achaccountsgridpanel
${customer_payment_accounts_card_gridpanel}    ccaccountsgridpanel

${account_text_checking}       CHECKING
${account_text_saving}         SAVINGS
${account_text_credit_card}    Credit Card


${admin_merchant_form_panel}    merchantform


#JSON PROPERTIES FOR PAYMENTS


*** Keywords ***
Open Browser With Proxy If Needed
    [Arguments]       ${urlToOpen} 
    Run Keyword If    '${browser}'=='Firefox' and '${enable_burp_proxy}'=='true'    Create Firefox Profile With Proxy    ${urlToOpen} 
    ...               ELSE                                                          Open Browser                         ${urlToOpen}     ${browser}

Create Firefox Profile With Proxy
    [Arguments]           ${urlToOpen} 
    ${profile_path}       Create Proxied Ff Profile 
    Log                   profile path is ${profile_path}
    Set Suite Variable    \${profile_path}                   ${profile_path}    
    Open Browser          ${urlToOpen}                       ${browser}                     ff_profile_dir=${profile_path}    

Open Developer Tools Network Tab
    Run Keyword if    '${browser}' == 'chrome'     Press Combination    KEY.CTRL    KEY.SHIFT    key.i
    Run Keyword if    '${browser}' == 'opera'      Press Combination    KEY.CTRL    KEY.SHIFT    key.i
    Run Keyword if    '${browser}' == 'firefox'    Press Combination    KEY.CTRL    KEY.SHIFT    key.e

Open Developer Tools Console Tab
    Run Keyword if    '${browser}' == 'chrome'     Press Combination    KEY.CTRL    KEY.SHIFT    key.j
    Run Keyword if    '${browser}' == 'opera'      Press Combination    KEY.CTRL    KEY.SHIFT    key.j
    Run Keyword if    '${browser}' == 'firefox'    Press Combination    KEY.CTRL    KEY.SHIFT    key.k
    #Ctrl+Shift+K
Open Developer Tools Console
    Run Keyword if    '${browser}' == 'chrome'     Press Combination    key.f12
    Run Keyword if    '${browser}' == 'firefox'    Press Combination    KEY.CTRL    KEY.SHIFT    key.i

Switch Developer Tools from Elements to Network Tab
    Run Keyword if    '${browser}' == 'chrome'    Press Combination    KEY.CTRL    key.]
    ...               AND                         Press Combination    KEY.CTRL    key.]
Switch Developer Tools from Elements to Console Tab
    Run Keyword if    '${browser}' == 'chrome'    Press Combination    KEY.CTRL    key.]

Switch Developer Tools from Network to Elements Tab
    Run Keyword if    '${browser}' == 'chrome'    Press Combination    KEY.CTRL    key.[
    ...               AND                         Press Combination    KEY.CTRL    key.[

Switch Developer Tools from Network to Console Tab
    Run Keyword if    '${browser}' == 'chrome'    Press Combination    KEY.CTRL    key.[

Switch Developer Tools from Console to Network Tab
    Run Keyword if    '${browser}' == 'chrome'    Press Combination    KEY.CTRL    key.]

Switch Developer Tools from Console to Elements Tab
    Run Keyword if    '${browser}' == 'chrome'    Press Combination    KEY.CTRL    key.[

Login to Payment Portal Through UI
    Open Browser With Proxy If Needed    ${url}/sbps/
    Input Text                           username        ${username}
    Input Text                           password        ${password}
    Click Button                         submit
    Open Developer Tools Console Tab
    Log Request Exception

Login to Payment Portal Using UI
    Configure Custom Selenium Locator
    Open Browser With Proxy If Needed    ${url}/sbps/
    Input Text                           username        ${username}
    Input Text                           password        ${password}
    Click Button                         submit

Login to Admin Portal Through UI
    Configure Custom Selenium Locator
    Open Browser With Proxy If Needed    ${url}/sbpsAdmin/
    Input Text                           username             ${admin_username}
    Input Text                           password             ${admin_password}
    Click Button                         submit

Login to Payment Portal Through UI as DHL User
    Open Browser With Proxy If Needed    ${url}/sbps/
    Input Text                           username        ${dhl_username}
    Input Text                           password        ${dhl_password}
    Click Button                         submit

Configure Custom Selenium Locator
    Add Location Strategy    extjs    Extjs Locator Strategy

Extjs Locator Strategy
    [Arguments]    ${browser}    ${locator}    ${tag}    ${constraints}

	${element}=    Execute Javascript    if (Ext.ComponentQuery.query('${locator}')[0]) {
                ...                   if (Ext.ComponentQuery.query('${locator}')[0].inputEl == undefined) {
                ...                   return Ext.ComponentQuery.query('${locator}')[0].getEl().id;             
                ...                   } else {
                ...                   return Ext.ComponentQuery.query('${locator}')[0].inputEl.id;             
                ...                   }
                ...                   } else {
                ...                   return undefined;
                ...                   }

    Log    element is ${element}

	[Return]    ${element}    

Go to RefPortal Through UI
    Open Browser With Proxy If Needed    ${refportal_url}/sbpsRefPortal/


Initiate WebShip Workflow
    Go to RefPortal Through UI
    Log to Console                Webpage Open
    Click Element                 xpath=//a[.//text()='com.fundtech.sbps.dhl.WebShipDataController']
    Log to Console                Webship Linked Clicked

Initiate EBilling Workflow
    Go to RefPortal Through UI
    Log to Console                Webpage Open
    Click Element                 xpath=//a[.//text()='com.fundtech.sbps.ebilling.EbillingController']
    Log to Console                EBilling Linked Clicked

Initiate AutoPay Workflow
    Go to RefPortal Through UI
    Log to Console                Webpage Open
    Click Element                 xpath=//a[.//text()='com.fundtech.sbps.ebilling.AutoPayController']
    Log to Console                AutoPay Linked Clicked

Initiate Print And Post Workflow
    Go to RefPortal Through UI
    Log to Console                Webpage Open
    Click Element                 xpath=//a[.//text()='com.fundtech.sbps.ebilling.PrintAndPostController']
    Log to Console                Print And Post Linked Clicked

Click RefPortal Preview Button Link
    Click Element    xpath=//fieldset[1]//input[1]

Click RefPortal Execute Button Link
    Click Element    xpath=//fieldset[1]//input[1]

Choose How to Payment Run Test
    ${test_mode_type_reqsuested}=    Get Selection From User
    ...                              Select the test mode you would like to use and press OK.
    ...                              ${manual}                                                                                            ${utomted}
    Set Suite Variable               \${test_mode_type}                                                                                   ${test_mode_type_requested}    
    Import Resource                  ${CURDIR}/TotalTransact/../../TestCases/UI/variables/Payment-${test_mode_type_requested}.resource
    Set Suite Variable               \${test_mode_type}                                                                                   ${test_mode_type}
    Log Variables


Populate Fullname
    ${first_name_text}    First Name
    ${last_name_text}     Last Name
    ${full_name_text}     Set Variable          ${first_name_text} ${last_name_text}
    Set Suite Variable    \${full_name_text}    ${full_name_text}

Populate Test Variables with Fake Customer Data
    ${customer_id_text}=     Numerify                  @@#############
    ${business_name_text}    Company
    ${first_name_text}       First Name
    ${last_name_text}        Last Name
    ${street_number}=        Random Int
    ${street_name}=          Street Name
    ${address_text}          Set Variable              ${street_number} ${street_name}
    ${city_text}             City
    ${state_text}            State Abbr
    ${zip_code_text}         Postcode
    ${phone_text}            Set Variable              8018018001
    ${email_address_text}    Email
    Set Suite Variable       \${customer_id_text}      ${customer_id_text}
    Set Suite Variable       \${business_name_text}    ${business_name_text}
    Set Suite Variable       \${first_name_text}       ${first_name_text}
    Set Suite Variable       \${last_name_text}        ${last_name_text}
    Set Suite Variable       \${address_text}          ${address_text}
    Set Suite Variable       \${city_text}             ${city_text}
    Set Suite Variable       \${state_text}            ${state_text}
    Set Suite Variable       \${zip_code_text}         ${zip_code_text}
    Set Suite Variable       \${phone_text}            ${phone_text}
    Set Suite Variable       \${email_address_text}    ${email_address_text}
    Log Variables

Populate Level Two Data
    ${invoice_number_text}=    Bothify                    text=## ??                #Random Int
    ${purchase_order_text}=    Bothify                    text=## ??                #Random Int
    ${tax_amount_text}=        Numerify                   @@!!.!!
    Set Suite Variable         \${invoice_number_text}    ${invoice_number_text}
    Set Suite Variable         \${purchase_order_text}    ${purchase_order_text}
    Set Suite Variable         \${tax_amount_text}        ${tax_amount_text}
    Log Variables


Test Invalid Card Pyment Amount
    ${payment_amount}=    Get Selection From User    Select Invalid Test Pyment Amount    ${deny_amounts_list_one}    ${deny_amounts_list_two}    ${deny_amounts_list_three}
    Set Suite Variable    \${payment_amount}         ${payment_amount}
    Log to Console        ${payment_amount}
Test Random Payment Amount
    ${payment_amount}=    Numerify              @@##.##              #@@!#.!!
    Set Suite Variable    \${payment_amount}    ${payment_amount}
    Log to Console        ${payment_amount}
Test User Submitted Payment Amount
    ${payment_amount}=    Run Keyword           Get Value From User    Input Test Pyment Amount
    Set Suite Variable    \${payment_amount}    ${payment_amount}
    Log to Console        ${payment_amount}


Select and Input Values for Payments Tab
    ${payment_type}=      Get Selection From User    Select Test Pyment Type    ${one_time}    ${installment}    ${recurring}
    Set Suite Variable    \${payment_type}           ${payment_type}
    Log to Console        ${payment_type}

Select and Input Values for Payment Form
    # Amounts
    ${deny_amounts_list_one}=      Create List    6.01    6.08    6.09    6.10    6.11    6.12    6.13    6.14    6.15    6.16    6.17    6.19
    ${deny_amounts_list_two}=      Create List    6.19    6.20    6.21    6.22    6.24    6.27    6.29    6.30    6.31    6.32    6.33    6.34
    ${deny_amounts_list_three}=    Create List    6.35    6.36    6.37    6.38    6.39    6.40    6.41    6.42    6.51    6.52    6.53
    ${deny_amounts_list_four}=     Create List    5.00    5.10    5.20    5.30    5.40

    # Days
    ${default_date}=    Date                       %m/%d/%Y
    #${set_date}=                       Get Value From User	       Choose Date                          ${default_date}
    ${current_date}=    Get Current Date           #%m\\%d\\%y
    ${future_date}=     Get Time                   result_format=MM\\DD\\YYYY    time_='NOW - 5 day'
    ${payment_date}=    Get Selection From User    Select Pyment DateOptions     ${payment_date_default}    ${current_date}    ${future_date}



# ADMIN PORTAL Keywords
Populate Merchant Variables
    ${business_name_text}     Company
    ${first_name_text}        First Name
    ${last_name_text}         Last Name
    ${street_number}=         Random Int
    ${street_name}=           Street Name
    ${address_text}=          Set Variable    ${street_number} ${street_name}
    ${city_text}=             City
    ${state_text}=            State Abbr
    ${zip_code_text}=         Postcode
    ${phone_text}=            Set Variable    8018018001
    ${fax_text}=              Set Variable    8018018001
    ${email_address_text}=    Email

    #${reseller_id_default}=                 Numerify
    ${merchant_name_text}=                Company
    ${time_zone_default}=                 Timezone    #ENVIRONMENTAL VARIABLES
    ${website_text}=                      Url         
    ${website_return_text}=               Uri Path
    ${merchant_reference_number_text}=    Numerify    @@!!!!                      #!!!!    #Need to Create
    ${external_id_text}=                  Numerify    @@!!!!!!!!                  

    Set Suite Variable    \${business_name_text}    ${business_name_text}
    Set Suite Variable    \${first_name_text}       ${first_name_text}
    Set Suite Variable    \${last_name_text}        ${last_name_text}
    Set Suite Variable    \${address_text}          ${address_text}
    Set Suite Variable    \${city_text}             ${city_text}
    Set Suite Variable    \${state_text}            ${state_text}
    Set Suite Variable    \${zip_code_text}         ${zip_code_text}
    Set Suite Variable    \${phone_text}            ${phone_text}
    Set Suite Variable    \${fax_text}              ${fax_text}
    Set Suite Variable    \${email_address_text}    ${email_address_text}

    Set Suite Variable    \${merchant_name_text}                ${merchant_name_text}
    Set Suite Variable    \${website_text}                      ${website_text}
    Set Suite Variable    \${website_return_text}               ${website_return_text}
    Set Suite Variable    \${merchant_reference_number_text}    ${merchant_reference_number_text}
    Set Suite Variable    \${external_id_text}                  ${external_id_text}
    Log Variables


Populate Acccount Location Variables
    ${company_id}               Numerify        ##########
    ${account_location_text}    Domain Word     
    ${first_name_text}          First Name
    ${last_name_text}           Last Name
    ${street_number}=           Random Int
    ${street_name}=             Street Name
    ${address_text}=            Set Variable    ${street_number} ${street_name}
    ${city_text}=               City
    ${state_text}=              State Abbr
    ${country_default}=         Country
    ${zip_code_text}=           Postcode
    ${phone_text}=              Set Variable    8018018001
    ${fax_text}=                Set Variable    8018018001
    ${email_address_text}=      Email

    #${reseller_id_default}=                 Numerify
    ${merchant_name_text}=               Company
    ${time_zone_default}=                Timezone    #ENVIRONMENTAL VARIABLES
    ${website_text}=                     Url
    ${website_return_text}=              Uri Path
    ${account_reference_number_text}=    Numerify    !@@!!
    ${external_id_text}=                 Numerify

    ${max_credit_per_day_text}      Numerify    @@!!#.## 
    ${max_credit_per_month_text}    Numerify    @@!!#.## 



    Set Suite Variable    \${company_id}               ${company_id}
    Set Suite Variable    \${account_location_text}    ${account_location_text}
    Set Suite Variable    \${business_name_text}       ${business_name_text}
    Set Suite Variable    \${first_name_text}          ${first_name_text}
    Set Suite Variable    \${last_name_text}           ${last_name_text}
    Set Suite Variable    \${address_text}             ${address_text}
    Set Suite Variable    \${city_text}                ${city_text}
    Set Suite Variable    \${state_text}               ${state_text}
    Set Suite Variable    \${country_default}          ${country_default}
    Set Suite Variable    \${zip_code_text}            ${zip_code_text}
    Set Suite Variable    \${phone_text}               ${phone_text}
    Set Suite Variable    \${fax_text}                 ${fax_text}
    Set Suite Variable    \${email_address_text}       ${email_address_text}

    Set Suite Variable    \${merchant_name_text}               ${merchant_name_text}
    Set Suite Variable    \${website_text}                     ${website_text}
    Set Suite Variable    \${website_return_text}              ${website_return_text}
    Set Suite Variable    \${account_reference_number_text}    ${account_reference_number_text}
    Set Suite Variable    \${external_id_text}                 ${external_id_text}

    Set Suite Variable    \${max_credit_per_day_text}      ${max_credit_per_day_text}
    Set Suite Variable    \${max_credit_per_month_text}    ${max_credit_per_month_text}

    Log Variables

Populate ACH Account Access Variables
    #${endpoint_text}
    ${company_id}=                          Numerify    \##########
    #${ach_disbursement_window_text}
    ${reserve_rate_percentage_text}=        Numerify    @!%
    ${reserve_rate_max_text}=               Numerify    @#
    ${max_transaction_limit_text}=          Numerify    @@!##.%%
    #${ach_duplicate_checking_window_text}
    ${max_daily_number_payments_text}=      Numerify    @!!!!!!!
    ${max_monthly_number_payments_text}=    Numerify    @!!!!!!!
    ${max_monthly_transactions_text}=       Numerify    @@!!!!.!!
    #${nsf_resubmit_text}
    ${max_daily_transactions_text}=         Numerify    @@!!!!.!!
    #${{ach_duplicate_checking_window_text}=
    #${bank_timezone_text}=
    #${odfi_cutoff_text}=

    Set Suite Variable    \${endpoint_text}                       Sapphire Reseller                      #BANK OF AMERICA
    Set Suite Variable    \${company_id}                          ${company_id}
    #Set Suite Variable  \${ach_disbursement_window_text}  ${ach_disbursement_window_text}
    Set Suite Variable    \${reserve_rate_percentage_text}        ${reserve_rate_percentage_text}
    Set Suite Variable    \${reserve_rate_max_text}               ${reserve_rate_max_text}
    Set Suite Variable    \${max_transaction_limit_text}          ${max_transaction_limit_text}
    #Set Suite Variable  \${ach_duplicate_checking_window_text}  ${ach_duplicate_checking_window_text}
    Set Suite Variable    \${max_daily_number_payments_text}      ${max_daily_number_payments_text}
    Set Suite Variable    \${max_monthly_number_payments_text}    ${max_monthly_number_payments_text}
    Set Suite Variable    \${max_monthly_transactions_text}       ${max_monthly_transactions_text}
    #Set Suite Variable  \${nsf_resubmit_text}  ${nsf_resubmit_text}
    Set Suite Variable    \${max_daily_transactions_text}         ${max_daily_transactions_text}
    #Set Suite Variable  \${ach_duplicate_checking_window_text}  ${ach_duplicate_checking_window_text}
    #Set Suite Variable  \${bank_timezone_text}  ${bank_timezone_text}
    #Set Suite Variable  \${odfi_cutoff_text}  ${odfi_cutoff_text}

Populate Card Account Access Variables
    ${card_present_profile_name_text}=    Word
    #${card_present_text}=                               True
    #${card_processor_text}=                             MONETRA
    #${ach_duplicate_checking_window_text}
    ${extra_settings_text}=               Numerify    @!!!!!!!
    #${card_batch_cutoff_time_text}=                     0
    #${card_batch_cutoff_minute_text}                    0
    ${accept_visa_text}=                  Boolean     100
    ${accept_mastercard_text}=            Boolean     90
    ${accept_amex_text}=                  Boolean     15
    ${accept_discover_text}=              Boolean     75
    #${nsf_resubmit_text}
    ${require_cvv}=                       Boolean     25
    ${avs_check}=                         Boolean     15

    Set Suite Variable    \${card_present_profile_name_text}     ${card_present_profile_name_text}
    Set Suite Variable    \${card_present_text}                  True
    Set Suite Variable    \${card_processor_text}                MONETRA
    Set Suite Variable    \${extra_settings_text}                ${extra_settings_text}
    Set Suite Variable    \${card_institution_text}              Monetra Loopback Emulator            #LOOPBACK
    Set Suite Variable    \${card_institution_alternate_text}    LOOPBACK                             #Monetra Loopback Emulator
    #Set Suite Variable  \${ach_duplicate_checking_window_text}  ${ach_duplicate_checking_window_text}
    #Set Suite Variable  \${extra_settings_text}  ${extra_settings_text}
    Set Suite Variable    \${card_batch_cutoff_time_text}        0
    Set Suite Variable    \${card_batch_cutoff_minute_text}      0
    Set Suite Variable    \${gateway_timezone_alternate_text}    (-08:00) Canada Pacific Time
    Set Suite Variable    \${accept_visa_text}                   ${accept_visa_text}
    Set Suite Variable    \${accept_mastercard_text}             ${accept_mastercard_text}
    Set Suite Variable    \${accept_amex_text}                   ${accept_amex_text}
    Set Suite Variable    \${accept_discover_text}               ${accept_discover_text}
    #Set Suite Variable  \${nsf_resubmit_text}  ${nsf_resubmit_text}
    Set Suite Variable    \${require_cvv}                        ${require_cvv}
    Set Suite Variable    \${avs_check}                          ${avs_check}

Select Navigation Tab
    [Arguments]           ${messageId} 
    Execute Javascript    var navigationTabPanel = Ext.ComponentQuery.query('tabpanel[cls=navigation]')[0],
    ...                   text = messages.${messageId}(),
    ...                   tabCard = Ext.ComponentQuery.query('tab[cls=navigation-tab][text=' + text + ']')[0].card;
    ...                   navigationTabPanel.setActiveTab(tabCard);

Expand Panel JS
    [Arguments]                    ${locator}
    Wait Until Keyword Succeeds    30s           5s    _Expand Panel    ${locator}

_Expand Panel
    [Arguments]           ${locator}
    Execute Javascript    Ext.ComponentQuery.query('${locator}')[0].expand();
    Sleep                 5s
    ${result} =           Execute Javascript                                     Ext.ComponentQuery.query('${locator}')[0].collapsed;
    Should Not Be True    ${result}

Select Combobox Value JS
    [Arguments]    ${locator}    ${displayValue}

    #set the endpoint combobox value to ${endpoint_text}
    Wait Until Keyword Succeeds    30s                                                                      200ms    Execute Javascript
    ...                            var endpointCombobox = Ext.ComponentQuery.query('${locator}')[0];
    ...                            if (endpointCombobox.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ...                            var record = endpointCombobox.findRecordByDisplay('${displayValue}');
    ...                            endpointCombobox.select(record);

Get Textfield Value JS
    [Arguments]    ${locator}
    ${value}=      Execute Javascript    return Ext.ComponentQuery.query('${locator}')[0].getValue();    
    [Return]       ${value}

Set Textfield Value JS
    [Arguments]           ${locator}                                                         ${value}
    Execute Javascript    Ext.ComponentQuery.query('${locator}')[0].setValue('${value}') 

Set Datefield Value JS
    [Arguments]           ${locator}                                                        ${value}
    Execute Javascript    Ext.ComponentQuery.query('${locator}')[0].setValue('${value}')    

Click Ext button JS
    [Arguments]           ${buttonLocatorQuery}
    ${isDisabled}=        Execute Javascript                                             return Ext.ComponentQuery.query('${buttonLocatorQuery}')[0].isDisabled();
    Log                   button ${buttonLocatorQuery}, isDisabled:${isDisabled}
    Should Not Be True    ${isDisabled}                                                  The button identified by ${buttonLocatorQuery} is disabled and cannot be clicked.
    ${buttonId}=          Execute Javascript                                             return Ext.ComponentQuery.query('${buttonLocatorQuery}')[0].getEl().id
    Log                   button id specified by ${buttonLocatorQuery} is ${buttonId}
    Click Element         ${buttonId}

Wait Until Ext Element Is Enabled
    [Arguments]                      ${buttonLocatorQuery}
    ${isDisabled}=                   Execute Javascript                                             return Ext.ComponentQuery.query('${buttonLocatorQuery}')[0].isDisabled();
    Log                              button ${buttonLocatorQuery}, isDisabled:${isDisabled}
    Should Not Be True               ${isDisabled}                                                  The button identified by ${buttonLocatorQuery} is disabled and cannot be clicked.
    ${buttonId}=                     Execute Javascript                                             return Ext.ComponentQuery.query('${buttonLocatorQuery}')[0].getEl().id
    Log                              button id specified by ${buttonLocatorQuery} is ${buttonId}
    Wait Until Element Is Enabled    ${buttonId}

Confirm Combobox Has Records JS
    [Arguments]        ${comboboxLocator}
    ${recordCount}=    Execute Javascript    return Ext.ComponentQuery.query('${comboboxLocator}')[0].getStore().count();
    Should Be True     ${recordCount} > 0    The combobox identified by ${comboboxLocator} store has no records.

Check Checkbox JS
    [Arguments]           ${locator}
    Execute Javascript    Ext.ComponentQuery.query('${locator}')[0].setValue(true)

Uncheck Checkbox JS
    [Arguments]           ${locator}
    Execute Javascript    Ext.ComponentQuery.query('${locator}')[0].setValue(false)

Click Grid Row
    [Arguments]                    ${gridLocator}                                                                    ${fieldName}    ${fieldValue}
    Wait Until Keyword Succeeds    30s                                                                               200ms           Execute Javascript
    ...                            var grid = Ext.ComponentQuery.query('${gridLocator}')[0];
    ...                            if (grid.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ...                            selectionModel = grid.getSelectionModel();
    ...                            var store = grid.getStore(),
    ...                            record = store.findRecord('${fieldName}', '${fieldValue}');
    ...                            if (record == undefined) {throw("The record was not found in the grid")};
    ...                            var recordIndex = store.indexOf(record);
    ...                            selectionModel.select(recordIndex);
    ...                            grid.fireEvent('itemclick', grid, grid.getSelectionModel().getLastSelected());

Click Grid Row First Element
    [Arguments]                    ${gridLocator}                                                                    
    Wait Until Keyword Succeeds    30s                                                                               200ms    Execute Javascript
    ...                            var grid = Ext.ComponentQuery.query('${gridLocator}')[0];
    ...                            if (grid.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ...                            selectionModel = grid.getSelectionModel();
    ...                            var store = grid.getStore();
    ...                            selectionModel.select(0);
    ...                            grid.fireEvent('itemclick', grid, grid.getSelectionModel().getLastSelected());

Click Grid Row Via CellClick
    [Arguments]                    ${gridLocator}                                                              ${fieldName}    ${fieldValue} 
    Wait Until Keyword Succeeds    30s                                                                         200ms           Execute Javascript
    ...                            var grid = Ext.ComponentQuery.query('${gridLocator}')[0];
    ...                            if (grid.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ...                            var store = grid.getStore(),
    ...                            record = store.findRecord('${fieldName}', '${fieldValue}');
    ...                            var model = grid.getSelectionModel(); model.select(record); 
    ...                            var cell = grid.getView().getCell(record, grid.columns[0]).dom,
    ...                            row = grid.getView().getCell(record, grid.columns[0]).dom.parentElement,
    ...                            index= store.find('${fieldName}', '${fieldValue}');
    ...                            grid.fireEvent('cellclick', grid, cell, 0 , record, row, index);

Click Grid Row Via Dom
    [Arguments]                    ${gridLocator}                                                           ${fieldName}    ${fieldValue} 
    Wait Until Keyword Succeeds    30s                                                                      200ms           Execute Javascript
    ...                            var grid = Ext.ComponentQuery.query('${gridLocator}')[0];
    ...                            if (grid.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ...                            var store = grid.getStore(),
    ...                            record = store.findRecord('${fieldName}', '${fieldValue}');
    ...                            var model = grid.getSelectionModel(); model.select(record); 
    ...                            var domElement = grid.getView().getCell(record, grid.columns[0]).dom;
    ...                            domElement.click();

Verify Checkbox Value
    [Arguments]       ${checkboxLocator}    ${expectedValue}
    ${checked}=       Execute Javascript    return Ext.ComponentQuery.query('${checkboxLocator}')[0].getValue() == ${expectedValue}
    Should Be True    ${checked}

Verify Grid Is Empty
    [Arguments]                    ${gridLocator}
    Wait Until Keyword Succeeds    30s                                                          200ms                                                                          Execute Javascript
    ...                            var grid = Ext.ComponentQuery.query('${gridLocator}')[0];
    ...                            if (grid.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ${recordCount}=                Execute Javascript                                           return Ext.ComponentQuery.query('${gridLocator}')[0].getStore().getCount();
    Should Be True                 ${recordCount} == 0

Verify Grid Is Not Empty
    [Arguments]                    ${gridLocator}
    Wait Until Keyword Succeeds    30s                                                          200ms                                                                          Execute Javascript
    ...                            var grid = Ext.ComponentQuery.query('${gridLocator}')[0];
    ...                            if (grid.getStore().isLoading()) {
    ...                            throw("Combobox is loading");
    ...                            }
    ${recordCount}=                Execute Javascript                                           return Ext.ComponentQuery.query('${gridLocator}')[0].getStore().getCount();
    Should Be True                 ${recordCount} > 0

User Create Custom fields in payment Settings page

    ${Customfieldname}=            Generate Random String                         length=5              chars=[LETTERS]
    # ${Customfieldname} =    Catenate    ${Customfieldname}    Auto
    Set Textfield Value JS         \#additemcontainer > [name=customFieldName]    ${Customfieldname}
    Select Combobox Value JS       \#additemcontainer > #fieldtype                Text
    Select Combobox Value JS       \#additemcontainer > #ruletype                 InvoiceNumber         
    Sleep                          2s                                             
    Click Ext Button JS            button#addbutton{isVisible(true)}
    Wait Until Keyword Succeeds    15s                                            15s                   Wait Until Page Contains    ${Customfieldname}    timeout=15s
     # ${Customfieldname}=    Convert To Lowercase    ${Customfieldname}
    # Log    ${Customfieldname}
    # ${Customfieldname}=    Convert To Title Case    ${Customfieldname}
    # Log    ${Customfieldname}
    Set Suite Variable             \${Customfieldname}                            ${Customfieldname}


User Delete Custom field in Payment Settings Page
    Sleep                          5s
    Click Grid Row                 \#savedcustomdatagridpanel                             customFieldName                                                                                       ${Customfieldname}
    ${removebutton}                Set Variable                                           Ext.getCmp(Ext.ComponentQuery.query("#paymentsettingscustomdata")[0].getEl().down('.adjusted').id)    #Ext.ComponentQuery.query('#savedcustomdatagridpanel #removebutton')[2]
    Execute Javascript             ${removebutton}.fireEvent('click',${removebutton});
    Wait Until Page Contains       Are you sure                                           timeout=30 seconds                                                                                    error=None
    Click Ext Button JS            button#ok{isVisible(true)}
    Wait Until Keyword Succeeds    15s                                                    15s                                                                                                   Wait Until Page Does Not Contain                                           ${Customfieldname}    timeout=15s    

Create fees in the Payment Settings
    ${feename}=               Generate Random String                           length=5                                     chars=[LETTERS]
    Set Textfield Value JS    \#feename                                        ${feename}
    Set Textfield Value JS    \#achfees > #amount                              10.00
    Set Textfield Value JS    \#achfees > #percentage                          2
    Set Textfield Value JS    \#cardfees > #amount                             10.00
    Set Textfield Value JS    \#cardfees > #percentage                         2
    ${addbutton}              Set Variable                                     Ext.ComponentQuery.query('#addbutton')[1]
    Execute Javascript        ${addbutton}.fireEvent('click',${addbutton});
    Set Suite Variable        \${feename}                                      ${feename}

Delete fees from Payment Settings 
    Click Grid Row              \#savedfeesgridpanel                                          name                                                                                            ${feename}
    ${feeremovebutton}          Set Variable                                                  Ext.getCmp(Ext.ComponentQuery.query("#paymentsettingsfees")[0].getEl().down('.adjusted').id)    #Ext.ComponentQuery.query('#savedfeesgridpanel #removebutton')[1]
    Execute Javascript          ${feeremovebutton}.fireEvent('click',${feeremovebutton}); 
    Wait Until Page Contains    Are you sure                                                  timeout=30 seconds                                                                              error=None
    Click Ext Button JS         button#ok{isVisible(true)}