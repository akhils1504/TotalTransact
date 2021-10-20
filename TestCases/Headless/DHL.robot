# coding: utf-8
*** Settings ***
Documentation     Exercises the system as much as possible to give clues to Burp Suite for testing.  BURP MUST BE SET TO LISTEN ON LOCALHOST:8080
Library           Collections
Library           Dialogs
Library           robot.libraries.DateTime
Library           RequestsLibrary
Library           JsonpathLibrary
Library           OperatingSystem
Library           String
Library           XML
Resource          ../../variables/CommonKeywordsAndVariables.resource
Suite Setup       Setup Test Suite

*** Keywords ***
Find And Force Webship Payment
    [Arguments]  ${airwayBillNumber}
    &{headers}=  Create Dictionary  Content-Type=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary   ${headers}  Accept=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary  ${headers}  X-TT-APIKEY  ${api_key}
    ${queryStringParams}=  Set Variable  ?filter=airwaybillnumbers:${airwayBillNumber},creditCardPaymentStatus:P2EqpaxBJf3aIKcOBazAh!!!XTSthTC0YsH90MJdXBftpkOZrl@@@iDqCVrIPI6C2llT
    Log To Console  Attempting to find webship payment with params ${queryStringParams}
    ${resp}=  Get Request  dhlSession  /sbps/api/creditcardpayments${queryStringParams}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  CustomDataFields
    ${credit_card_payment_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  CreditCardPayment.*id="(.*)"  1
    ${data}=  Set Variable  <CreditCardPayment xmlns="http://www.fundtech.com/t3applicationmedia-v1"><Amount>101.01</Amount><CreditCardPaymentStatus id="YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ"/></CreditCardPayment>
    ${resp}=  Put Request  dhlSession  /sbps/api/creditcardpayment/${credit_card_payment_id[0]}  data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Be Equal As Strings  ${resp.status_code}  200
    #authorized status is YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ
    Should Contain  ${resp.content.decode('utf-8')}  YH@@@C1gCA5Lc34Nap2C@@@jUYqHr!!!uXmWnfk9IGcmDcZjgdN81fRo@@@5BDHTBT6jrYon  #Grails 2.2.5 was YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ

Find And Force Webship Payment CI environment
    [Arguments]  ${airwayBillNumber}
    &{headers}=  Create Dictionary  Content-Type=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary   ${headers}  Accept=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary  ${headers}  X-TT-APIKEY  ${api_key}
    ${queryStringParams}=  Set Variable  ?filter=airwaybillnumbers:${airwayBillNumber},creditCardPaymentStatus:P2EqpaxBJf3aIKcOBazAh!!!XTSthTC0YsH90MJdXBftpkOZrl@@@iDqCVrIPI6C2llT
    Log To Console  Attempting to find webship payment with params ${queryStringParams}
    ${resp}=  Get Request  dhlSession  /sbps/api/creditcardpayments${queryStringParams}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  CustomDataFields
    ${credit_card_payment_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}   CreditCardPayment id="(.*)" href  1
    ${data}=  Set Variable  <CreditCardPayment xmlns="http://www.fundtech.com/t3applicationmedia-v1"><Amount>101.01</Amount><CreditCardPaymentStatus id="YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ"/></CreditCardPayment>
    ${resp}=  Put Request  dhlSession  /sbps/api/creditcardpayment/${credit_card_payment_id[0]}  data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Be Equal As Strings  ${resp.status_code}  200
    #authorized status is YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ
    Should Contain  ${resp.content.decode('utf-8')}  YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ  #Grails 2.2.5 was YH@@@C1gCA5LeFQ52IDytTyubBdYVgqGeEugJwVrP1ubunSzjnNLUxABy4tlzS5ZRQ
	
Find Autopay Payment
    [Arguments]   ${externalId}   ${EBPPUserName}
    &{headers}=  Create Dictionary  properties  
	Set To Dictionary   ${headers}	UserName						${dhl_username}
    Set To Dictionary   ${headers}  SESSION_TOKEN					${session_id}
	Set To Dictionary   ${headers}	ProcessingAccount				QDGfoL8MVLK8A49qup7O2vW1kILuFE2EJMEzbLnq0lPPpviBGUg8!!!jVoNEtcPPe@@@
	Set To Dictionary   ${headers}	Password 					    ${dhl_password}
	Set To Dictionary   ${headers}	Customerid						${customerid}
	Set To Dictionary   ${headers}	CreditCardPaymentStatus			P2EqpaxBJf3aIKcOBazAh!!!XTSthTC0YsH90MJdXBftpkOZrl@@@iDqCVrIPI6C2llT
	Set To Dictionary   ${headers}	CreditCardPaymentAccount		${cc_pmt_acct_id}
	Set To Dictionary   ${headers}	Cookie							null
	Set To Dictionary   ${headers}	BankAccountType					${BankAccountType}
	Set To Dictionary   ${headers}	API_KEY							${api_key}
	Set To Dictionary   ${headers}	ApiKeyName						${ApiKeyName}
	Set To Dictionary   ${headers}	Amount							${Amount}
	Set To Dictionary   ${headers}	AchPaymentAccount		        ${ach_pmt_acct_id}		
	Set To Dictionary   ${headers}	CreditCardPaymentid				${cc_pmt_acct_id}
	Set To Dictionary   ${headers}	AuditUserId						763
	Set To Dictionary   ${headers}	Userid						    ${Userid}

*** Test Cases ***
Login as dhluser and retrieve the apikey
    [Tags]  Smoke   DHL  
    Set Suite Variable  ${merchant_search_string}  DHL Express
    Set Suite Variable  ${processing_account_search_string}  DHL
    Run Keyword If  '${testServer}'=='AzureCustint'  Login To Payment Portal CI Environment  ${dhl_username}  ${dhl_password}
         ...                ELSE  Login To Payment Portal  ${dhl_username}  ${dhl_password}
    Read Account Location
    Create API Key
    Set Suite Variable  ${processing_account_id}  1
    Run Keyword If  '${testServer}'=='AzureCustint'  Logout CI Environment
             ...                ELSE  Logout


List Processing Accounts using /sbps/api/processingaccounts
    [Tags]  Smoke   DHL 
    #Set Suite Variable  \${api_key}  25lsedk2fnnoikn5tgdnh394bpt0kpm49fmf98brpbjsik3hl3
    Log  'api key is ${api_key}'
    Create Sessions
    &{headers}=  Create Dictionary  Content-Type=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary   ${headers}  Accept=application/vnd.fundtech.t3-v1+xml
    Set To Dictionary  ${headers}  X-TT-APIKEY  ${api_key}
    ${resp}=  Get Request  dhlSession  /sbps/api/processingaccounts  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    ${root}=  Parse XML  ${resp.content.decode('utf-8')}
    ${api_processing_account_id}=  Get Element Attribute  ${root}  id  xpath=ProcessingAccount[Name='DHL'][last()] 		
    Log  ${api_processing_account_id}
    Set Suite Variable  \${api_processing_account_id}  ${api_processing_account_id}

# The failure of this test case is usually caused by the payment not being found in DW,Webship force check for CustomDataFields will succeed once the payment has reached the DW schema and has a custom field for the AirwayBillNumber. 05/21/2019 by Dayanand  
Call Webship - Simulates a user selecting 'Pay Now' on the DHL
    [Tags]  Smoke   DHL 
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=123456789 
    ${shipperid}=  Generate Random String  length=7  chars=[NUMBERS]
    ${customer_number}=  Generate Random String  length=9  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=http://robotframeworkautomatedtest.junk 
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  hdnBFCCache  <?xml version\="1.0" encoding\="UTF-8"?><creditcard action\="cc_request"><shipper><shipperid>${shipperid}</shipperid><companyname>Fundtech</companyname><addressline1>34 Fisher Street</addressline1><addressline2>null</addressline2><city>Mountain View</city><state>CA</state><postalcode>94043</postalcode><countrycode>100</countrycode></shipper><shipment><currentawb>${airwayBillNumber}</currentawb><hasci>1</hasci><ssouserid>${shipperid}</ssouserid><estimatedcharge>18.83</estimatedcharge><userapp>webship</userapp><userappurl>https://webship.dhl-usa.com/</userappurl></shipment></creditcard>
    Set To Dictionary  ${data}  hdnCache  <?xml version\="1.0" encoding\="UTF-8"?><exchange vsn\="1" action\="Response"><fault>null</fault><shpt action\=""><inv_typ>com</inv_typ><paperless>null</paperless><fault>null</fault><shpt_id>0</shpt_id><arbl_nbr>${airwayBillNumber}</arbl_nbr><arbl_nbr_edited>null</arbl_nbr_edited><prnt_alt_for_edited>YES</prnt_alt_for_edited><lbl_prnt_flg>NO</lbl_prnt_flg><totl_chrg>null</totl_chrg><sndr><fault>null</fault><user_id>${shipperid}</user_id><cust_nbr>${customer_number}</cust_nbr><third_pty_cust_nbr>null</third_pty_cust_nbr><sent_nam>FirstoD LastoD</sent_nam><phon_nbr>801-716-4720</phon_nbr><ca_nam>null</ca_nam><ca_phon_nbr>null</ca_phon_nbr><ca_email_addr>null</ca_email_addr><notify_default_user_flg>NO</notify_default_user_flg><emplr_id_typ_cd descr\="null">0</emplr_id_typ_cd><emplr_id_nbr>null</emplr_id_nbr><co_nam>Fundtech</co_nam><str_addr_1>34 Fisher Street</str_addr_1><str_addr_2>null</str_addr_2><city_nam>Mountain View</city_nam><st_prvnc_cd>CA</st_prvnc_cd><postl_cd>94043</postl_cd><email_addr>firstoD.lastoD@fundtech.com</email_addr><reset_addr_flg>YES</reset_addr_flg><CanShipToOfacCountries><![CDATA[NO]]></CanShipToOfacCountries><RegisteredForPaperless><![CDATA[NO]]></RegisteredForPaperless><PaperlessDefInvTyp>null</PaperlessDefInvTyp><PaperlessDefInvMethod>0</PaperlessDefInvMethod><PaperlessDefCertOrgnMethod>0</PaperlessDefCertOrgnMethod><PaperlessGeneratedInvFlg><![CDATA[NO]]></PaperlessGeneratedInvFlg><PaperlessTermsConditionsFlg><![CDATA[NO]]></PaperlessTermsConditionsFlg><org_id>3</org_id><CanRegisterForPaperless><![CDATA[YES]]></CanRegisterForPaperless><CanPrepareITNRequestShpt><![CDATA[YES]]></CanPrepareITNRequestShpt><CanPrepareDeptStateShpt><![CDATA[NO]]></CanPrepareDeptStateShpt><show_mgn_box_flg>YES</show_mgn_box_flg><shpt_val_prtct_flg>YES</shpt_val_prtct_flg></sndr><save_sndr_addr>NO</save_sndr_addr><display_edit_addr>null</display_edit_addr><addr_chng_alowd>YES</addr_chng_alowd><shpt_dt>10/29/2014</shpt_dt><svc_typ_cd>1</svc_typ_cd><shpt_typ>5</shpt_typ><wt_cd>2</wt_cd><dims_len>10.1</dims_len><dims_wdth>5.8</dims_wdth><dims_hgt>5.9</dims_hgt><cstms_valu_amt>100</cstms_valu_amt><dutiable_flg><![CDATA[N]]></dutiable_flg><valu_amt>0</valu_amt><shpt_pkg_descr>Book</shpt_pkg_descr><shpt_ref_cd>null</shpt_ref_cd><show_ref_flg>NO</show_ref_flg><bill_to_typ_cd>4</bill_to_typ_cd><bill_to_cust_nbr>null</bill_to_cust_nbr><bill_duty_to_typ_cd>2</bill_duty_to_typ_cd><bill_duty_to_cust_nbr>null</bill_duty_to_cust_nbr><free_domcl_flg>YES</free_domcl_flg><ntfy_rcv_flg>NO</ntfy_rcv_flg><ntfy_othr_flg>NO</ntfy_othr_flg><othr_email_addr>null</othr_email_addr><ntfy_msg_txt>null</ntfy_msg_txt><cod_amt>null</cod_amt><cod_pmt_term_cd>null</cod_pmt_term_cd><hazmat_flg>NO</hazmat_flg><haa_flg>NO</haa_flg><creat_rcpt_flg>NO</creat_rcpt_flg><creat_ci_flg>NO</creat_ci_flg><creat_sed_flg>0</creat_sed_flg><ignored_err_list>null</ignored_err_list><is_ci_reqd>NO</is_ci_reqd><is_sed_reqd>NO</is_sed_reqd><is_ci_suprs>NO</is_ci_suprs><is_self_filing>NO</is_self_filing><void_flg>NO</void_flg><sav_to_prsnl_addr_flg>NO</sav_to_prsnl_addr_flg><ask_user_sed_quest>NO</ask_user_sed_quest><user_sed_choice>null</user_sed_choice><total_pieces>null</total_pieces><xtn>null</xtn><res_del_flg>YES</res_del_flg><type_pickup>0</type_pickup><pick_up_option>null</pick_up_option><pick_up_date>null</pick_up_date><pick_up_closetime>null</pick_up_closetime><pick_up_readytime>null</pick_up_readytime><pick_up_specilainstruction>null</pick_up_specilainstruction><nbr_of_pkp_pkgs>null</nbr_of_pkp_pkgs><est_pkp_wt>null</est_pkp_wt><pick_up_current_time>1109</pick_up_current_time><ca_creditcard_opt>0</ca_creditcard_opt><user_pickup_opt>4</user_pickup_opt><crdt_card_details><crdt_Card_nbr>null</crdt_Card_nbr><crdt_card_typ>null</crdt_card_typ><unique_id>null</unique_id><crdt_exp_dt>null</crdt_exp_dt></crdt_card_details><getfocus>null</getfocus><is_sed_frm_eef>NO</is_sed_frm_eef><cstms_valu_req_sed>2500</cstms_valu_req_sed><is_cntry_allow_aes4>YES</is_cntry_allow_aes4><ant_pu_dt>null</ant_pu_dt><ca_int_allow>True</ca_int_allow><eef_cstms_valu_amt>null</eef_cstms_valu_amt><ftr_cd>0</ftr_cd><pieces_flg>0</pieces_flg><sed action\="null"><fault>null</fault><emplr_id_typ_cd descr\="null"></emplr_id_typ_cd><emplr_id_nbr>null</emplr_id_nbr><itn_requested_emplr_id_typ_cd>0</itn_requested_emplr_id_typ_cd><prty_relt_flg>NO</prty_relt_flg><itarITN>null</itarITN><itarLic>null</itarLic><ultCntry>null</ultCntry><ultCsgn>null</ultCsgn><itn>null</itn><sed_id>null</sed_id><sed_filing_typ>null</sed_filing_typ><eef_login_id>null</eef_login_id><routed_export_txn>NO</routed_export_txn><ln_itms action\=""><totl>0</totl><totl_wt>0</totl_wt></ln_itms><ultCnsg>null</ultCnsg></sed><dept_state_shpt_flg>NO</dept_state_shpt_flg><prnt_nafta_flg>NO</prnt_nafta_flg><creat_cert_orgn_flg>NO</creat_cert_orgn_flg><request_landed_cost>null</request_landed_cost><orgn_stat_id>null</orgn_stat_id><dest_svc_area_cd>null</dest_svc_area_cd><orgn_svc_area_cd>null</orgn_svc_area_cd><svc_typ_descr>null</svc_typ_descr><wt_um_cd>1</wt_um_cd><package_typ>6</package_typ><insur_typ_cd>0</insur_typ_cd><insur_typ_cd_descr>null</insur_typ_cd_descr><bill_to_desc>null</bill_to_desc><bill_duty_to_desc>null</bill_duty_to_desc><stat_cd><![CDATA[P]]></stat_cd><src_cd>null</src_cd><trans_id>null</trans_id><crdt_Card_nbr>null</crdt_Card_nbr><pkp_cnfrm_nbr>null</pkp_cnfrm_nbr><unique_id>null</unique_id><shpt_for_focus_flg>YES</shpt_for_focus_flg><gbl_product_cd>D</gbl_product_cd><lcl_product_cd>null</lcl_product_cd><ofac_flg>NO</ofac_flg><paperless_flg><![CDATA[NO]]></paperless_flg><paperless_clr_typ>null</paperless_clr_typ><eco_status_cd>null</eco_status_cd><paperless_clr_archive_dt>null</paperless_clr_archive_dt><dce_itn>null</dce_itn><email_addr><![CDATA[firstoD.lastoD@fundtech.com]]></email_addr><sndr_nam>null</sndr_nam><sndr_addr_1>null</sndr_addr_1><sndr_addr_2>null</sndr_addr_2><sndr_dept_nam>null</sndr_dept_nam><sndr_city_nam>null</sndr_city_nam><sndr_st_prvnc_id>null</sndr_st_prvnc_id><sndr_postl_cd>null</sndr_postl_cd><sndr_cntry_id>100</sndr_cntry_id><sndr_cntry_nam><![CDATA[UNITED STATES]]></sndr_cntry_nam><sndr_regn_cd>1</sndr_regn_cd><rcvr><addr_id>null</addr_id><co_nam><![CDATA[Bright Light]]></co_nam><str_addr_1><![CDATA[1 Canterbury]]></str_addr_1><str_addr_2>null</str_addr_2><dept_nam><![CDATA[Suite 300]]></dept_nam><city_nam><![CDATA[CANTERBURY]]></city_nam><st_prvnc_cd><![CDATA[FL]]></st_prvnc_cd><postl_cd><![CDATA[CT1]]></postl_cd><cntry_id>412.1</cntry_id><regn_cd>4</regn_cd><cntry_nam><![CDATA[UNITED KINGDOM]]></cntry_nam><attn_nam><![CDATA[OtheroD]]></attn_nam><phon_nbr>18015551212</phon_nbr><email_addr><![CDATA[rcvrFirstoD.rcvrLastoD@fundtech.com]]></email_addr><ref_cd>null</ref_cd><note_txt>null</note_txt><prty_relt_flg>NO</prty_relt_flg><ctry_cd><![CDATA[GB]]></ctry_cd><suburb>null</suburb><rcvr_cust_nbr>null</rcvr_cust_nbr><third_pty_cust_nbr>null</third_pty_cust_nbr><addr_bk_typ>null</addr_bk_typ><ofac_restricted_ctry_flg><![CDATA[NO]]></ofac_restricted_ctry_flg><rcvr_postal_code_reqd_flg><![CDATA[YES]]></rcvr_postal_code_reqd_flg><rcvr_suburb_reqd_flg><![CDATA[NO]]></rcvr_suburb_reqd_flg><credit_card_restrict_flg><![CDATA[NO]]></credit_card_restrict_flg><third_party_restrict_flg><![CDATA[NO]]></third_party_restrict_flg><third_party_restrict_wt>0</third_party_restrict_wt><receiver_restrict_flg><![CDATA[NO]]></receiver_restrict_flg><paperless_cntry_flg><![CDATA[YES]]></paperless_cntry_flg><paperless_cntry_max_cstms_valu>9999999.99</paperless_cntry_max_cstms_valu></rcvr><is_itn_requested>NO</is_itn_requested><allow_prsnl_addr_bk>YES</allow_prsnl_addr_bk><neutral_dlvy_flg>NO</neutral_dlvy_flg><acct_supp_flg>NO</acct_supp_flg><is_demo_cust>NO</is_demo_cust><svc_cmpr_cd>NO</svc_cmpr_cd><shpt_ref_fld_lbl><![CDATA[Shipment Reference]]></shpt_ref_fld_lbl><ignore_warn_flg>NO</ignore_warn_flg><ca_paperless_allow>YES</ca_paperless_allow><ca_paperless_generated_inv_flg>YES</ca_paperless_generated_inv_flg><is_validate_address_requested>NO</is_validate_address_requested><ready_time>null</ready_time><check_receiver_address>YES</check_receiver_address><estimatedcharge>18.83</estimatedcharge><shpt_pces>null</shpt_pces><ci action\=""><fault/><is_first_visit/><tax_id/><pkg_mark_txt/><comt_txt/><ln_itms action\=""><totl/><totl_wt/></ln_itms><misc_chrgs><misc_chrg_1>com.fundtech.sbps.dhl.MiscChrg : 19654</misc_chrg_1><misc_chrg_2>com.fundtech.sbps.dhl.MiscChrg : 19655</misc_chrg_2><misc_chrg_3>com.fundtech.sbps.dhl.MiscChrg : 19656</misc_chrg_3><totl/></misc_chrgs><tot_typ_cd/><grnd_totl/><tot_typ_descr/></ci></shpt></exchange>
    ${resp}=  Post Request  dhlSession  /sbps/dhl/index   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>WebShip</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 

    Set To Dictionary  ${data}  csrfToken=${sessionid}
    Set To Dictionary  ${data}  accountAchAccountNumber= 
    Set To Dictionary  ${data}  accountAchActive=
    Set To Dictionary  ${data}  accountAchAuditUserId=
    Set To Dictionary  ${data}  accountAchDateCreated=
    Set To Dictionary  ${data}  accountAchDefault=
    Set To Dictionary  ${data}  accountAchExternalId=
    Set To Dictionary  ${data}  accountAchId=
    Set To Dictionary  ${data}  accountAchLastFour=
    Set To Dictionary  ${data}  accountAchLastUpdated=
    Set To Dictionary  ${data}  accountAchName=
    Set To Dictionary  ${data}  accountAchNameOnAccount=
    Set To Dictionary  ${data}  accountAchRoutingNumber=
    Set To Dictionary  ${data}  accountCardActive=
    Set To Dictionary  ${data}  accountCardAuditUserId=
    Set To Dictionary  ${data}  accountCardBillingCity=
    Set To Dictionary  ${data}  accountCardBillingCountry=
    Set To Dictionary  ${data}  accountCardBillingPostalCode=
    Set To Dictionary  ${data}  accountCardBillingState=
    Set To Dictionary  ${data}  accountCardBillingStreet1=
    Set To Dictionary  ${data}  accountCardBillingStreet2=
    Set To Dictionary  ${data}  accountCardCardNumber  4111111111111111
    Set To Dictionary  ${data}  accountCardCardType=
    Set To Dictionary  ${data}  accountCardDateCreated=
    Set To Dictionary  ${data}  accountCardDefault=
    Set To Dictionary  ${data}  accountCardExpiredDate=
    Set To Dictionary  ${data}  accountCardExternalId=
    Set To Dictionary  ${data}  accountCardId=
    Set To Dictionary  ${data}  accountCardLastFour  4111111111111111
    Set To Dictionary  ${data}  accountCardLastUpdated=
    Set To Dictionary  ${data}  accountCardName=
    Set To Dictionary  ${data}  accountCardNameOnCard  Robot Tester
    Set To Dictionary  ${data}  accountRemember  false
    Set To Dictionary  ${data}  customerActive=
    Set To Dictionary  ${data}  customerAuditUserId=
    Set To Dictionary  ${data}  customerBusinessName  Fundtech
    Set To Dictionary  ${data}  customerCity  Mountain View
    Set To Dictionary  ${data}  customerCountry=
    Set To Dictionary  ${data}  customerCustomDataFields=
    Set To Dictionary  ${data}  customerDateCreated=
    Set To Dictionary  ${data}  customerEmailAddress  ${customer_number}.robotlastname@fundtech.com
    Set To Dictionary  ${data}  customerExternalId  ${shipperid}
    Set To Dictionary  ${data}  customerFirstName  RobotWebshipFirstName
    Set To Dictionary  ${data}  customerId=
    Set To Dictionary  ${data}  customerLastName  RobotWebshipLastName
    Set To Dictionary  ${data}  customerLastUpdated=
    Set To Dictionary  ${data}  customerPhoneNumber=
    Set To Dictionary  ${data}  customerPostalCode  94043
    Set To Dictionary  ${data}  customerSortOrder=
    Set To Dictionary  ${data}  customerState  CA
    Set To Dictionary  ${data}  customerStatus=
    Set To Dictionary  ${data}  customerStreet1  34 Fisher Street
    Set To Dictionary  ${data}  customerStreet2=
    Set To Dictionary  ${data}  customerTypeId=
    Set To Dictionary  ${data}  paymentAchAccountNumber=
    Set To Dictionary  ${data}  paymentAchAchBatchId=
    Set To Dictionary  ${data}  paymentAchAchFileId=
    Set To Dictionary  ${data}  paymentAchAchNsfReturnCount=
    Set To Dictionary  ${data}  paymentAchAchPaymentAccountId=   
    Set To Dictionary  ${data}  paymentAchAchReferenceNo=
    Set To Dictionary  ${data}  paymentAchAchReturnCode=
    Set To Dictionary  ${data}  paymentAchAchTrxId=
    Set To Dictionary  ${data}  paymentAchActive=
    Set To Dictionary  ${data}  paymentAchAmount=
    Set To Dictionary  ${data}  paymentAchAuditUserId=
    Set To Dictionary  ${data}  paymentAchAuditUserName=
    Set To Dictionary  ${data}  paymentAchBankAccountTypeId=
    Set To Dictionary  ${data}  paymentAchCustomDataFields=
    Set To Dictionary  ${data}  paymentAchDateCreated=
    Set To Dictionary  ${data}  paymentAchEffectiveDate= 
    Set To Dictionary  ${data}  paymentAchEmailNotes=
    Set To Dictionary  ${data}  paymentAchExternalId=
    Set To Dictionary  ${data}  paymentAchFee=
    Set To Dictionary  ${data}  paymentAchFeeScheduleId=
    Set To Dictionary  ${data}  paymentAchId=
    Set To Dictionary  ${data}  paymentAchInvoiceNumber=
    Set To Dictionary  ${data}  paymentAchLastUpdated=
    Set To Dictionary  ${data}  paymentAchName=
    Set To Dictionary  ${data}  paymentAchParentPaymentExternalId=
    Set To Dictionary  ${data}  paymentAchPaymentDate=
    Set To Dictionary  ${data}  paymentAchPointOfEntryId=
    Set To Dictionary  ${data}  paymentAchPoNumber=
    Set To Dictionary  ${data}  paymentAchProcessDate=
    Set To Dictionary  ${data}  paymentAchReportNotes=
    Set To Dictionary  ${data}  paymentAchReversedAmount=
    Set To Dictionary  ${data}  paymentAchReversedPayment= 
    Set To Dictionary  ${data}  paymentAchRoutingNumber=
    Set To Dictionary  ${data}  paymentAchScheduleId=
    Set To Dictionary  ${data}  paymentAchSecCode=
    Set To Dictionary  ${data}  paymentAchServiceClassCode=
    Set To Dictionary  ${data}  paymentAchSettlementDate=
    Set To Dictionary  ${data}  paymentAchSettlementEffectiveDate=
    Set To Dictionary  ${data}  paymentAchStatus=
    Set To Dictionary  ${data}  paymentAchStatusId=
    Set To Dictionary  ${data}  paymentAchTaxAmount=
    Set To Dictionary  ${data}  paymentAchTransactionCode=
    Set To Dictionary  ${data}  paymentAchTransactionTypeId=
    Set To Dictionary  ${data}  paymentCardActive=
    Set To Dictionary  ${data}  paymentCardAddressVerificationResult=
    Set To Dictionary  ${data}  paymentCardAmount  575.63
    Set To Dictionary  ${data}  paymentCardAuditUserId=
    Set To Dictionary  ${data}  paymentCardAuditUserName=
    Set To Dictionary  ${data}  paymentCardAuthCode=
    Set To Dictionary  ${data}  paymentCardCardId=
    Set To Dictionary  ${data}  paymentCardCardPaymentAccountId=
    Set To Dictionary  ${data}  paymentCardCardPaymentStatus=
    Set To Dictionary  ${data}  paymentCardCardPaymentStatusId= 
    Set To Dictionary  ${data}  paymentCardCardVerificationResult=
    Set To Dictionary  ${data}  paymentCardCpgBatchId=
    Set To Dictionary  ${data}  paymentCardCpgItemNumber=
    Set To Dictionary  ${data}  paymentCardCpgItemTimestamp=
    Set To Dictionary  ${data}  paymentCardCpgPcRiskLevel=
    Set To Dictionary  ${data}  paymentCardCpgPnrefId=
    Set To Dictionary  ${data}  paymentCardCpgProcResponse=
    Set To Dictionary  ${data}  paymentCardCpgResultId=
    Set To Dictionary  ${data}  paymentCardCustomDataFields  [{airwayBillNumbers:'${airwayBillNumber}'}]
    Set To Dictionary  ${data}  paymentCardCustomerReferenceNumber=
    Set To Dictionary  ${data}  paymentCardCvv  1111
    Set To Dictionary  ${data}  paymentCardDateCreated=
    Set To Dictionary  ${data}  paymentCardDestinationCountryCode=
    Set To Dictionary  ${data}  paymentCardDestinationPostalCode=
    Set To Dictionary  ${data}  paymentCardDiscountAmount=
    Set To Dictionary  ${data}  paymentCardDutyAmount=  
    Set To Dictionary  ${data}  paymentCardEmailNotes=
    Set To Dictionary  ${data}  paymentCardExpirationDate  11/23
    Set To Dictionary  ${data}  paymentCardExternalId=
    Set To Dictionary  ${data}  paymentCardFee=
    Set To Dictionary  ${data}  paymentCardFeeScheduleId=
    Set To Dictionary  ${data}  paymentCardFreightAmount=
    Set To Dictionary  ${data}  paymentCardId=
    Set To Dictionary  ${data}  paymentCardInvoiceNumber=
    Set To Dictionary  ${data}  paymentCardLastUpdated=
    Set To Dictionary  ${data}  paymentCardLevel3Items=
    Set To Dictionary  ${data}  paymentCardNameOnCard=
    Set To Dictionary  ${data}  paymentCardOrderNumber=
    Set To Dictionary  ${data}  paymentCardParentCardPaymentExternalId=
    Set To Dictionary  ${data}  paymentCardPaymentDate=
    Set To Dictionary  ${data}  paymentCardPointOfEntryId=
    Set To Dictionary  ${data}  paymentCardPoNumber=
    Set To Dictionary  ${data}  paymentCardReportNotes=
    Set To Dictionary  ${data}  paymentCardReversedAmount=
    Set To Dictionary  ${data}  paymentCardScheduleId=
    Set To Dictionary  ${data}  paymentCardTaxAmount=
    Set To Dictionary  ${data}  paymentCardTransactionTypeId=
    Set To Dictionary  ${data}  urlBack  http://172.16.225.252:8001/sbpsRefPortal/webShipData/save
    Set To Dictionary  ${data}  urlFail=
    Set To Dictionary  ${data}  urlSucceed=
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/dhl/index 
    ${resp}=  Post Request  dhlSession  /sbps/dhl/submitPayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true  
    #force the payment using the API
    # Wait Until Keyword Succeeds  10 min  20 sec    Run Keyword If  '${testServer}'=='AzureCustint'  Find And Force Webship Payment CI environment  ${airwayBillNumber}
         # ...                ELSE  Find And Force Webship Payment  ${airwayBillNumber}
    Wait Until Keyword Succeeds  10 min  20 sec    Find And Force Webship Payment  ${airwayBillNumber}
    Log  ${airwayBillNumber}
    Set Suite Variable  \${air_way_bill_number}  ${airwayBillNumber}

Call Print and Post - Simulates a user selecting 'Pay Now' on the DHL
    [Tags]    DHL
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.com
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  extraToken  extraToken
    Set To Dictionary  ${data}  signature   ${signature}
    Set To Dictionary  ${data}  payload  <?xml version\="1.0" encoding\="UTF-8" ?><CustomerAccountPayments xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstmqgMYnbD</FirstName><LastName>LastmqgMYnbD</LastName><BusinessName>LastmqgMYnbD's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstmqgMYnbD.LastmqgMYnbD@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>2102809917 P 1 43.31</AmexTaa1><AmexTaa2>mqgMYnbD1661800012</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP552199 PP552199</AmexTaa4><Amount>43.31</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>67710516</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>PrintPost</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstqVfEqMbqMKgXxUxo</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastqVfEqMbqMKgXxUxo</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>mqgMYnbD1661800012</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>43.31</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>91255974</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>48178127</CommodityCode><ProductDescription>2102809917</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>43.31</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>2102809917</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>43.31</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>mqgMYnbD1661800012</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
	
Call Print and Post - Simulates a user Submit CC payment selecting 'Submit' on the DHL
    [Tags]    DHL
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS]
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=13   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@dh.com
    ${account_ACH_NameOn}=  Generate Random String  length=10  chars=[LETTERS]
    ${account_ACH_Number}=  Generate Random String  length=12  chars=[NUMBERS]
    ${EBPPBatchID}=   Generate Random String  length=8  chars=[NUMBERS]
    ${account_Card_NameOnCard}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}  Create Dictionary  create  Send
    Set To Dictionary  ${data}   create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/failure?callback\=failure" returnUrl\="http://172.16.225.252:8001/sbpsRefPortal/printAndPost/save" successUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/success?callback\=success" xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstOHTxOFFQ</FirstName><LastName>LastOHTxOFFQ</LastName><BusinessName>${BusinessName}</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstOHTxOFFQ.LastOHTxOFFQ@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>${airwayBillNumber} P 1 761.75</AmexTaa1><AmexTaa2>${airwayBillNumber}</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP295274 PP295274</AmexTaa4><Amount>761.75</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>${EBPPBatchID}</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>PrintPost</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>${airwayBillNumber}</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>761.75</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>${InvoiceNumber}</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>10300955</CommodityCode><ProductDescription>${airwayBillNumber}</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>761.75</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>${airwayBillNumber}</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>761.75</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>${airwayBillNumber}</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    Set To Dictionary  ${data}   csrfToken                         ${session_id}
    Set To Dictionary  ${data}   invoice                           ${BusinessName}
    Set To Dictionary  ${data}   invoice                           ${ExternalId}
    Set To Dictionary  ${data}   invoice                           987.16
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${InvoiceNumber}
    Set To Dictionary  ${data}   customerEmailAddress              ${EmailID}@example.com
    Set To Dictionary  ${data}   accountCardNameOnCard             ${account_Card_NameOnCard}
    Set To Dictionary  ${data}   accountCardCardNumber             5454545454545454
    Set To Dictionary  ${data}   paymentCardCvv                    111
    Set To Dictionary  ${data}   paymentCardExpirationDate         11/23
    Set To Dictionary  ${data}   paymentCardAmount                 987.16
    Set To Dictionary  ${data}   paymentCardCardPaymentStatus      PreAuthorized
    Set To Dictionary  ${data}   paymentCardPaymentDate            ${today}
    Set To Dictionary  ${data}   accountCardBillingStreet1         test1
    Set To Dictionary  ${data}   accountCardBillingCity            test
    Set To Dictionary  ${data}   accountCardBillingState           AL
    Set To Dictionary  ${data}   accountCardBillingPostalCode      14785
    Set To Dictionary  ${data}   browserTabId   ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  sbps/printPost/submitPayment    data=${data}  headers=${headers}
    Log   ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true


Call Print and Post - Simulates a user Creating ACH payment selecting 'Submit' on the DHL
    [Tags]  Smoke   DHL 
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS]
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=13   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@dh.com
    ${account_ACH_NameOn}=  Generate Random String  length=10  chars=[LETTERS]
    ${account_ACH_Number}=  Generate Random String  length=12  chars=[NUMBERS]
    ${EBPPBatchID}=   Generate Random String  length=8  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}  Create Dictionary  create  Send
    Set To Dictionary  ${data}   create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/failure?callback\=failure" returnUrl\="http://172.16.225.252:8001/sbpsRefPortal/printAndPost/save" successUrl\="http://172.16.225.252:8001/sbpsRefPortal/callback/success?callback\=success" xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstOHTxOFFQ</FirstName><LastName>LastOHTxOFFQ</LastName><BusinessName>${BusinessName}</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstOHTxOFFQ.LastOHTxOFFQ@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>${airwayBillNumber} P 1 761.75</AmexTaa1><AmexTaa2>${airwayBillNumber}</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP295274 PP295274</AmexTaa4><Amount>761.75</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>${EBPPBatchID}</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>PrintPost</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastsuayieBgrLIlVqQX</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>${airwayBillNumber}</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>761.75</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>${InvoiceNumber}</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>10300955</CommodityCode><ProductDescription>${airwayBillNumber}</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>761.75</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>${airwayBillNumber}</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>761.75</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>${airwayBillNumber}</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>Print and Post</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    &{data}  Create Dictionary   invoice                           ${BusinessName}
    Set To Dictionary  ${data}   invoice                           ${InvoiceNumber}
    Set To Dictionary  ${data}   invoice                           987.16
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${today}
    Set To Dictionary  ${data}   invoice                           ${ExternalId}
    Set To Dictionary  ${data}   customerEmailAddress              FirstsWxZKXHz.LastsWxZKXHz@example.com
    Set To Dictionary  ${data}   accountAchNameOnAccount           ${account_ACH_NameOn}
    Set To Dictionary  ${data}   accountAchRoutingNumber           011000015
    Set To Dictionary  ${data}   accountAchAccountNumber           ${account_ACH_Number}
    Set To Dictionary  ${data}   accountAchBankAccountType         Savings
    Set To Dictionary  ${data}   paymentAchAmount                  987.16
    Set To Dictionary  ${data}   paymentAchStatus                  PreAuthorized
    Set To Dictionary  ${data}   paymentAchPaymentDate             ${today}
    Set To Dictionary  ${data}   browserTabId                      ${browser_tab_id[0]}
    Set To Dictionary  ${data}   csrfToken                         ${session_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/printPost/submitPayment    data=${data}  headers=${headers}
    Log   ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    Set Suite Variable  \${ebpp_batch_id}   ${EBPPBatchID}
    Set Suite Variable  \${ebpp_user_name}  ${EbppUserName}
    Set Suite Variable  \${ebpp_batch_id}  ${EBPPBatchID}
    Set Suite Variable  \${invoice_number}  ${InvoiceNumber}
	
Create AutoPay ACH Mywallet and Simulates a user to selecting 'Add New Account'on the DHL
    [Tags]    DHL
    Create Sessions
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>First${customer_name_uniqueifier}</FirstName><LastName>Last${customer_name_uniqueifier}</LastName><BusinessName>Last${customer_name_uniqueifier}'s Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>First${customer_name_uniqueifier}.Last${customer_name_uniqueifier}@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    Set To Dictionary  ${data}  csrfToken                       ${session_id}
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType        Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount        ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname             ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                  ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                  ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    ${accountAchAccountId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountAchAccountId
    Should Be Equal  ${success}  true
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${ach_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${ach_created_customer_id}
    ####xAddPaymentSchedule
    ${data}  Create Dictionary  csrfToken              ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountId    ${accountAchAccountId}
    Set To Dictionary  ${data}  customerId            ${ach_created_customer_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  browserTabId                  ${browser_tab_id[0]}
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
   	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true

test - Create AutoPay ACH Mywallet and Simulates a user to selecting 'Add New Account'on the DHL with long email address
    [Tags]    DHL
    Create Sessions
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>First${customer_name_uniqueifier}</FirstName><LastName>Last${customer_name_uniqueifier}</LastName><BusinessName>Last${customer_name_uniqueifier}'s Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>First${customer_name_uniqueifier}.Last${customer_name_uniqueifier}@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    Set To Dictionary  ${data}  csrfToken                       ${session_id}
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType        Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount        ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname             ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            happy.tester${customer_name_uniqueifier}@finastra.shopping
	Set To Dictionary  ${data}	oboEmailAddress                 happy.tester${customer_name_uniqueifier}@finastra.shopping
	Set To Dictionary  ${data}	userEmailAddress                happy.tester${customer_name_uniqueifier}@finastra.shopping
	Set To Dictionary  ${data}	accountDigits                  ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                  ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    ${accountAchAccountId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountAchAccountId
    Should Be Equal  ${success}  true
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${ach_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${ach_created_customer_id}
    ####xAddPaymentSchedule
    ${data}  Create Dictionary  csrfToken              ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountId    ${accountAchAccountId}
    Set To Dictionary  ${data}  customerId            ${ach_created_customer_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}  browserTabId                  ${browser_tab_id[0]}
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
   	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true


	
Create AutoPay Credit Card Mywallet and Simulates a user to selecting 'Add New Account'on the DHL
    [Tags]    DHL
    Create Sessions
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>First${customer_name_uniqueifier}</FirstName><LastName>Last${customer_name_uniqueifier}</LastName><BusinessName>Last${customer_name_uniqueifier}'s Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>First${customer_name_uniqueifier}.Last${customer_name_uniqueifier}@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    ${data}=  Create Dictionary  csrfToken                          ${session_id} 
    Set To Dictionary  ${data}   accountCardBillingCity             Pune
    Set To Dictionary  ${data}   accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}   accountCardBillingState            CA
    Set To Dictionary  ${data}   accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}   accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}   accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}   accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}   customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}   oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}   paymentCardExpirationDate          11/23
    Set To Dictionary  ${data}   userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}   browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountCardId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountCardId
     #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
    Set To Dictionary  ${data}   browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${cc_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${cc_created_customer_id}
    ### create Payment schedule
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customerId      ${cc_created_customer_id}
    Set To Dictionary  ${data}  accountCardId    ${accountCardId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}   browserTabId                       ${browser_tab_id[0]}
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
	
Add AutoPay ACH and Credit Card Mywallet and Simulates a user to selecting 'Add New Account' to Add 'ACH and CC Wallet' on the DHL    
   [Tags]  Smoke   DHL 
    Create Sessions
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload   <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>First${customer_name_uniqueifier}</FirstName><LastName>Last${customer_name_uniqueifier}</LastName><BusinessName>Last${customer_name_uniqueifier}'s Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>First${customer_name_uniqueifier}.Last${customer_name_uniqueifier}@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
        ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    Set To Dictionary  ${data}  csrfToken                       ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType       Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount         ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname              ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                   ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                   ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    Set To Dictionary  ${data}  csrfToken                          ${session_id} 
    Set To Dictionary  ${data}  accountCardBillingCity             Pune
    Set To Dictionary  ${data}  accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}  accountCardBillingState            CA
    Set To Dictionary  ${data}  accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}  accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}  accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}  accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  paymentCardExpirationDate          11/23
    Set To Dictionary  ${data}  userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true

AutoPay, Add ACH, Add Credit Card, xAddPaymentSchedule, xEditPaymentSchedule - Simulates a user to selecting 'EDIT' on the DHL
    [Tags]  Smoke   DHL 
    Create Sessions
    Log Variables
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/sbpsRefPortal/printAndPost/save
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload     <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstrHpngLyM</FirstName><LastName>LastrHpngLyM</LastName><BusinessName>LastrHpngLyM's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstrHpngLyM.LastrHpngLyM@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${cc_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${cc_created_customer_id}
    #####  Begin Create ACH Payment Account
    ${data}  Create Dictionary  csrfToken                       ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}  accountAchBankAccountType       Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount         ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname              ${account_Ach_Nickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}  customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	accountDigits                   ${accountDigits}
	Set To Dictionary  ${data}  browserTabId                   ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountAchAccountId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountAchAccountId
    #####  Begin Create CC Payment Account
    ${data}  Create Dictionary  csrfToken                          ${session_id} 
    Set To Dictionary  ${data}  accountCardBillingCity             Pune
    Set To Dictionary  ${data}  accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}  accountCardBillingState            CA
    Set To Dictionary  ${data}  accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}  accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}  accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}  accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  paymentCardExpirationDate          11/23
    Set To Dictionary  ${data}  userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}  browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountCardId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountCardId
    #####  Begin xAddPaymentSchedule
	${data}=  Create Dictionary  csrfToken      ${session_id} 
    Set To Dictionary  ${data}   customerId     ${cc_created_customer_id}
    Set To Dictionary  ${data}   accountCardId  ${accountCardId}
    Set To Dictionary  ${data}   browserTabId   ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${scheduleId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..scheduleId
    ####  Begin xEditPaymentSchedule
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  accountAchAccountId   ${accountAchAccountId}
    Set To Dictionary  ${data}  scheduleId           ${scheduleId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}   browserTabId       ${browser_tab_id[0]}
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
   	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xEditPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    
Select AutoPay Credit Card account as schedule wallet Simulates a user to selecting 'EDIT' on the DHL
    [Tags]    DHL
    Create Sessions
    ${ExternalId}=  Generate Random String  length=9  chars=[NUMBERS]
    ${customer_name_uniqueifier}=  Generate Random String  length=20  chars=[LETTERS]
    ${data}=  Create Dictionary  AddPaymentAccount  ACH
    ${account_Ach_NameOnAccount}=  Generate Random String  length=9  chars=[LETTERS]
    ${account_Ach_Nickname}=  Generate Random String  length=10  chars=[LETTERS]
    ${accountDigits}=  Generate Random String  length=10  chars=[NUMBERS]
    ${account_CC_NameOnCARD}=  Generate Random String  length=9  chars=[LETTERS]
    ${accountCardNickname}=  Generate Random String  length=10  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}   extraToken   extraToken
    Set To Dictionary  ${data}   signature   ${signature}
    Set To Dictionary  ${data}   payload     <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstrHpngLyM</FirstName><LastName>LastrHpngLyM</LastName><BusinessName>LastrHpngLyM's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstrHpngLyM.LastrHpngLyM@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${cc_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${cc_created_customer_id}
    ### Add ACH Payment Account
    ${data}=  Create Dictionary  csrfToken                       ${session_id} 
    Set To Dictionary  ${data}   accountAchAccountNumber         ${accountDigits}
    Set To Dictionary  ${data}   accountAchBankAccountType       Checking
    Set To Dictionary  ${data}   accountAchNameOnAccount         ${account_Ach_NameOnAccount}
    Set To Dictionary  ${data}   accountAchNickname              ${account_Ach_Nickname}
    Set To Dictionary  ${data}   accountAchRoutingNumber         011000015
    Set To Dictionary  ${data}   customerEmailAddress            dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	 oboEmailAddress                 dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	 userEmailAddress                dayanand.mhetre${customer_name_uniqueifier}@finastra.com
	Set To Dictionary  ${data}	 accountDigits                   ${accountDigits}
	Set To Dictionary  ${data}   browserTabId                   ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountAchAccountId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountAchAccountId
    ### Add CC Payment Account
    ${data}=  Create Dictionary  csrfToken                          ${session_id} 
    Set To Dictionary  ${data}   accountCardBillingCity             Pune
    Set To Dictionary  ${data}   accountCardBillingPostalCode       14785
    Set To Dictionary  ${data}   accountCardBillingState            CA
    Set To Dictionary  ${data}   accountCardBillingStreet1          Pune
    Set To Dictionary  ${data}   accountCardCardNumber              4111111111111111
    Set To Dictionary  ${data}   accountCardNameOnCard              ${account_CC_NameOnCARD}
    Set To Dictionary  ${data}   accountCardNickname                ${accountCardNickname}
    Set To Dictionary  ${data}   customerEmailAddress               dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}   oboEmailAddress                    dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}   paymentCardExpirationDate          11/23
    Set To Dictionary  ${data}   userEmailAddress                   dayanand.mhetre${customer_name_uniqueifier}@finastra.com
    Set To Dictionary  ${data}   browserTabId                       ${browser_tab_id[0]}
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountCardId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountCardId
    #### Add Payment Schedule with ACH
	${data}  Create Dictionary  csrfToken  ${session_id} 
	Set To Dictionary  ${data}  accountAchAccountId   ${accountAchAccountId}
    Set To Dictionary  ${data}  customerId           ${cc_created_customer_id}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}   browserTabId                       ${browser_tab_id[0]}
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
   	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    #### Edit to change to CC
    ${data}  Create Dictionary  csrfToken  ${session_id} 
    Set To Dictionary  ${data}  customer_id      ${cc_created_customer_id}
    Set To Dictionary  ${data}  accountCardId    ${accountCardId}
    Set To Dictionary  ${data}  page  1
    Set To Dictionary  ${data}  start  0
    Set To Dictionary  ${data}  limit  25
    Set To Dictionary  ${data}   browserTabId                       ${browser_tab_id[0]}
   	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
   	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xEditPaymentSchedule  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true

Call Autopay - Simulates a user create ACH payment account and Submit ACH payment by selecting 'Submit' on the DHL email address to allow more than two characters in domain name
    [Tags]  Smoke   DHL 
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${ExternalId1}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.com
    ${accountAchNickname}=  Generate Random String  length=6  chars=[LETTERS]
    ${accountAchAccountNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${accountAchNameOnAccount}=  Generate Random String  length=6  chars=[LETTERS]
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  extraToken  extraToken
    Set To Dictionary  ${data}  signature   ${signature}
    Set To Dictionary  ${data}   payload     <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1" xmlns:ext\="http://www.w3.org/2001/XMLSchema"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirstrHpngLyM</FirstName><LastName>LastrHpngLyM</LastName><BusinessName>LastrHpngLyM's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirstrHpngLyM.LastrHpngLyM@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${processing_account_id}</ProcessingAccountId></Customer><ext:AutoPayAdmin>true</ext:AutoPayAdmin></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
	Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${cc_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${cc_created_customer_id}
    ### Add Ach Payment Account
    ${data}=  Create Dictionary  csrfToken=${session_id} 
    Set To Dictionary  ${data}  accountAchAccountNumber=${accountAchAccountNumber}
    Set To Dictionary  ${data}  accountAchBankAccountType=Checking
    Set To Dictionary  ${data}  accountAchNameOnAccount=${accountAchNameOnAccount}
    Set To Dictionary  ${data}  accountAchNickname=${accountAchNickname}
    Set To Dictionary  ${data}  accountAchRoutingNumber=011000015
    Set To Dictionary  ${data}  customerEmailAddress=${EbppUserName}
    Set To Dictionary  ${data}  oboEmailAddress=${EbppUserName}
    Set To Dictionary  ${data}  userEmailAddress=${EbppUserName}
    Set To Dictionary  ${data}  accountDigits=${accountAchAccountNumber}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount   data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountAchAccountId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountAchAccountId
    Log  ${accountAchAccountId}
    Set Suite Variable  \${accountAchAccountId}  ${accountAchAccountId}
    ### Submit Invoice Payment
    ${data}=  Create Dictionary  csrfToken=${session_id} 
    Set To Dictionary  ${data}  accountAchAccountId=${accountAchAccountId}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]} 
    Set To Dictionary   ${data}  customerId  ${cc_created_customer_id}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentSchedule   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    
    
test Call Ebilling - Simulates a user create CC payment account and Submit CC payment by selecting 'Submit' on the DHL - email address to allow more than two characters in domain name
    [Tags]    DHL
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${ExternalId1}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.shopping
    ${accountCardNickname}=  Generate Random String  length=6  chars=[LETTERS]
    ${accountCardNameOnCard}=  Generate Random String  length=6  chars=[LETTERS]
    ${EmailIDs}=    Generate Random String    length=8   chars=[LETTERS]
    ${domains}=    Generate Random String    length=5   chars=[LETTERS]
    ${customerEmailAddress}=     Set Variable    ${EmailIDs}@${domains}.shopping
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  extraToken  extraToken
    Set To Dictionary  ${data}  signature   ${signature}
    Set To Dictionary  ${data}  payload  <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirsttiavDVQj</FirstName><LastName>LasttiavDVQj</LastName><BusinessName>LasttiavDVQj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirsttiavDVQj.LasttiavDVQj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>1371273177 P 1 370.53</AmexTaa1><AmexTaa2>tiavDVQj1094465769</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP304824 PP304824</AmexTaa4><Amount>370.53</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>30833124</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>tiavDVQj1094465769</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>370.53</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>19988897</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>98270128</CommodityCode><ProductDescription>1371273177</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>370.53</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1371273177</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>370.53</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>tiavDVQj1094465769</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment><Payment><AmexTaa1>1385991913 P 1 66.53</AmexTaa1><AmexTaa2>tiavDVQj1048673105</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP304824 PP304824</AmexTaa4><Amount>66.16</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>2019-01-11T17:51:27.155Z</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>2019-01-11T17:51:27.155Z</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>30833124</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>DBfkxlIkTnzgisPN@fundtech.com</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>1385991913, 1700997055</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>tiavDVQj1048673105</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>66.16</GrandTotalAmount><InvoiceNumber>19988897</InvoiceNumber><OrderNumber>19988897</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>98270128</CommodityCode><ProductDescription>1385991913</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>66.16</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1371273177</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>66.16</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>tiavDVQj1048673105</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${cc_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${cc_created_customer_id}
    ### Add Card Payment Account
    ${data}=  Create Dictionary  csrfToken=${session_id} 
    Set To Dictionary  ${data}  accountCardBillingCity=Gainesville
    Set To Dictionary  ${data}  accountCardBillingPostalCode=32606
    Set To Dictionary  ${data}  accountCardBillingState=FL
    Set To Dictionary  ${data}  accountCardBillingStreet1=5800 NW 39th AVE
    Set To Dictionary  ${data}  accountCardCardNumber=5454545454545454
    Set To Dictionary  ${data}  accountCardNameOnCard=${accountCardNameOnCard}
    Set To Dictionary  ${data}  accountCardNickname=${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress=${customerEmailAddress}
    Set To Dictionary  ${data}  oboEmailAddress=${customerEmailAddress}
    Set To Dictionary  ${data}  paymentCardExpirationDate=11/28
    Set To Dictionary  ${data}  userEmailAddress=${customerEmailAddress}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount   data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountCardId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountCardId
    Log  ${accountCardId}
    Set Suite Variable  \${accountCardId}  ${accountCardId}
    ### Submit Invoice Payment
    ${data}=  Create Dictionary  csrfToken=${session_id} 
    Set To Dictionary  ${data}  accountCardId=${accountCardId}
    Set To Dictionary  ${data}  paymentCardCvv=1111
    Set To Dictionary  ${data}  paymentCardExpirationDate=11/28
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment 
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xSubmitInvoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    ${errors}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..errors
    Log  ${errors}
    Should Be Equal  ${errors}  []
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true

Call Ebilling - Simulates a user create CC payment account and Submit CC payment by selecting 'Submit' on the DHL
    [Tags]  Smoke   DHL 
    Create Sessions
    ${airwayBillNumber}=  Generate Random String  length=10  chars=[NUMBERS] 
    ${InvoiceNumber}=  Generate Random String  length=7  chars=[NUMBERS]
    ${ExternalId}=  Generate Random String  length=14  chars=[NUMBERS]
    ${ExternalId1}=  Generate Random String  length=14  chars=[NUMBERS]
    ${EmailID}=    Generate Random String    length=8   chars=[LETTERS]
    ${domain}=    Generate Random String    length=5   chars=[LETTERS]
    ${EbppUserName}=     Set Variable    ${EmailID}@${domain}.com
    ${accountCardNickname}=  Generate Random String  length=6  chars=[LETTERS]
    ${accountCardNameOnCard}=  Generate Random String  length=6  chars=[LETTERS]
    ${EmailIDs}=    Generate Random String    length=8   chars=[LETTERS]
    ${domains}=    Generate Random String    length=5   chars=[LETTERS]
    ${customerEmailAddress}=     Set Variable    ${EmailIDs}@${domains}.com
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    &{data}=  Create Dictionary  create  Send
    Set To Dictionary  ${data}  extraToken  extraToken
    Set To Dictionary  ${data}  signature   ${signature}
    Set To Dictionary  ${data}  payload  <?xml version\="1.0" encoding\="UTF-8"?><CustomerAccountPayments failureUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/failureCallback" returnUrl\="http://10.3.8.110/customer/dashboard/" successUrl\="https://ebpp-app-testa-1.accountis.net/totalTransact/successCallback" xmlns\="http://www.fundtech.com/t3applicationmedia-v1"><CustomerAccountPayment><Customer><ExternalId>${ExternalId}</ExternalId><FirstName>FirsttiavDVQj</FirstName><LastName>LasttiavDVQj</LastName><BusinessName>LasttiavDVQj's Business</BusinessName><Street1>5800 NW 39th AVE</Street1><City>Gainesville</City><State>FL</State><Zip>32606</Zip><Country>US</Country><PhoneNumber>8011235455</PhoneNumber><EmailAddress>FirsttiavDVQj.LasttiavDVQj@example.com</EmailAddress><CustomDataFields /><ProcessingAccountId>${api_processing_account_id}</ProcessingAccountId></Customer><Payments><Payment><AmexTaa1>1371273177 P 1 370.53</AmexTaa1><AmexTaa2>tiavDVQj1094465769</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP304824 PP304824</AmexTaa4><Amount>370.53</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>${today}</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>30833124</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>${EbppUserName}</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>${airwayBillNumber}</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>tiavDVQj1094465769</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>370.53</GrandTotalAmount><InvoiceNumber>${InvoiceNumber}</InvoiceNumber><OrderNumber>19988897</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>98270128</CommodityCode><ProductDescription>1371273177</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>370.53</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1371273177</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>370.53</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>tiavDVQj1094465769</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment><Payment><AmexTaa1>1385991913 P 1 66.53</AmexTaa1><AmexTaa2>tiavDVQj1048673105</AmexTaa2><AmexTaa3>Winchester, VA Salt Lake City, UT</AmexTaa3><AmexTaa4>10-10-2014 PP304824 PP304824</AmexTaa4><Amount>66.16</Amount><CapturePurchaseLevel>3</CapturePurchaseLevel><CreditPurchaseLevel>3</CreditPurchaseLevel><CustomDataFields><CustomDataField><Name>Invoice Date</Name><Value>2019-01-11T17:51:27.155Z</Value></CustomDataField><CustomDataField><Name>Invoice Due Date</Name><Value>2019-01-11T17:51:27.155Z</Value></CustomDataField><CustomDataField><Name>EBPPBatchID</Name><Value>30833124</Value></CustomDataField><CustomDataField><Name>Channel</Name><Value>Ebilling</Value></CustomDataField><CustomDataField><Name>EBPPUserName</Name><Value>DBfkxlIkTnzgisPN@fundtech.com</Value></CustomDataField><CustomDataField><Name>FirstName</Name><Value>FirstDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>LastName</Name><Value>LastDBfkxlIkTnzgisPN</Value></CustomDataField><CustomDataField><Name>AirWayBillNumbers</Name><Value>1385991913, 1700997055</Value></CustomDataField></CustomDataFields><CustomerReferenceNumber>tiavDVQj1048673105</CustomerReferenceNumber><DestinationCountryCode>USA</DestinationCountryCode><DestinationPostalCode>10154</DestinationPostalCode><FreightAmount>0</FreightAmount><GrandTotalAmount>66.16</GrandTotalAmount><InvoiceNumber>19988897</InvoiceNumber><OrderNumber>19988897</OrderNumber><PaymentLvl3Items><PaymentLvl3Item><CommodityCode>98270128</CommodityCode><ProductDescription>1385991913</ProductDescription><ProductCode>default</ProductCode><Qty>1</Qty><UnitOfMeasure>LBS</UnitOfMeasure><UnitPrice>66.16</UnitPrice><DiscountAmount>0.00</DiscountAmount><DiscountIndicator>N</DiscountIndicator><DiscountRate>0.0</DiscountRate><GrossNetIndicator>G</GrossNetIndicator><ItemReferenceNumber>1371273177</ItemReferenceNumber><TaxAmount>0.00</TaxAmount><TaxRate>0.0</TaxRate><TaxTypeApplied>State</TaxTypeApplied><Amount>66.16</Amount></PaymentLvl3Item></PaymentLvl3Items><PoNumber>tiavDVQj1048673105</PoNumber><ShipFromPostalCode>10154</ShipFromPostalCode><TaxAmount>0.00</TaxAmount><TaxRate>0.00</TaxRate></Payment></Payments></CustomerAccountPayment></CustomerAccountPayments>
    ${resp}=  Post Request  dhlSession  /sbps/invoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    Should Contain  ${resp.content.decode('utf-8')}  <title>eBilling</title>
    Should Be Equal As Strings  ${resp.status_code}  200
    ${browser_tab_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  options.params.browserTabId = (\\d*);  1
    Log  ${browser_tab_id[0]}
    ${session_id}=  Get Regexp Matches  ${resp.content.decode('utf-8')}  sessionid = '(.*?)'  1
    Log  ${session_id[0]}
    Set Suite Variable  \${session_id}  ${session_id[0]} 
    #####  xGetPaymentSchedules
    ${data}  Create Dictionary  csrfToken       ${session_id} 
    Set To Dictionary  ${data}  browserTabId    ${browser_tab_id[0]}
    Set To Dictionary  ${data}  page            1
    Set To Dictionary  ${data}  start           0
    Set To Dictionary  ${data}  limit           25
	&{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xGetPaymentSchedules  data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}  
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${cc_created_customer_id}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..customerId
    Log  ${cc_created_customer_id}
    ### Add Card Payment Account
    ${data}=  Create Dictionary  csrfToken=${session_id} 
    Set To Dictionary  ${data}  accountCardBillingCity=Gainesville
    Set To Dictionary  ${data}  accountCardBillingPostalCode=32606
    Set To Dictionary  ${data}  accountCardBillingState=FL
    Set To Dictionary  ${data}  accountCardBillingStreet1=5800 NW 39th AVE
    Set To Dictionary  ${data}  accountCardCardNumber=5454545454545454
    Set To Dictionary  ${data}  accountCardNameOnCard=${accountCardNameOnCard}
    Set To Dictionary  ${data}  accountCardNickname=${accountCardNickname}
    Set To Dictionary  ${data}  customerEmailAddress=${customerEmailAddress}
    Set To Dictionary  ${data}  oboEmailAddress=${customerEmailAddress}
    Set To Dictionary  ${data}  paymentCardExpirationDate=11/28
    Set To Dictionary  ${data}  userEmailAddress=${customerEmailAddress}
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xAddPaymentAccount   data=${data}  headers=${headers}
    Pretty Print  ${resp.content.decode('utf-8')}
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true
    ${accountCardId}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..accountCardId
    Log  ${accountCardId}
    Set Suite Variable  \${accountCardId}  ${accountCardId}
    ### Submit Invoice Payment
    ${data}=  Create Dictionary  csrfToken=${session_id} 
    Set To Dictionary  ${data}  accountCardId=${accountCardId}
    Set To Dictionary  ${data}  paymentCardCvv=1111
    Set To Dictionary  ${data}  paymentCardExpirationDate=11/28
    Set To Dictionary  ${data}  browserTabId  ${browser_tab_id[0]}
    &{headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
    Set To Dictionary  ${headers}  referer=${url}/sbps/invoicePayment 
    ${resp}=  Post Request  dhlSession  /sbps/ebilling/xSubmitInvoicePayment   data=${data}  headers=${headers}
    Log  ${resp.content.decode('utf-8')}
    ${errors}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..errors
    Log  ${errors}
    Should Be Equal  ${errors}  []
    ${success}=  Get Items By Path  ${resp.content.decode('utf-8')}  $..success
    Should Be Equal  ${success}  true