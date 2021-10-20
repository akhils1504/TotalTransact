*** Settings ***
Documentation    Creating a User and Resetting the Password in Specified Enviornment

Library    SeleniumLibrary    timeout=10                                     implicit_wait=2    run_on_failure=Capture Page Screenshot    
Library    String             #RobotFramework Standard Libraries > String    
Library    FakerLibrary       locale=en_US

Resource    ${CURDIR}../../../../../variables/CommonKeywordsAndVariables.resource
Resource    ${CURDIR}../../../../../variables/CommonUIKeywordsAndVariables.resource

Suite Setup       Run Keywords        Setup Test Suite
                  ...                 AND                 Login
Test Teardown     Test Ui Teardown
Suite Teardown    Teardown Test Suite

*** Variables ***


*** Keywords ***

Failure Options
    Run Keyword If Test Failed    Capture Page Screenshot    

Test UI Teardown
    Failure Options

Login
    Login to Admin Portal Through UI
    Wait Until Page Contains Element    xpath=//span[@class='x-tab-inner x-tab-inner-default' and contains(text(),'Users')]

_Search Newly Created User
    Set Textfield Value JS         \#usersearchtextfield    dummytext
    Wait Until Keyword Succeeds    30s                      200ms                 Verify Grid Is Empty        \#userListGridPanel
    Set Textfield Value JS         \#usersearchtextfield    ${createdUsername}
    Wait Until Keyword Succeeds    10x                      200ms                 Verify Grid Is Not Empty    \#userListGridPanel

_Status Field value Equals
    [Arguments]          ${expectedValue}
    #verify status is inactive
    ${currentStatus}=    Get Textfield Value JS    \#userdetailform #status
    Should Be Equal      ${expectedValue}          ${currentStatus}


*** Test Cases ***

Create Users
    [Tags]    Regression    Smoke
    #declare and populate variables with data
    ${createdUsername}=    Generate Random String    length=10             chars=[LETTERS]
    Set Suite Variable     \${createdUsername}       ${createdUsername}

    Select Navigation Tab    NV003         #Users
    Expand Panel             \#userForm

    #set the reseller combobox to Diamond Reseller
    Select Combobox Value JS    \#createformpanel > #reseller    Diamond Reseller

    #set the merchant combobox to Diamond Printing
    Select Combobox Value JS    \#createformpanel > #merchant    Diamond Printing

    #enter values into text fields
    Set Textfield Value JS    \#createformpanel > [name=firstname]    DiamondRobot
    Set Textfield Value JS    \#createformpanel > [name=lastname]     Merchant
    Set Textfield Value JS    \#createformpanel > [name=username]     ${createdUsername}

    #select the merchant admin radio button
    Execute Javascript    Ext.ComponentQuery.query('#rolegroup')[0].items.items.filter(i => i.inputValue === 'T3MerchantAdmin')[0].setValue(true)

    Click Ext Button JS         button#createUserButton{isVisible(true)}
    Wait Until Page Contains    Copy to Clipboard

    Click Ext Button JS    button#cancel{isVisible(true)}
    Sleep  2s      #Added a sleep inorder to load the Diamond Reseller in the Reseller combobox for the Test Case-Toggle User Activation

Toggle User Activation
    [Tags]    Regression
    #set the reseller to Diamond Reseller
    Select Combobox Value JS    \#userListGridPanel #reseller    Diamond Reseller

    #set the merchant combobox to Diamond Printing
    Select Combobox Value JS    \#userListGridPanel #merchant    Diamond Printing

    #search for the created user from the previous test
    Wait Until Keyword Succeeds    10x    1s    _Search Newly Created User

    #select the newly created user
    Click Grid Row              \#userListGridPanel    username    ${createdUsername}
    Wait Until Page Contains    Toggle Status 

    #click toggle status button
    Click Ext Button JS    \#togglestatusbutton{isVisible(true)}

    Wait Until Keyword Succeeds    30s    200ms    _Status Field Value Equals    Inactive Status

Reset password using user detail lightbox
    [Tags]    Regression
    #click reset password button
    Click Ext Button JS    \#resetpasswordbutton{isVisible(true)}

    Wait Until Page Contains    Are you sure you want to 
    Click Ext Button JS         button#ok{isVisible(true)}
    Wait Until Page Contains    has been reset to
    Click Ext Button JS         button#ok{isVisible(true)}
    Handle Alert                action=DISMISS                timeout=10s

    #verify status is active
    Wait Until Keyword Succeeds    30s    200ms    _Status Field Value Equals    Active Status

    #click close button
    Click Ext Button JS    \#closebutton{isVisible(true)}

    #search the user again and make sure resetting the password updated the status to active
    _Search Newly Created User
    Wait Until Page Contains      Active Status    10s

Change User Roles
    [Tags]    Regression
    [Documentation]    Opens user detail, adds a role, closes user detail, opens the user again and verifies the added role is checked.

    #select the newly created user
    Click Grid Row                      \#userListGridPanel              username    ${createdUsername}
    Wait Until Page Contains Element    extjs:#userdetailform #status    10s

    #Verify it is unchecked first
    #Pause Execution  try Ext.ComponentQuery.query('#rolesCheckboxGroup checkboxfield{boxLabel=="T3Refund Transaction"}')[0].getValue() == False
    Verify Checkbox Value    \#rolesCheckboxGroup checkboxfield{boxLabel=="T3Refund Transaction"}    false

    #click role checkbox for
    Check Checkbox JS    \#rolesCheckboxGroup checkboxfield{boxLabel=="T3Refund Transaction"}

    #click close button
    Click Ext button JS                         \#closebutton{isVisible(true)}
    Wait Until Page Does Not Contain Element    extjs:#userdetailform #status     10s

    #select the newly created user
    Click Grid Row                      \#userListGridPanel              username    ${createdUsername}
    Wait Until Page Contains Element    extjs:#userdetailform #status    10s

    Verify Checkbox Value    \#rolesCheckboxGroup checkboxfield{boxLabel=="T3Refund Transaction"}    true

    #click close button
    Click Ext Button JS                         \#closebutton{isVisible(true)}
    Wait Until Page Does Not Contain Element    extjs:#userdetailform #status     10s

Reset password using reset password form
    [Tags]    Regression    Smoke
    #Put the username in the textbox
    Set Textfield Value JS    \#userResetPasswordForm > #resetpasswordformpanel > sharedtextfield    ${createdUsername}

    #click reset button
    Wait Until Keyword Succeeds    30s    200ms    Click Ext Button JS    \#userResetPasswordForm button[@text="Reset Password"]

    Wait Until Page Contains    Are you sure you want to 
    Click Ext Button JS         button#ok{isVisible(true)}
    Wait Until Page Contains    has been reset to
    Click Ext Button JS         button#ok{isVisible(true)}
    Handle Alert                action=DISMISS                timeout=10s

    #search the user again and make sure resetting the password updated the status to active
    _Search Newly Created User

    Wait Until Page Contains    Active Status

Reset password of invalid user using reset password form
    [Tags]    Regression
    ${random}=    Word 

    #Put the invalid username in the textbox
    Set Textfield Value JS    \#userResetPasswordForm > #resetpasswordformpanel > sharedtextfield    invalid_${random}

    #click reset button
    Click Ext Button JS    \#userResetPasswordForm > button

    Wait Until Page Contains    Are you sure you want to reset 
    Click Ext Button JS         button#ok{isVisible(true)}

    Wait Until Page Contains    user does not exist           timeout=30 seconds    error=None
    Click Ext Button JS         button#ok{isVisible(true)}
