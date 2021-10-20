*** Settings ***
Documentation     Variables defining user inputted information 


*** Keywords ***

Select Account Location Name
    ${account_location_name}=  Get Value From User    Input Account Location    ${processing_account_search_string}
    Set Suite Variable  \${account_location_name}  ${account_location_name}
    Log Variables

Select Customer iD
    ${customer_id}=                     Get Value From User         Input Customer ID           ${customer_id_default}
    Set Suite Variable  \${customer_id}  ${customer_id}
    Log Variables

#Select Payment Type
    ${payment_type}=                    Get Selection From User	    Select Test Pyment Type     ${one_time}  ${installment}  ${recurring}
    Run Keyword If  '${payment_type}'=='${one_time}'        Choose One Time Payment Tab
    Run Keyword If  '${payment_type}'=='${installment}'     Choose Installment Payment Tab
    Run Keyword If  '${payment_type}'=='${recurring}'       Choose Recurring Payment Tab
    Set Suite Variable  \${payment_type}  ${payment_type}
    Log Variables

Select Payment Account Name
    ${pament_account_name}=             Get Value From User	        Input Payment Account       ${pament_account_default}
    Set Suite Variable  \${pament_account_name}  ${pament_account_name}
    Log Variables

Select Installment Specialty FIeld
    ${specialty_amount_type}=    Get Selection From User	            Select Installment Payment Type     ${amount_string_text}  ${number_string_text} 
    Set Suite Variable  \${specialty_amount_type}  ${specialty_amount_type}
    Log Variables

Select Frequency        
    ${payment_frequency_type}=               Get Selection From User                Select Test Fee  ${freqency_id_weekly}  ${freqency_id_first_and_15th}  ${freqency_id_monthly}  ${freqency_id_quarterly}  ${freqency_id_semi_annually}  ${freqency_id_annually}
    Run Keyword If  '${payment_frequency_type}'=='${freqency_text_weekly}'          Set Variable    ${freqency_id_weekly}     
    Run Keyword If  '${payment_frequency_type}'=='${freqency_text_first_and_15th}'  Set Variable    ${freqency_id_first_and_15th}   
    Run Keyword If  '${payment_frequency_type}'=='${freqency_text_monthly}'         Set Variable    ${freqency_id_monthly}   
    Run Keyword If  '${payment_frequency_type}'=='${freqency_text_quarterly}'       Set Variable    ${freqency_id_quarterly}   
    Run Keyword If  '${payment_frequency_type}'=='${freqency_text_semi_annually}'   Set Variable    ${freqency_id_semi_annually}    
    Run Keyword If  '${payment_frequency_type}'=='${freqency_text_annually}'        Set Variable    ${freqency_id_annually}  
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables

Select CVV
    ${cvv}=                 Get Value From User	        Input CVV               ${cvv_default}

Select Expiration
    ${expiration_date}=     Get Value From User	        Input Expiration Date   ${expiration_date_default}


Select Payment Amount
    ${payment_amount_type}=          Get Selection From User	    Select Test Pyment Amount Type     ${test_valid_amount_text}  ${user_test_amount_text}  ${invalid_amount_text}
    Run Keyword If  '${payment_amount_type}'=='${user_test_amount_text}'          Test Invalid Card Pyment Amount
    Run Keyword If  '${payment_amount_type}'=='${test_valid_amount_text}'         Test Random Payment Amount
    Run Keyword If  '${payment_amount_type}'=='${invalid_amount_text}'            Test User Submitted Payment Amount
    Set Suite Variable  \${payment_amount_type}  ${payment_amount_type}
    Log Variables

Select Amount Per Payment Option
    Set Combobox By Found Value  \#specialtycomboboxfield   value _amount
Select Number of Payments Option
    Set Combobox By Found Value  \#specialtycomboboxfield   value _number


