*** Settings ***
Documentation    Variables defining targeted environment specific information 

*** Variables ***
${url}                               https://totalt-devint.netdeposit.com
${refportal_url}                     https://totalt-devint.netdeposit.com
${captcha_safe_url}                  totalt-devint.netdeposit.com
${browser}                           chrome
${admin_username}                    admin
${admin_password}                    pass1   
${admin_password_hash}               8FePHnF0saQcTqjG4X96ijuIySo=
${username}                          tsodamerchant
${password}                          pass1
${password_hash}                     8FePHnF0saQcTqjG4X96ijuIySo=
${dhl_username}                      dhluser
${dhl_password}                      Finastra1!
${dhl_password_hash}                 Drm9xDqrd2fCvfQmIGcYs4IP5Xg=
${merchant_search_string}            Topaz Soda
${processing_account_search_string}  Downtown
${user_search_string}                tsodamerchant
${admin_compName}                    Total Transact
${compName}                          Topaz Soda
${db_host}                           10.192.1.168
${db_port}                           1521
${db_service}                        TOTALT_DEV
${db_ls_schema_name}                 totalt_ls
${card_processor_search_string}      CYBERSOURCE
${db_base_schema_name}               totalt_sbps_base
${db_base_schema_password}           sbps

${latency_time_default}    15s
${wait_time_default}       15s



# ---- GENERAL DEFECT VARIABLES
${payment_account_ach_name_default}     Selenium ACH        
${payment_account_card_name_default}    Selenium Card       
${customer_id_default}                  IN6sp4M9EL0Ps7cK
${fullname_default}                     John Doe
${payment_date_default}                 02/13/2019
${payment_mount_default}                345.90              # > FAILS CC Address Check 500.00
${payment_specialty_mount_default}      69.00               # > FAILS CC Address Check 500.00


${payment_account_default}    Add New

# --- CUSTOMER VARIABLES
${first_name_default}         Kara
${last_name_default}          Jensen
${address_default}            345 One Street Lane
${city_default}               Salt Lake Ciy Utah
${state_default}              UT
${zip_code_default}           80493
${phone_default}              8018018001
${email_domain_default}       seleniumtest
${email_address_default}      ${first_name_default}.${last_name_default}@${email_domain_default}.com    #kara.jensen@finstra.com
${customer_search_default}    qBlIiQWIkZIfDyJVKpoC                                                      #Customer Id

# --- ACH RELATED VARIABLES
${written_authorization}=      True
${phone_authorization}=        False
${authorization_agreement}=    True     #Boolean    100

# --- CARD RELATED VARIABLES
${expiration_month}=             Date     %m
${expiration_year}=              Date     %y
${cvv_default}=                  999
${cvv_dhl_default}=              111
${expiration_date_default}=      12/23    
${disable_credit_card_tests}=    False    

${card_processor_default}                MONETRA-AZ
${card_institution_default}              Monetra Loopback Emulator    #CHASEPAYMENTTECH
${card_institution_alternate_default}    Monetra Loopback Emulator    #Chase Payment Tech


#${payment_date}=    Date    %m/%d/%y

# --- RESELLER RELATED VARIABLES (ADMIN PORTAL)
${reseller_default}                   Sapphire Reseller
${merchant_search_default}            Sapphire Auto
${account_location_search_default}    State Street Account

# --- TIME ZONE RELATED VARIABLES
${merchant_time_zone_default}            (-07:00) US Mountain Time
${account_location_time_zone_default}    (-07:00) US Mountain Time
${gateway_time_zone_default}             (-07:00) US Mountain Time