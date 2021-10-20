
*** Settings ***
Documentation     Variables defining user inputted information 


*** Keywords ***


Read Account Location Name
    ${account_location_name}=           ${processing_account_search_string}
    Set Suite Variable  \${account_location_name}  ${account_location_name}
    Log Variables

Read Customer iD
    ${customer_id}=                     ${customer_id_default}
    Set Suite Variable  \${customer_id}  ${customer_id}
    Log Variables

Read Onetime Payment Type
    ${payment_type}=                ${one_time}
    Set Suite Variable  \${payment_type}  ${payment_type}
    Log Variables
Read Installment Payment Type
    ${payment_type}=                ${installment}
    Set Suite Variable  \${payment_type}  ${payment_type}
    Log Variables
Read Recurring Payment Type
    ${payment_type}=                ${recurring}
    Set Suite Variable  \${payment_type}  ${payment_type}
    Log Variables

Read Valid Payment Amount Type
    ${payment_amount_type}=         Test User Submitted Payment Amount
    Set Suite Variable  \${payment_amount_type}  ${payment_amount_type}
    Log Variables
Read Invalid Payment Amount Type
    ${payment_amount_type}=         Test Invalid Card Pyment Amount
    Set Suite Variable  \${payment_amount_type}  ${payment_amount_type}
    Log Variables
Read Random Payment Amount Type
    ${payment_amount_type}=         Test Random Payment Amount
    Set Suite Variable  \${payment_amount_type}  ${payment_amount_type}
    Log Variables

Read Payment Account Name
    ${pament_account_name}=             ${pament_account_default}
    Set Suite Variable  \${pament_account_name}  ${pament_account_name}
    Log Variables


Read Weekly Frequency        
    ${payment_frequency_type}=               ${freqency_id_weekly}     
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables

Read First and Fifteenth Frequency        
    ${payment_frequency_type}=               ${freqency_id_first_and_15th}
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables

Read Monthly Frequency        
    ${payment_frequency_type}=  ${freqency_id_monthly}
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables

Read Quartlery Frequency        
    ${payment_frequency_type}=  ${freqency_id_quarterly}
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables

Read Semi-Annual Frequency        
    ${payment_frequency_type}=  ${freqency_id_semi_annually}
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables

Read Annual Frequency        
    ${payment_frequency_type}=  ${freqency_id_annually}
    Set Suite Variable  \${payment_frequency_type}  ${payment_frequency_type}
    Log Variables


Read CVV
    ${cvv}=                             ${cvv_default}
    Set Suite Variable  \${cvv}  ${cvv}
    Log Variables

Read Expiration
    ${expiration_date}=                 ${expiration_date_default}
    Set Suite Variable  \${expiration_date}  ${expiration_date}
    Log Variables