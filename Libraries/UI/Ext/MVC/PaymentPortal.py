from robot.libraries.BuiltIn import BuiltIn
from robot.utils.asserts import fail
from compiler.ast import Function
from objectpath.core.parser import FALSE


#import sys          #Refernce Files outside of current directory
#sys.path.append('../')

#Core Ext Keywords 
from ExtMVC import ExtMVC


class PaymentPortal:
    """ TODO: MOVE OUT INTO Robot Framweorkd Library """
    # Combobox > Account
    def _get_account_location_combobox(self):
        return ExtMVC().get_basic_component('accountlocationcombobox', None)

    def confirm_account_location_combobox_has_records(self):
        BuiltIn().sleep("4s") #The UI is Slow so we need to let it do it's thing before we check 
        combobox = self._get_account_location_combobox()
        print "combobox" + combobox
        count = combobox + ".getStore().count()"
        if count > 0:
            return BuiltIn().log_to_console('YES, Records Are Loaded Into Combobox Store')
        else:
            raise ValueError("Records Are Not Loaded Yet:", count)
            BuiltIn().fail('Records Are Not Loaded Yet')

    def set_account_location_combobox_value(self, value):
        combobox = self._get_account_location_combobox()
        valueField = ExtMVC().get_record_id(combobox, value)
        return ExtMVC().set_value(combobox, valueField)


    """ 
    TabPanel and Tab Elements    
    """
    # Tab
    def choose_dashboard_tab(self):
        return ExtMVC().set_active_navigation_tab('NV000')

    def choose_payment_tab(self):
        return ExtMVC().set_active_navigation_tab('NV001')

    def choose_customers_tab(self):
        return ExtMVC().set_active_navigation_tab('NV002')

    def choose_reporting_tab(self):
        return ExtMVC().set_active_navigation_tab('NV004') #Check MS Number

    def choose_research_tab(self):
        return ExtMVC().set_active_navigation_tab('NV013')

    def choose_settings_tab(self):
        return ExtMVC().set_active_navigation_tab('NV005')

    
    # PAYMENT Sub Tabs > Presumes you are in Payment Tab
    def choose_one_time_payment_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV006', 'payments')

    def choose_installment_payment_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV007', 'payments')

    def choose_recurring_payment_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV008', 'payments')


    # SETTINGS Sub Tabs > Presumes you are in Settings Tab
    def choose_payment_settings_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV018', 'settings')

    def choose_email_settings_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV016', 'settings')

    def choose_hosted_payments_page_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV019', 'settings')

    def choose_developer_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV021', 'settings')

    # RESEARCH Sub Tabs > Presumes you are in Research Tab
    def choose_transaction_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV020', 'research')

    def choose_authorization_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV022', 'research')


    """

    GRIDS

    """

    
    # Customer Grid Options...

    # Customer Grid
    def choose_customer_from_gridlist(self, name, value):
        ExtMVC().select_grid_row('customersgridpanel', 'CustomerPaymentAccounts', name, value)
        #return self.execute_ext_safe_click('x-grid-row-selected')

    # Confirm Account Location Value
    def confirm_account_location_is_expected(self, expectedValue):
        value = self._get_account_location_combobox() + ".getDisplayValue()"
        script = value + "=== '" + expectedValue + "'"
        return ExtMVC().execute_ext(script)


    def list_all_customers(self):
        return ExtMVC().click_ext_button("#viewcustomersbutton")

    def choose_customer_by_id(self, value):
        self.choose_customer_from_gridlist('customerid', value)

    def choose_first_customer(self):
        gridpanel = ExtMVC().get_basic_component('customersgridpanel')
        sript = gridpanel + ".getSelectionModel().select(0)"
        return ExtMVC().execute_ext(sript)

    def choose_customer_by_name(self, value):
        self.choose_customer_from_gridlist('customername', value)

    def choose_customer_by_fullname(self, lastname, firstname):
        last = self.choose_customer_from_gridlist('lastname', lastname)
        first = self.choose_customer_from_gridlist('firstname', firstname)
        if last is first:
            return self.choose_customer_from_gridlist('lastname', lastname)
            
    def choose_customer_by_business_name(self, value):
        self.choose_customer_from_gridlist('businessname', value)

    def choose_customer_by_address(self, value):
        self.choose_customer_from_gridlist('street1', value)


    # Pyments Grid Options...    
    def create_new_payment_account(self, paymentType):
        return ExtMVC().click_ext_button("#addnewbutton")

    def list_all_ach_payment_accounts(self, paymentType):
        return ExtMVC().click_ext_button("#viewallachbutton")
    
    def list_all_card_payment_accounts(self, paymentType):
        return ExtMVC().click_ext_button("#viewallccbutton")

    def choose_first_payment_account(self, paymentType):
        paymentType = ExtMVC().ternary_equals(paymentType, 'ACH', 'achaccountsgridpanel', 'ccaccountsgridpanel')
        gridpanel = ExtMVC().get_basic_component(paymentType)
        sript = gridpanel + ".getSelectionModel().select(0)"
        return ExtMVC().execute_ext(sript)

    def choose_payment_accout_by_name(self, value, paymentType):        
        gridpanelItemId = ExtMVC().ternary_equals(paymentType, 'ACH', 'achaccountsgridpanel', 'ccaccountsgridpanel')
        storeIdScript = ExtMVC()._get_gridpanel_storeId(gridpanelItemId)
        storeId = ExtMVC().execute_returned_ext(storeIdScript)
        print "choose_payment_accout_by_name locals: {locals}".format(locals=locals())
        ExtMVC().select_grid_row(gridpanelItemId, storeId, 'name', value)
        print " &&& Choose Payment >>> select_grid_row locals: {locals}".format(locals=locals())
        ExtMVC().click_selected_ext_gridrow("4s", gridpanelItemId)
        print " &&& Choose Payment >>> click_selected_ext_gridrow locals: {locals}".format(locals=locals())

    def select_apikey_grid_record(self, value):        
        gridpanelItemId = "savedapikeysgridpanel"
        storeIdScript = ExtMVC()._get_gridpanel_storeId(gridpanelItemId)
        storeId = ExtMVC().execute_returned_ext(storeIdScript)
        ExtMVC().select_grid_row(gridpanelItemId, storeId, 'name', value)
    
    def remove_button_click_selected_apikey_grid_record(self):        
        row = ExtMVC()._dom_grid_selected_row("0")
        removeBtn = row + ".getElementsByClassName('x-grid-cell')[3].getElementsByClassName('x-btn')[0]"
        ExtMVC()._dom_click(removeBtn)

    def edit_selected_apikey_grid_record(self):        
        gridpanelItemId = "savedapikeysgridpanel"
        gridpanel = ExtMVC().get_basic_component(gridpanelItemId)   
        selectedRecord = gridpanel + ".getSelectionModel().selected.getAt(0)"
        isEnabledColumn = gridpanel + ".getColumnManager().columns[1]"
        scriptThree = selectedRecord + ".set(\"isenabled\", !"+selectedRecord+".get('isenabled'))"
        ExtMVC().execute_ext(scriptThree)
        selectedRecord = gridpanel + ".getSelectionModel().selected.getAt(0)"
        rowIndex = gridpanel + ".getStore().indexOf(" + selectedRecord + ")"
        ExtMVC().execute_ext(isEnabledColumn + ".fireEvent(\"checkchange\", " + isEnabledColumn+"," + rowIndex + "," + selectedRecord + ")")

    


    def choose_first_payment_account(self, selector):    #paymentType
        #paymentType = ExtMVC().ternary_equals(paymentType, 'ACH', 'achaccountsgridpanel', 'ccaccountsgridpanel')
        gridpanel = ExtMVC().get_basic_component(selector)
        sript = gridpanel + ".getSelectionModel().select(0)"
        return ExtMVC().execute_ext(sript)

    def choose_payment_accout_by_name(self, value, paymentType):        
        gridpanelItemId = ExtMVC().ternary_equals(paymentType, 'ACH', '#achaccountsgridpanel', '#ccaccountsgridpanel')
        storeIdScript = ExtMVC()._get_gridpanel_storeId(gridpanelItemId)
        storeId = ExtMVC().execute_returned_ext(storeIdScript)
        print "choose_payment_accout_by_name locals: {locals}".format(locals=locals())
        ExtMVC().select_grid_row(gridpanelItemId, storeId, 'name', value)
        ExtMVC().click_selected_ext_gridrow("4s", gridpanelItemId)

    """ 
    Payment - Authorization Checkbox
    """

    def show_ext_authorzation_checkbox(self, associatedRadiofield):
        radiofield = ExtMVC()._get_radiofield_by_selector(associatedRadiofield)
        authorizationContianer = radiofield + ".up('#paymentinformationformpanel').query('#authorizationcheckbox')[0]"
        script = authorizationContianer  + ".setVisible(true)"
        print "show_ext_authorzation_checkbox locals: {locals}".format(locals=locals())
        return ExtMVC().execute_ext(script)

    def set_authorization_radiofield_value(self, selector, associatedRadiofield, value):
        ExtMVC().set_radiofield_value(selector, value)
        BuiltIn().sleep("1s")
        radiofield = ExtMVC()._get_radiofield_by_selector(selector)
        authorizationContianer = radiofield + ".up('#paymentinformationformpanel').query('#authorizationcheckbox')[0]"
        if value == 'true':
            script = radiofield + ".fireEvent('change'," + radiofield + ".up().onRadioButtonChange, " + radiofield + ")"
            print "\n True > \n set_authorization_radiofield_value >>> value is true locals: {locals}".format(locals=locals())
            return ExtMVC().execute_ext(script)



    """ 
    CUSTOM LINKS - Links or Text that are customized for convenience
    """

    def hosted_payment_link(self, server, domain):
        paymentUrlInnerText = "SbpsTargeting.selectComponent('paymentpageurl').inputEl.dom.innerText"
        serverMatchesLink = ExtMVC().execute_returned_ext("/"+ domain + "/i.test(" + paymentUrlInnerText + ")")
        if not serverMatchesLink:
            locationPort = ExtMVC().execute_returned_ext("window.location.port")
            url = ExtMVC().execute_returned_ext("window.location.host.replace('" + locationPort + "', '')")
            paymentUrlInnerText = paymentUrlInnerText + ".replace('" + url + "', '" + domain + ":')"

        if server == 'DhlDevint': 
            return ExtMVC().execute_returned_ext(str(paymentUrlInnerText) + ".replace('https:','http:')")
        else:
            return ExtMVC().execute_returned_ext(paymentUrlInnerText)


    """ ALERTS """


    def choose_first_new_alert(self):
        newalertsgridpanel = ExtMVC().get_basic_component('grid', '#homepagealertgrid')
        print "newalertsgridpanel" + newalertsgridpanel
        storecount = newalertsgridpanel + ".getStore().count()"
        storecount = ExtMVC().execute_returned_ext(storecount)
        if storecount > 0 :
            script = newalertsgridpanel + ".getSelectionModel().select(0)"
            return ExtMVC().execute_ext(script)
        else:
            self.choose_viewall_alerts_tab()
            BuiltIn().sleep("15s")
            viewallgridpanel = ExtMVC().get_basic_component('grid', '#homeviewnewpayment')
            script = viewallgridpanel + ".getSelectionModel().select(0)"
            return ExtMVC().execute_ext(script)


        ''' Alerts TABS '''

   
    def get_alert_tab_panel(self):
        args = "[itemId=alertstabpanel]"
        return ExtMVC().get_basic_component_with_args('tabpanel', args)

    def get_alert_tab_by_text(self, text):
        args = "[cls=section-tab][text=" + text + "]" #Text Not Internationalized Yet in UI...
        return ExtMVC().get_basic_component_with_args('tab', args)

    def get_alert_tab_card(self, text):
        tab = self.get_alert_tab_by_text(text)
        return tab + ".card"

    def set_active_alert_tab(self, text):
        alertTabPanel = self.get_alert_tab_panel()
        tabCard = self.get_alert_tab_card(text)
        return ExtMVC().execute_ext(alertTabPanel + ".setActiveTab("+ tabCard + ");")

            
    ''' DashBoard Grid Options '''

    def choose_viewall_alerts_tab(self):
        alertTabPanel = self.get_alert_tab_panel()
        tabCard = self.get_alert_tab_card('View All')
        return ExtMVC().execute_ext(alertTabPanel + ".setActiveTab("+ tabCard + ");") 
    

    ''' Update Fee '''
   
    def choose_another_fee(self):
        feeschedulecombobox = ExtMVC().get_basic_component('combobox', '#feeschedule')
        feestore = feeschedulecombobox + ".getStore()"
        storecount = feestore + ".count()"
        print storecount
        if storecount > 0 :
            script = feeschedulecombobox + ".setValue(" + feestore + " .getAt(1))"
            BuiltIn().sleep("2s")
            ExtMVC().execute_ext(script)
        else:
            script = feeschedulecombobox + ".getStore().getAt(0)"
            ExtMVC().execute_ext(script)
            

    ''' Update Payment Account by a New One '''
            
    def choose_another_payment_account(self, name):
        paymentaccountcombobox = ExtMVC().get_basic_component('combobox', '#accountcombobox')
        paymentaccountstore = paymentaccountcombobox + ".getStore()"
        paymentaccountstorecount = paymentaccountstore + ".count()"
        BuiltIn().sleep("5s")
        print  ' The store count is ' + paymentaccountstorecount

        if  paymentaccountstorecount <= 2  :
            print paymentaccountstorecount
            script = paymentaccountcombobox + ".setValue(" + paymentaccountstore + " .getAt(1))"
            BuiltIn().sleep("5s")
            ExtMVC().execute_ext(script)
        else:
            paymentaccountcomboboxvalue = paymentaccountstore + ".findRecord('" + name + "', 'Add New')"
            script = paymentaccountcombobox + ".setValue(" + paymentaccountcomboboxvalue + ")"
            BuiltIn().sleep("5s")
            ExtMVC().execute_ext(script)


    '''  Reconciliation Report tab'''
     
    def choose_reconciliation_tab(self):
        reconciliationtabpanel = "Ext.ComponentQuery.query('reportschooseroption')[1]";
        script = reconciliationtabpanel + ".down('#viewbutton')";
        buttonclick = script + ".fireEvent('click',Ext.ComponentQuery.query('button#viewbutton{isVisible(true)}')[1])"
        ExtMVC().execute_ext(buttonclick)


    """ Confirm Lists Exists """
    def customer_list_should_contain(self, value):
        BuiltIn().log_to_console('Customer LIst Should Contain')
        actual = ExtMVC().selected_gridpanel_row_should_contain('customersgridpanel', value, 'customerid')#customername         #customerid   #lastname
        print actual
        print value
        if actual != value:
            raise AssertionError("FAIL: Value should have been '%s' but was '%s' " % (value, actual))
        print "PASS: Selected Merchant Row Value is '%s'." % value

    def payment_account_list_should_contain(self, value, paymentType):
        gridpanelItemId = ExtMVC().ternary_equals(paymentType, 'ach', 'nameonaccount', 'nameoncard')
        actual = ExtMVC().selected_gridpanel_row_should_contain(gridpanelItemId, value)
        if actual != value:
            raise AssertionError("FAIL: Value should have been '%s' but was '%s' " % (value, actual))
        print "PASS: Selected Payment Account Value is '%s'." % value