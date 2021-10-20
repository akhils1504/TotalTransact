
from robot.libraries.BuiltIn import BuiltIn
from robot.utils.asserts import fail
from compiler.ast import Function
from objectpath.core.parser import FALSE


#import sys          #Refernce Files outside of current directory
#sys.path.append('../')

#Core Ext Keywords 
from ExtMVC import ExtMVC


class AdminPortal:
    # Tabs
    def choose_dashboard_tab(self):
        return ExtMVC().set_active_navigation_tab('NV090')  # 1) build the msnumber match into check - pass fail 2) using the desired_capabilities plugin to check lang=no
    def choose_merchants_tab(self):
        return ExtMVC().set_active_navigation_tab('NV091')
    def choose_reporting_tab(self):
        return ExtMVC().set_active_navigation_tab('NV093')  
    def choose_research_tab(self):
        return ExtMVC().set_active_navigation_tab('NV094')  
    def choose_users_tab(self):
        return ExtMVC().set_active_navigation_tab('NV003')  

    # MERCHANTS Sub Tabs > Presumes you are in Merchant Tab
    def choose_sub_merchants_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV097', 'merchants')

    # RESEARCH Sub Tabs > Presumes you are in Research Tab
    def choose_reports_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV100', 'reporting')

    # RESEARCH Sub Tabs > Presumes you are in Research Tab
    def choose_transaction_tab(self):
        return ExtMVC().set_sub_active_navigation_tab('NV099', 'research')


    # def choose_payment_tab(self, tabName):
    #     if tabName is 'One Time':
    #     elif tabName is 'Installment':
    #     elif tabName is 'Recurring':

    ''' Users Tab '''
        
    def choose_create_user_tab(self):
        ExtMVC().expand_panel('#userForm')


    """ Confirm Lists Exists """
    def merchant_list_should_contain(self, value):
        actual = ExtMVC().selected_gridpanel_row_should_contain('viewallmerchantgrid', value, 'merchantname')
        print actual
        print value
        if actual != value:
            raise AssertionError("FAIL: Value should have been '%s' but was '%s' " % (value, actual))
        print "PASS: Selected Merchant Row Value is '%s'." % value


    def account_location_list_should_contain(self, value):
        actual = ExtMVC().selected_gridpanel_row_should_contain('accountlocationgridpanel', value, 'accountlocationname')
        print actual
        print value
        if actual != value:
            raise AssertionError("FAIL: Value should have been '%s' but was '%s' " % (value, actual))
        print "PASS: Selected Merchant Row Value is '%s'." % value