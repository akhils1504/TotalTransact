*** Settings ***
Documentation    Creating Reports of Transaction Summary and Reconciliation 

Library    SeleniumLibrary    timeout=10                                     implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library    String             #RobotFramework Standard Libraries > String    
Library    FakerLibrary       locale=en_US

Resource    ../../../../variables/CommonKeywordsAndVariables.resource
Resource    ../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
Test Teardown     Test Ui Teardown
Suite Teardown    Teardown Test Suite

*** Variables ***

${latency_time}  5s

*** Keywords ***
    

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Payment Portal Using UI
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Reporting')]
    Select Navigation Tab    NV004  


Choose Reconciliation Report
    Execute Javascript      var reconcilationWindow= Ext.ComponentQuery.query('reportschooseroption')[1].down('#viewbutton'),
     ...                        viewButton = Ext.ComponentQuery.query('button#viewbutton{isVisible(true)}')[1];
     ...                        reconcilationWindow.fireEvent('click',viewButton);

Enter Transaction Summary Details for Current Day
    # ${today}  Get Current Date    result_format=%m/%d/%Y
    # ${begin_date}  Subtract Time From Date    ${today}   1d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    # ${end_date}  Subtract Time From Date    ${today}   1d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${begin_date}  Get Current Date    result_format=%m/%d/%Y
    ${end_date}  Get Current Date  result_format=%m/%d/%Y
    Set Datefield Value JS    \#filteringcriteriapanel #begindate    ${begin_date}
    Set Datefield Value JS    \#filteringcriteriapanel #enddate    ${end_date}   
    Sleep  ${latency_time}
    ${All}     Set Variable    All
    Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         ${All}     #Downtown       
    Select Combobox Value JS    \#filteringcriteriapanel #datetype                Transaction Date
    Select Combobox Value JS    \#filteringcriteriapanel #transactiontype         ${All}
    Select Combobox Value JS    \#filteringcriteriapanel #statustype              ${All}
    Check Checkbox JS   \#filteringcriteriapanel #customdatacheckbox


Enter Transaction Summary Details for Current Day ACH 
    # ${today}  Get Current Date    result_format=%m/%d/%Y
    # ${begin_date}  Subtract Time From Date    ${today}   1d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    # ${end_date}  Subtract Time From Date    ${today}   1d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${begin_date}  Get Current Date    result_format=%m/%d/%Y
    ${end_date}  Get Current Date  result_format=%m/%d/%Y
    Set Datefield Value JS    \#filteringcriteriapanel #begindate    ${begin_date}
    Set Datefield Value JS    \#filteringcriteriapanel #enddate    ${end_date}   
    Sleep  ${latency_time}
    ${All}     Set Variable    All
    ${ACH}     Set Variable    ACH
    #Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         ${All}     #Downtown 
    Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         Downtown 
    Select Combobox Value JS    \#filteringcriteriapanel #datetype                Transaction Date
    Select Combobox Value JS    \#filteringcriteriapanel #transactiontype         ${ACH}
    Select Combobox Value JS    \#filteringcriteriapanel #statustype              Submitted
    Check Checkbox JS   \#filteringcriteriapanel #customdatacheckbox
    


Enter Transaction Summary Details for Different Date Card
    
    ${begin_date}  Subtract Time From Date    ${today}   10d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${end_date}  Get Current Date    result_format=%m/%d/%Y
    Set Datefield Value JS    \#filteringcriteriapanel #begindate    ${begin_date}
    Set Datefield Value JS    \#filteringcriteriapanel #enddate    ${end_date}   
    Sleep  ${latency_time}
    ${All}     Set Variable    All
    ${CARD}     Set Variable    CARD
    #Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         ${All}     #Downtown   
    Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         Downtown     
    Select Combobox Value JS    \#filteringcriteriapanel #datetype                Transaction Date
    Select Combobox Value JS    \#filteringcriteriapanel #transactiontype         ${Card}
    Select Combobox Value JS    \#filteringcriteriapanel #statustype              ${All}
    Check Checkbox JS   \#filteringcriteriapanel #customdatacheckbox



Enter Transaction Summary Details for Single Account location 
    
    ${begin_date}  Subtract Time From Date    ${today}   10d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    ${end_date}  Get Current Date    result_format=%m/%d/%Y
    Set Datefield Value JS    \#filteringcriteriapanel #begindate    ${begin_date}
    Set Datefield Value JS    \#filteringcriteriapanel #enddate    ${end_date}   
    Sleep  ${latency_time}
    ${All}     Set Variable    All
    #${CARD}     Set Variable    CARD
    #Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         ${All}     #Downtown   
    Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         Downtown     
    Select Combobox Value JS    \#filteringcriteriapanel #datetype                Transaction Date
    Select Combobox Value JS    \#filteringcriteriapanel #transactiontype          ${All}
    Select Combobox Value JS    \#filteringcriteriapanel #statustype              ${All}
    Check Checkbox JS   \#filteringcriteriapanel #customdatacheckbox



    
Enter Transaction Summary Details for Different Date Range
    ${today}  Get Current Date    result_format=%m/%d/%Y
    ${past_date}  Subtract Time From Date    ${today}   10d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Set Datefield Value JS    \#filteringcriteriapanel #enddate    ${today}
    Set Datefield Value JS    \#filteringcriteriapanel #begindate    ${past_date}
    Sleep  ${latency_time}
    ${All}     Set Variable    All
    Select Combobox Value JS    \#filteringcriteriapanel #accountlocation         ${All}     #Downtown       
    Select Combobox Value JS    \#filteringcriteriapanel #datetype                Transaction Date
    Select Combobox Value JS    \#filteringcriteriapanel #transactiontype         ${All}
    Select Combobox Value JS    \#filteringcriteriapanel #statustype              ${All}
    Check Checkbox JS           \#filteringcriteriapanel #customdatacheckbox
        
Enter Reconciliation Details
    Sleep  ${latency_time}
    ${today}  Get Current Date    result_format=%m/%d/%Y
    ${past_date}  Subtract Time From Date    ${today}   10d  result_format=%m/%d/%Y    exclude_millis=True    date_format=%m/%d/%Y
    Execute Javascript    Ext.ComponentQuery.query('#filteringcriteriapanel #enddate')[1].setValue('${today}')
    Execute Javascript    Ext.ComponentQuery.query('#filteringcriteriapanel #begindate')[1].setValue('${past_date}')
    ${All}     Set Variable    All
    Select Combobox Value JS    \#transactiontype    ${All}
    Execute Javascript    Ext.ComponentQuery.query('#filteringcriteriapanel #customdatacheckbox')[1].setValue(true)
 

*** Test Cases ***


#Transaction Summary Report
Generate Transaction Summary Report for Current Day
    [Tags]     Smoke   Regression
    Wait Until Page Contains    Transaction Summary  timeout=15s   error=None
    Sleep   ${latency_time}
    Click Ext Button JS    \#viewbutton{isVisible(true)}
    Wait Until Page Contains    Report Criteria   timeout=15s   error=None
    Sleep  ${latency_time}
    Enter Transaction Summary Details for Current Day
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    There are no transactions for the selected criteria   timeout=15s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE  Wait Until Page Contains  Transaction Report Summary   timeout=15s    error=None
    Expand Panel  \#filteringcriteriapanel    
    

Generate Transaction Summary Report for ACH Transactions alone for Current Day
    [Tags]     Smoke   Regression
    #Wait Until Page Contains    Transaction Summary  timeout=15s   error=None
    #Sleep   ${latency_time}
    #Click Ext Button JS    \#viewbutton{isVisible(true)}
    Wait Until Page Contains    Report Criteria   timeout=15s   error=None
    Sleep  ${latency_time}
    Enter Transaction Summary Details for Current Day ACH 
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    There are no transactions for the selected criteria   timeout=15s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE  Wait Until Page Contains  Transaction Report Summary   timeout=15s    error=None
    Expand Panel  \#filteringcriteriapanel    
 
Generate Transaction Summary Report for Card Transactions alone for Different Date Range
    [Tags]    Smoke    Regression
    Wait Until Page Contains    Report Criteria   timeout=15s   error=None
    Sleep  ${latency_time}
    Enter Transaction Summary Details for Different Date Card
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    There are no transactions for the selected criteria   timeout=15s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE  Wait Until Page Contains  Transaction Report Summary   timeout=15s    error=None
    Sleep  ${latency_time}
    Expand Panel  \#filteringcriteriapanel  

Generate Transaction Summary Report for a Single Account Location
    [Tags]     Smoke   Regression
    # Wait Until Page Contains    Transaction Summary  timeout=15s   error=None
    # Sleep   ${latency_time}
    # Click Ext Button JS    \#viewbutton{isVisible(true)}
    Wait Until Page Contains    Report Criteria   timeout=15s   error=None
    Sleep  ${latency_time}
    Enter Transaction Summary Details for Single Account location 
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    There are no transactions for the selected criteria   timeout=15s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE  Wait Until Page Contains  Transaction Report Summary   timeout=15s    error=None
    Expand Panel  \#filteringcriteriapanel 
 
Generate Transaction Summary Report for Different Date Range
    [Tags]    Smoke    Regression
    Wait Until Page Contains    Report Criteria   timeout=15s   error=None
    Sleep  ${latency_time}
    Enter Transaction Summary Details for Different Date Range
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    There are no transactions for the selected criteria   timeout=15s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE  Wait Until Page Contains  Transaction Report Summary   timeout=15s    error=None
    Expand Panel  \#filteringcriteriapanel
    #Wait Until Page Contains  Transaction Report Summary   timeout=15s    error=None
    #Sleep  ${latency_time}
    #Expand Panel  \#filteringcriteriapanel  


View Transaction Summary Report
    [Tags]    Smoke    Regression
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Enter Transaction Summary Details for Different Date Range
    Wait Until Page Contains    Report Criteria  timeout=15s  error=None
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    Wait Until Page Contains  Transaction Report Summary   timeout=10 seconds    error=None
    Sleep  ${latency_time}
    Sleep  10s
    Click Ext button JS    \#viewdetailsbutton{isVisible(true)}
    Wait Until Page Contains   Report Details    timeout=15s  error=None
    Click Ext button JS  \#closebutton{isVisible(true)}
    Wait Until Page Contains    Transaction Report Summary   timeout=15s    error=None    
    Expand Panel  \#filteringcriteriapanel
     
     
     
Download Transaction Details
    [Tags]    Smoke    Regression
    Wait Until Page Contains  Report Criteria   timeout=15s  error=None
    Enter Transaction Summary Details for Different Date Range
    Wait Until Page Contains    Report Criteria          timeout=10s 
    Click Ext button JS    \#generatereportbutton{isVisible(true)}
    Wait Until Page Contains  Transaction Report Summary   timeout=15s  error=None
    Sleep  ${latency_time}
    Click Ext button JS    \#downloaddetailsbutton{isVisible(true)}
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    Download too large    timeout=10s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE   Expand Panel  \#filteringcriteriapanel


#Reconciliation Report  - Inorder to pass the below test cases, Reconciliation window should be enabled for this merchant
Generate Reconciliation Report
    [Tags]    Smoke    Regression
    Wait Until Page Contains    Reconciliation  timeout=30s   error=None
    Sleep  ${latency_time}
    Choose Reconciliation Report
    Wait Until Page Contains  Report Criteria   timeout=30s  error=None
    Enter Reconciliation Details
    Sleep  ${latency_time}
    Wait Until Page Contains    Report Criteria      timeout=30s  error=None 
    ${reconciliation_generatebutton}    Set Variable  Ext.ComponentQuery.query('#generatereportbutton')[1]
    Execute Javascript    ${reconciliation_generatebutton}.fireEvent('click', ${reconciliation_generatebutton})
    Wait Until Page Contains   Reconciliation Report Summary   timeout=30s   error=None  
    Sleep  10s
#Expanding the Panel
    Execute Javascript     Ext.ComponentQuery.query('#filteringcriteriapanel')[1].expand()

          
Download Reconciliation Report
    [Tags]    Smoke    Regression
    Wait Until Page Contains  Report Criteria   timeout=30s  error=None
    Enter Reconciliation Details
    Sleep  ${latency_time}
#Clicking on Generate Button -written in this way as we are having multiple constructors 
    ${reconciliation_generatebutton}    Set Variable  Ext.ComponentQuery.query('#generatereportbutton')[1]
    Execute Javascript    ${reconciliation_generatebutton}.fireEvent('click', ${reconciliation_generatebutton})
    Wait Until Page Contains    Reconciliation Report Summary  timeout=30s   error=None
#Clicking on Download Details Button - written in this way as we are having multiple constructors 
    ${reconciliation_downloadbutton}    Set Variable  Ext.ComponentQuery.query('#downloaddetailsbutton')[1]
    Execute Javascript    ${reconciliation_downloadbutton}.fireEvent('click', ${reconciliation_downloadbutton})
    ${condition}=  Run keyword And Return Status    Wait Until Page Contains    Download too large    timeout=10s    error=None
    Run Keyword If  ${condition}== True   Click Ext button JS   button#ok{isVisible(true)}
    ...  ELSE   Execute Javascript     Ext.ComponentQuery.query('#filteringcriteriapanel')[1].expand()
    
   
    