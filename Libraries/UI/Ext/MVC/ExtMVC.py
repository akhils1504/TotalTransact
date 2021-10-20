from robot.libraries.BuiltIn import BuiltIn
from robot.utils.asserts import fail
from compiler.ast import Function
from objectpath.core.parser import FALSE
import pyautogui

class ExtMVC:
    __version__ = '0.1'
    pyautogui.FAILSAFE = False
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    selenium = BuiltIn().get_library_instance('SeleniumLibrary')
    root = "Ext.ComponentQuery.query"
    root_component = ""
    runScript = ""
    isVisible = "{isVisible(true)}"
    suiteVariable = ""
   
        
    def hello(self, name):
        print "Hello, %s!" % name
    
    def execute_ext(self, script):
        self.selenium.execute_javascript(script)

    def execute_returned_ext(self, script):
        return self.selenium.execute_javascript("return " + script)
    
    #Wait for Ext Elements
    def wait_for_ext_condition(self, selector, condition=isVisible):
        extCondition = self.root + "('" + selector + condition + "')[0]"
        return self.selenium.wait_for_condition(extCondition)
    
    def component_visible(self, component):
        return self.execute_ext(component + ".isVisible() === true")

    def build_component(self, query=None, arguments="component" + isVisible):
        if query is None: 
            return self.root + "('" + arguments + "')[0]"
        else: 
            return query + "('" + arguments + "')[0]"

    def build_scope_component(self, query=None, scope=None, arguments="component"):
        print "build_scope_component locals: {locals}".format(locals=locals())
        if scope is not None:
            return self.root + "('" + scope + "')[0]" #Only Use ID or Other Definite Definitive Value
        if query is None: 
            return self.root + "('" + arguments + ","  + scope + "')[0]"
        else: 
            return query + "('" + arguments + ","  + scope + "')[0]"

    # def build_visible_scope_component(self, query=None, scope=None, arguments="component" + isVisible):
    #     if query is None: 
    #         return self.root + "('" + arguments + ","  + scope + "')[0]"
    #     else: 
    #         return query + "('" + arguments + ","  + scope + "')[0]"
    


    """ Description: 
            @parent: Ext.ComponentQuery, other defined/passed component string
            @selector: Ext component classname: textfield, combobox, panel, etc.., can also be
            @scope: Ext containing component scope that limits the search as well...
            @params: 
    
    """
    def get_basic_component_by_parent(self, parent, selector, scope, params=None):
        print "get_basic_component_by_parent locals: {locals}".format(locals=locals())
        if params is None:
            argList = selector + self.isVisible
        else:
            argList = selector + params + self.isVisible
            #rules = ["#" in params, "[" in params and "]" in params]
            #if all(rules): else:
        return self.build_scope_component(parent, scope, argList)

    """ Description: 
            @selector: Ext component classname: textfield, combobox, panel, etc.., can also be
            @params: can either be alias, itemid, name, will deduce based on xtype
    
    """

    def ext_components(self):
        sharedFormFieldListA = ['sharedtexfield', 'shareddisplayfield' , 'sharedcombobox', 'sharedcheckboxfield', 'sharedradiofield']
        formFieldListA = ['texfield', 'displayfield' , 'combobox', 'field']
        formFieldListB = ['numberfield', 'datefield', 'pickerfield', 'htmleditor']
        formFIeldListC = ['checkboxfield', 'radiofield', 'checkboxgroup', 'radiofieldgroup']
        formFIeldListD = ['button', 'buttongroup', 'buttontoolbar', 'toolbar']
        allForms = sharedFormFieldListA + formFieldListA + formFieldListB + formFIeldListC + formFIeldListD
        otherComponentsA = ['panel', 'formpanel', 'form', 'tab', 'tabpanel', 'container']
        otherComponentsB = ['fieldlist', 'fielcontainer']
        allOthers = otherComponentsA + otherComponentsB
        return allForms + allOthers
        
    def evaluate_query(self, argument):
        itemId = '#' + argument
        name = '[name=' + argument +  ']'
        label = '[fieldLabel=' + argument + ']'
        text = '[text=' + argument + ']'
        return [itemId, argument, name, label, text]


    def evaluate_match(self):
        xtype = '.xtype'
        itemId = '.itemmId'
        name = '.name'
        label = '.fieldLabel'
        text = '.text'
        print "END evaluate_match ... and RETURN >>>>"
        print [xtype, itemId, name, label, text]
        return [itemId, xtype, name, label, text]

    def check_component_viability(self, component):
        print "check_component_viability: {locals}".format(locals=locals())
        notUndefined = self.execute_returned_ext(component + "!== 'undefined'")
        notNull = self.execute_returned_ext(component + "!== 'null'")
        if notUndefined and notNull:
            print "END check_component_viability before Return True"
            return True

    def get_basic_component_by_ext(self, selector, params=None):
        #print "get_basic_component locals: {locals}".format(locals=locals())
        if params is None:
            argList = selector + self.isVisible
        else:
            if '#' in params: # TODO remoe # in selector after we cleanup panel related methods...
                params = params
            else:
                params = '[name='+ params + ']'
            argList = selector + params + self.isVisible
            #rules = ["#" in params, "[" in params and "]" in params]
            #if all(rules): else:
        return self.build_component(None, argList)

    #def get_basic_component_by_expectation(self, selector, params=None):
        

    def get_basic_component(self, selector, params=None):
        print "get_basic_component locals: {locals}".format(locals=locals())
        extSelectors = self.ext_components()
        if params is None:
            #print "inside IF ... params is None"
            if selector in extSelectors: #if argument is basic generic class search
                selector = selector
            else:
                queries = self.evaluate_query(selector)
                #print "Possbile Queries for Selector: "
                print queries
                for index, value in enumerate(queries):
                    argList = value + self.isVisible
                    component = self.build_component(None, argList)
                    componentViability = self.check_component_viability(component)
                    if componentViability:
                        #print "In Component Viability Check True... \n" + component +  " \nnot undefined or null"
                        return component
                    else:
                        raise ValueError("Component Does Not Exist with selector: '%s'" % (selector))
                        #raise AssertionError("FAIL: Element Was Not Defined '%s'" % (domElement))
                        print "returned undefined or null"
                    
        else:
            queries = self.evaluate_query(params)
            #print "Possbile Queries for Params: "
            #print queries
            for index, value in enumerate(queries):
                argList = selector + params + self.isVisible
                component = self.build_component(None, argList)
                if component != 'undefined' and component != 'null':
                    print "RETURN component with Selector and Params"
                    return component

    def get_basic_component_with_args(self, selector, args):
        return self.build_component(None, selector + args + self.isVisible)
    
    def get_basic_scope_component(self, selector, scope, params=None):
        if params is None:
            argList = selector + self.isVisible
        else:
            argList = selector + params + self.isVisible
            #rules = ["#" in params, "[" in params and "]" in params]
            #if all(rules): else:
        return self.build_scope_component(None, scope, argList)


    #Allow for Multiple Returns
    def return_set_value(self, component, value):
        return self.set_value(component, value) 

    def return_set_unquote_value(self, component, value):
        print "return_set_unquote_value locals: {locals}".format(locals=locals())
        return self.set_unquote_value(component, value)

    def return_set_raw_value(self, component, value):
        return self.set_raw_value(component, value) 

    def return_fire_event(self, component, action, scope):
        return self._fire_event(component, action, scope) 

    #Wait For Internationalized Ext Value  MS277  30 seconds  ''
    def wait_until_internationalized_page_contains(self, msNumber, timeInSeconds, errorMessge=None):
        script = "messages." + msNumber + "()"
        internationalizedText = self.execute_returned_ext(script)
        print internationalizedText
        self.selenium.wait_until_page_contains(internationalizedText,  timeInSeconds, errorMessge)
 
    #Javascript-esq Methods
    def switch_equal(self, array, argument): 
        switcher = array
        return switcher.get(argument, "tier2tabpanel")

    def ternary_equals(self, valueA, valueB, isTrue, isFalse):
        return isTrue if valueA == valueB else isFalse
        # if valueA == valueB:
        #    return isTrue
        # else:
        #   return isFalse

    def ternary_not_equals(self, valueA, valueB, isTrue, isFalse):
        return isTrue if valueA != valueB else isFalse
        # if valueA != valueB:
        #    return isTrue
        # else:
        #   return isFalse

    #messages
    def get_internationalized_text(self, msnumber):
        return "messages." + msnumber + "()"
    #Tab
    def get_tabpane(self, selector):
        return self.get_basic_component('tabpanel', selector)

    def get_tabbar(self, tabpanel):
        return self.execute_ext(tabpanel + ".getTabBar();")

    def get_tabpanel_tabs(self, tabpanel):
        return self.execute_ext(tabpanel + ".items.items;")

    def get_active_tab(self, tabpanel):
        return self.execute_ext(tabpanel + ".getActiveTab();")

    def get_navigation_tab_panel(self):
        args = "[cls=navigation]"
        return self.get_basic_component_with_args('tabpanel', args)

    def get_navigation_tabs(self):
        args = "[cls=navigation-tab]"
        return self.get_basic_component_with_args('tab', args)

    def get_sub_navigation_tab_panel(self, subpanel):
        #args = "[cls=sub-navigation]"
        #return self.get_basic_component_with_args('tier2tabpanel', args)
        return self.get_basic_component(subpanel)   #'tier2tabpanel'         

    def get_sub_navigation_tabs(self):
        args = "[cls=sub-navigation]"
        return self.get_basic_component_with_args('tab', args)

    def get_navigation_tab(self, selector):
        result = self.get_basic_component_with_args('tab', selector)
        return result

    def get_navigation_tab_by_text(self, msnumber):
        text = self.get_internationalized_text(msnumber)
        args = "[cls=navigation-tab][text='+" + text + "+']" 
        return self.get_basic_component_with_args('tab', args)

    def get_navigation_tab_card(self, msnumber):
        tab = self.get_navigation_tab_by_text(msnumber)
        return tab + ".card"

    def set_active_navigation_tab(self, msnumber):
        navigationTabPanel = self.get_navigation_tab_panel()
        tabCard = self.get_navigation_tab_card(msnumber)
        return self.execute_ext(navigationTabPanel + ".setActiveTab("+ tabCard + ");")

    def get_sub_navigation_tab_by_text(self, msnumber):
        text = self.get_internationalized_text(msnumber)
        args = "[cls=sub-navigation][text='+" + text + "+']"
        return self.get_basic_component_with_args('tab', args)

    def get_sub_navigation_tab_card(self, msnumber):
        tab = self.get_sub_navigation_tab_by_text(msnumber)
        return tab + ".card"

    #OBS: Used by both PaymentPortal and AdminPortal Files...
    def set_sub_active_navigation_tab(self, msnumber, subpanel):
        print "set_sub_active_navigation_tab"
        #TODO: After Fixing the Baisc Component so taht it evaluates itemId's, ALiases, etc.. pull the '#'+ out subpanel itemids
        tabs = {
            "payments":"tier2tabpanel", 
            "reporting":"tier2reportingtabpanel", 
            "research":"tier2researchtabpanel",
            "settings":"tier2settingstabpanel",
            "merchants": "tier2tabpanel",
            "users": "userspanel"
        }
        sub = self.switch_equal(tabs, subpanel)
        print "sub"
        print sub
        navigationTabPanel = self.get_sub_navigation_tab_panel(sub)
        print "navigationTabPanel"
        print navigationTabPanel
        tabCard = self.get_sub_navigation_tab_card(msnumber)
        print "tabCard"
        print tabCard
        return self.execute_ext(navigationTabPanel + ".setActiveTab("+ tabCard + ");")


    """
    START TODO: Untested... 
    """

    # Panel
    def _get_panel_by_itemid(self, selector):
        return self.get_basic_component('panel', selector)

    # Checkbox field
    def _get_checkboxfield_by_selector(self, selector):
        return self.get_basic_component('checkboxfield', selector)

    # Radio field/button
    def _get_radiofield_by_selector(self, selector):
        return self.get_basic_component('radiofield', selector)

    # Combobox
    def _get_combobox_by_selector(self, selector): #Make public keyword....
        return self.get_basic_component('combobox', selector)

    def get_combobox_selectable_list(self, selector):
        print "get_combobox_selectable_list" 
        values = self._get_store_items_list_by_id(selector)
        print "Values" + values
        script = BuiltIn().create_list(values)
        print "script" + script
        return self.execute_returned_ext(script)

    def get_combobox_value_from_user(self, selector, message):
        print "get_combobox_value_from_user"
        choices = self.get_combobox_selectable_list(selector)
        print "AFTER >>>>>>  choices > " + choices
        #list = self.selenium.get_selection_from_user(message, str(choices)) #Dialogs
        #print "list > " + list

    # Comboobx Store
    def _get_combobox_store_id(self, selector):
        combobox = self.get_basic_component('combobox', selector)
        script = combobox + ".getStore().storeId"
        storeId = self.execute_returned_ext(script)
        return storeId

    def _get_account_location_combobox_store_id(self):
        combobox = self._get_account_location_combobox()
        script = combobox + ".getStore().storeId"
        storeId = self.execute_returned_ext(script)
        return storeId

    def _get_store_item_list(self, selector, key=None):
        combobox = self.get_basic_component('combobox', selector)
        store = combobox + ".getStore()"
        item = "item.data"
        if key is not None:
            #script = "var list = [];" + store + ".each(function(item) { list.push(" + key +");}); return list"
            script = "var list = [];" + store + ".each(function(item) \\{ return " + item + '[' + key + ']' +";\\});"
            print self.execute_returned_ext(script)
            return self.execute_returned_ext(script)

    def _get_store_items_list_by_id(self, selector):
        script = self._get_store_item_list(selector, ".id")
        return self.execute_ext(script)

    def _get_store_items_list_by_name(self, selector):
        script = self._get_store_item_list(selector, ".name")
        return self.execute_ext(script)

    def create_ext_dictionary(self, selector):
        key = self._get_store_items_list_by_id(selector)
        value = self._get_store_items_list_by_name(selector)
        script = BuiltIn().create_dictionary(key + "=" + value)
        return self.execute_ext(script)


    #Gridpanel
    def _get_gridpanel(self, alias):
        return self.get_basic_component(alias, None)
	
    def _get_gridpanel_basic(self, selector):
        return self.get_basic_component("gridpanel", selector)
    
    def _get_gridpanel_view(self, alias):
        grid = self._get_gridpanel(alias)
        return grid + ".getView()"

    def _get_gridpanel_storeId(self, alias):
        grid = self._get_gridpanel(alias)
        return grid + ".getStore().storeId"

    def _get_selection_model(self, alias):
        grid = self._get_gridpanel(alias)
        return grid + ".getSelectionModel()"

    #Store
    def _get_store(self, obj):
        return "Ext.getStore('" + obj + "')"

    def _get_store_items(self, store, model):
        store = self._get_store(store)
        return store + ".data.items"

    def _get_store_record(self, storeId, name, value):
        store = self._get_store(storeId)
        return store + ".findRecord('" + name + "', '" + value + "')"


    def _get_combobox_store_record(self, storeId, name, value):
        store = self._get_store(storeId)
        return store + ".findRecord('" + name + "', '" + value + "')"


    def _get_record_index(self, storeId, record):
        store = self._get_store(storeId)
        return store + ".indexOf(" + record + ")"

    def select_grid_row(self, alias, storeId, name, value):
        model = self._get_selection_model(alias)
        record = self._get_store_record(storeId, name, value)
        index = self._get_record_index(storeId, record)
        script = model + ".select(" + index + ");"
        print "\n Inside the select_grid_row locals: {locals}".format(locals=locals())
        return self.execute_ext(script)

    def _get_last_selected_row(self, alias):
        grid = self._get_gridpanel(alias)
        script = grid + ".getSelectionModel().getLastSelected()"
        return script

    # Grid Elements...
    def itemclick_ext_grid_row(self, alias, name, value):
        grid = self._get_gridpanel(alias)
        #gridpanelItemId = ExtMVC().ternary_equals(paymentType, 'ACH', '#achaccountsgridpanel', '#ccaccountsgridpanel')
        storeIdScript = ExtMVC()._get_gridpanel_storeId(alias)
        storeId = ExtMVC().execute_returned_ext(storeIdScript)

        #view = self._get_gridpanel_view(alias)
        record = self._get_store_record(storeId, name, value)
        index = self._get_record_index(storeId, record)
        #self.select_grid_row(alias, storeId, name, value)
        #model = self._get_selection_model(alias)
        #lastSelected = self._get_last_selected_row(alias)
        #params =  view + "," + record + "," + "null" + "," + index
        #script = "SB.getApplication().getCustomerController().onCustomersGridItemClick(" + params + ")"
        script = grid + ".fireEvent('itemclick', " + grid + ", " + index + ")"
        #script = model + ".selectionchange(" + model + ", " + lastSelected + ")"
        #script = model + ".fireEvent('selectionchange', " + model + ", " + record + ")"
        #script = view + ".on('itemclick', " + grid + ", " + item + ");"
        #script = view + ".on('itemclick', " + grid + ", " + index + ");"
        
        print "SCRIPT >" + script
        return self.execute_ext(script)

    def select_first_row_via_itemclick(self, selector):
        gridpanel = self.get_basic_component('grid', selector)
        record = gridpanel + ".getSelectionModel().selected.items[0]"
        script = gridpanel + ".fireEvent('itemclick', " + gridpanel + ", " + record + ")"
        print "SCRIPT >" + script
        return self.execute_ext(script)

    def select_first_row_via_itemdblclick(self, selector):
        gridpanel = self.get_basic_component('grid', selector)
        record = gridpanel + ".getSelectionModel().selected.items[0]"
        script = gridpanel + ".fireEvent('itemdblclick', " + gridpanel + ", " + record + ")"
        print "SCRIPT >" + script
        return self.execute_ext(script)

        #cellclick
    def select_first_row_via_cellclick(self, selector):
        gridpanel = self.get_basic_component('grid', selector)
        cellIndex = gridpanel + ".getSelectionModel().selected.items[0]"
        record = gridpanel + ".getSelectionModel().selected.items[0]"
        #script = gridpanel + ".fireEvent('cellclick', " + gridpanel + ", " + record + ")"
        script = gridpanel + ".fireEvent('cellclick', " + gridpanel + ", " + gridpanel + ",0 ," + record + ")"
        print "SCRIPT >" + script
        return self.execute_ext(script)


    #Comboboxes, etc...
    def _call_out_from_list(self, collection, extClassProperty):
        extList = "var list = []; \n Ext.Array.forEach(" + collection + "function(item) { \n list.push(item" + extClassProperty +"); return list  \n });"
        return self.execute_ext(extList)
    
    def show_all_itemids_of(self, selector, scopeSelector, scopeSelectorItemId):
        component = self.get_basic_component(scopeSelector, scopeSelectorItemId)
        executedComponent = self.execute_ext(component)
        collection = self.execute_ext(executedComponent +".query('"+ selector +"{isVisible()}')")
        itemIds = self._call_out_from_list(collection, "itemId")
        BuiltIn().log_many(itemIds)
        BuiltIn().log(itemIds, "TRACE", True, True, True)


    def confirm_combobox_has_records(self, selector):
        BuiltIn().sleep("4s") #The UI is Slow so we need to let it do it's thing before we check 
        combobox = ExtMVC().get_basic_component('combobox', selector)
        print "combobox" + combobox
        count = combobox + ".getStore().count()"
        if count > 0:
            return BuiltIn().log_to_console('YES, Records Are Loaded Into Combobox Store')
        else:
            raise ValueError("Records Are Not Loaded Yet:", count)
            BuiltIn().fail('Records Are Not Loaded Yet')

    """ 
    END TODO: Untested... 
    """   

    #Textfields
    def ext_textfield_blur(self, scope, selector):
        component = self.get_basic_component('textfield', selector)
        return self.execute_ext(component + ".blur()")


    def ext_textfield_keyup(self, selector):
        textfield = self.get_basic_component('textfield', selector)
        return self._fire_event(textfield, 'keyup', textfield)



    def search_field(self, selector, value):
        BuiltIn().log_to_console('Search Records by String')
        #if you want to search by number please use Search FIeld By Number
        #Ext.ComponentQuery.query('textfield#search{isVisible(true)}')[0].setValue('Sapphire').blur()
        textfield = self.get_basic_component('textfield', selector)
        return self.execute_ext(textfield + ".setValue('" + value + "').blur()")

    def clear_search_field(self, selector):
        BuiltIn().log_to_console('Clear Search')
        #if you want to search by number please use Search FIeld By Number
        #Ext.ComponentQuery.query('textfield#search{isVisible(true)}')[0].setValue('Sapphire').blur()
        textfield = self.get_basic_component('textfield', selector)
        blurScript = self.execute_ext(textfield + ".setValue('').blur()")
        script = self.execute_ext(textfield + ".setValue('')")
        print script
        return script

    def grid_has_records(self, selector):
        BuiltIn().log_to_console('Finding Out if Grid Has Records')
        BuiltIn().sleep('25s')
        hasRecords = self.confirm_store_has_records('gridpanel',selector)
        if hasRecords is True:
            BuiltIn().log_to_console('YES, Records Are Present for Store', selector)
            return True
        else:
            BuiltIn().log_to_console('Records Are Not Loaded Yet')
            raise ValueError("Records Are Not Loaded Yet:")
            BuiltIn().fail('Records Are Not Loaded Yet')
            return False




    #EventListeners
    def select(self, component, value): 
        script = component + ".select('" + value + "')"
        print script
        return self.execute_ext(script)

    def set_value(self, component, value): 
        script = component + ".setValue('" + value + "')"
        return self.execute_ext(script)

    def set_raw_value(self, component, value): 
        script = component + ".setRawValue('" + value + "')"
        print "SET RAW VALUE"
        return self.execute_ext(script)

    def set_unquote_value(self, component, value):
        #OBS: Python requires conversion of numeric value to string to properly concantiate, it will not coerce it on it's own.
        script = component + ".setValue(" + str(value) + ")"
        return self.execute_ext(script)
    
    def set_index_value(self, component, value): 
        return self.execute_ext(component + ".setValue(" + value + ")")
    
    def get_value(self, component):
        return self.execute_ext(component + ".getValue()")

    def get_return_value(self, component):
        value = self.execute_returned_ext(component + ".getValue()")
        return value

    def get_return_display_value(self, component): #for Combobox
        value = self.execute_returned_ext(component + ".getRawValue()")
        return value

    def get_return_name_value(self, component): #for Combobox - SHOULD BE RENAMED TO get_return_combobox_value
        value = self.execute_returned_ext(component + ".value")
        return value

    def confirm_value(self, component, value, expectedValue):
        existingValue = self.get_value(component)
        if existingValue is expectedValue and expectedValue is not None:
            return True
        elif existingValue == None:
            raise ValueError("Value Does Not Exist:", existingValue)
            return False
        else:
            raise ValueError("Has existing value:", existingValue)
            return False    

    def _check_before_set_value(self, component, value):
        existingValue = self.get_value(component)
        if existingValue == None:
            existingSetValue = self.set_value(component, value)
            return self.set_value(component, value)
        else:
            raise ValueError("Has existing value:", existingValue)
        
    def _fire_event(self, component, event, scope):
        scope = scope if not "" else component
        return self.execute_ext(component + ".fireEvent('"+ event + "'," +  scope + ")")
    
    """ 
    START TODO: Untested... 
    """
    # Windows
    def get_window_instance(self, selector):
        saved_args = locals()
        #self.suiteVariable = "currentwindow"
        window = self.get_basic_component('window', selector)
        return self.execute_ext(window +".isVisible() === true") 
        #self.set_ext_suite_variable(component)    

    # Messagebox
    def get_alert_instance(self, selector):
        saved_args = locals()
        
    def get_active_window_instance(self):
        return self.execute_ext("Ext.WindowManager.getActive()")

    def get_visible_panel(self, selector):
        ext = self.get_basic_component(selector) + ".itemId"
        return ext

    def get_visible_checkboxfield(self, itemId):
        ext = self.get_basic_component('checkboxfield', itemId) + ".itemId"
        return ext

    
    # Confirmation Ext Elements Exist
    def confirm_active_window_is_expected(self, expectedItemId):
        activeItemId = self.get_active_window_instance().itemId
        return self.execute_ext(activeItemId + "===" + expectedItemId)
    
    def confirm_alert_is_present(self, title):
        script = "Ext.WindowManager.getActive().header.title"
        return self.execute_ext(script + "== '" + title + "'")

    def confirm_panel_focused_is_visible(self, expectedSelector):
        print "confirm_panel_focused_is_visible"
        matches = self.evaluate_match()
        print "Possbile Matches for for Selector: "
        print matches
        for index, value in enumerate(matches):
            print "NATCGED VALUE: "
            print value
            component = self.get_basic_component(expectedSelector)
            print "component with value: "
            print component + value
            panelSelector = component + value
            panelViability = self.check_component_viability(panelSelector)
            print "Panel Viability: "
            print panelViability
            if panelViability:
                print "matches check"
                ext = self.execute_ext(panelSelector + " === " + "'" + expectedSelector + "'")
                if ext:
                    print "\n INSIDE THE IF LOOP FOR confirm_panel_focused_is_visible"
                    return ext
                    BuiltIn().sleep("4s")
            else:
                print "returned undefined or null"
        

    def expand_panel(self, selector):
        expectedPanel = self.get_basic_component('panel', selector)
        script = self.execute_ext(expectedPanel + ".expand()")
        BuiltIn().sleep("4s")

    def confirm_checkboxfield_is_visible(self, expectedItemId):
        panelItemId = self.get_visible_checkboxfield(expectedItemId)
        return self.execute_ext(panelItemId + " === " + "'" + expectedItemId + "'")

    def confirm_checkboxfield_is_checked(self, selector):
        value = self.get_basic_component('checkboxfield#', selector) + ".value"
        iscchecked =  self.get_basic_component('checkboxfield#', selector) + ".isChecked()"
        valueChecked = self.execute_returned_ext(value)
        checkBoxIsChecked =  self.execute_returned_ext(iscchecked)
        if valueChecked == True or checkBoxIsChecked == True:
            return True

    # def does_page_have_element(self, xpth)
    #     return self.Page_should_contain_element("${" + Xpath + "}")

    # def run_element_check(xpath)
    #         Run Keyword Unless("'${" + RESULT "}'"=="'PASS'"  Keyword args*

    """ * * * * USABLE KEYWORDS * * * * """
    def load_combobox_store(self, selector):
        combobox = self._get_combobox_by_selector(selector)
        store = combobox + ".getStore()"
        count = store + ".getCount()"
        if count > 0:
            script = store + ".load()"
            return self.return_script(script)
        else:
            print "Store Already Has Records"

    def manually_select_combobox_value(self, selector, value, forceInput=None):
        BuiltIn().sleep("15s") #The UI is Slow so we need to let it do it's thing before we check 
        print "manually_select_combobox_value locals: {locals}".format(locals=locals())
        combobox = self._get_combobox_by_selector(selector)
        selectScript = combobox + ".fireEvent('select'," + combobox + ", '" + value + "')" 
        print "\n\n ^^&&& \n select \n manually_select_combobox_value locals: {locals}".format(locals=locals())
        return self.execute_ext(selectScript)

    def select_combobox_value(self, selector, value, forceInput=None):
        print "select_combobox_value locals: {locals}".format(locals=locals())
        combobox = self._get_combobox_by_selector(selector)
        self.load_combobox_store(selector)
        valueField = self.get_record_id(combobox, value)
        valueNameField = self.get_record_name(combobox, value)
        if forceInput is None:
            # if valueField != 'undefined':
            #     print "In Valuefield"
            print valueField
            script = self._check_before_set_value(combobox, valueField)
            # if valueNameField != 'undefined':
            #     print "In Valuefield"
            #     print valueNameField
            #     script = self._check_before_set_value(combobox, valueNameField)
            print "select_combobox_value FORCE INPUT IS NONE" 
            print script
        else: 
            script = self.set_value(combobox, value)
            print "select_combobox_value FORCE INPUT IS TRUE" 
            print script
        print "\n set_value \n select_combobox_value locals: {locals}".format(locals=locals())
        self.return_script(script)
        self.ext_combobox_should_contain(selector, value)

    def select_scoped_combobox_value(self, parent, selector, value, forceInput=None):
        scopedCmbobox = "Ext.ComponentQuery.query('#" + parent + "')[0].query('combobox" + selector + "{isVisible(true)}')[0]"
        self.load_combobox_store(selector)
        valueField = self.get_record_id(scopedCmbobox, value)
        valueNameField = self.get_record_name(scopedCmbobox, value)
        print "select_combobox_value locals: {locals}".format(locals=locals())
        if forceInput is None:
            # if valueField != 'undefined':
            #     print "In Valuefield"
            print valueField
            script = self._check_before_set_value(scopedCmbobox, valueField)
            # if valueNameField != 'undefined':
            #     print "In Valuefield"
            #     print valueNameField
            #     script = self._check_before_set_value(scopedCmbobox, valueNameField)
        else: 
            script = self.set_value(scopedCmbobox, value)
        print "\n set_value \n select_combobox_value locals: {locals}".format(locals=locals())
        self.return_script(script)
        self.ext_combobox_should_contain(selector, value)


    def select_combobox_value_valueField(self, selector, value):
        combobox = self._get_combobox_by_selector(selector)
        self.load_combobox_store(selector)
        valueField = self.get_record_name(combobox, value)
        print "select_combobox_value locals: {locals}".format(locals=locals())
        script = self.set_value(combobox, valueField)
        print "\n set_value \n select_combobox_value locals: {locals}".format(locals=locals())
        self.return_script(script)
        self.ext_combobox_name_should_contain(selector, value)

    def select_simple_combobox_value(self, selector, value):
        #Id's that are not Obfuscated and are Numeric
        combobox = self._get_combobox_by_selector(selector)
        self.load_combobox_store(selector)
        valueField = self.get_record_id(combobox, value)
        script = self.set_unquote_value(combobox, valueField)
        self.return_script(script)
        self.ext_combobox_should_contain(selector, value)


    def _get_textfield_value(self, selector, value):
        component = self.get_basic_component('textfield', selector)
        value =  self.get_return_value(component)
        return str(value)


    def _get_radiofield_value(self, selector, value):
        component = self.get_basic_component('radiofield', selector)
        value =  self.get_return_value(component)
        return str(value)


    def _get_checkbox_value(self, selector, value):
        component = self.get_basic_component('checkbox', selector)
        value =  self.get_return_value(component)
        return str(value)

    def _get_combobox_value(self, selector, value):
        component = self._get_combobox_by_selector(selector)
        value =  self.get_return_value(component)
        return str(value)


    def _get_gridpanel_selected_row_value(self, selector, value):
        component = self._get_combobox_by_selector(selector)
        value =  self.get_return_value(component)
        return str(value)

    def _get_combobox_disply_value(self, selector, value):
        component = self._get_combobox_by_selector(selector)
        value =  self.get_return_display_value(component)
        return str(value)

    def _get_combobox_name_value(self, selector, value):
        component = self._get_combobox_by_selector(selector)
        value =  self.get_return_name_value(component)
        return str(value)

    def _confirm_combobox_value_selected(self, selector):
        combobox = self._get_combobox_by_selector(selector)
        script = combobox + ".getValue() !== '' || null"
        return self.execute_ext(script)

    def check_if_payment_account_is_ach(self, selector):
        hasCurrentValue = self._confirm_combobox_value_selected(selector)
        if hasCurrentValue:
            combobox = self._get_combobox_by_iselector(selector)
            script = combobox + ".displayTplData[0].entcreditcardtype"
            return self.execute_ext(script)


    def check_if_payment_account_is_card(self, selector):
        hasCurrentValue = self._confirm_combobox_value_selected(selector)
        if hasCurrentValue:
            combobox = self._get_combobox_by_selector(selector)
            script = combobox + ".displayTplData[0].entcreditcardtype"
            return self.execute_ext(script)

    def set_payment_method_based_on_selection(self,selector):
        ach = self.check_if_payment_account_is_ach(selector)
        card = self.check_if_payment_account_is_card(selector)
        if ach:
            return 'ACH'
        elif card:
            return 'Card'

    def set_value_based_on_selection(self,selector, variable):
        hasCurrentValue = self._confirm_combobox_value_selected(selector)
        if hasCurrentValue and variable is not None:
            combobox = self._get_combobox_by_selector(selector)
            script = combobox + ".displayTplData[0]." + variable
            return self.execute_ext(script)


    """ Gridpanel and Grid Elements """

    def choose_first_row(self, selector):  #'#viewallmerchantgrid'
        gridpanel = self.get_basic_component('grid', selector)
        sript = gridpanel + ".getSelectionModel().select(0)"
        return self.execute_ext(sript)


    def get_keys_from_store_model(self, store):
        fields = store + ".model.getFields()"
        keyItems = self.execute_returned_ext(fields)
        keys = []
        for index, (key, value) in enumerate(keyItems.items()):
                if key not in keys:
                    print key.name
                    keys.append(key.name)
        print keys
        return keys

    def get_keys_from_grid_dataIndex(self, xtype, selector):
        gridpanel = self.get_basic_component(xtype, selector)
        columns = gridpanel +  ".columnManager.columns"
        keyItems = self.execute_returned_ext(columns)
        keys = []
        for index, (key, value) in enumerate(keyItems.items()):
                if key not in keys:
                    print key.dataIndex
                    keys.append(key.dataIndex)
        return keys

    def _get_keys_from_record(self, xtype, selector):
        print "_get_keys_from_record locals: {locals}".format(locals=locals())
        gridpanel = self.get_basic_component(xtype, selector)
        record = gridpanel + ".getStore().data.items[0].data"
        keyItems = self.execute_returned_ext(record)    #print keyItems
        keys = []
        for index, (key, value) in enumerate(keyItems.items()):
                if key not in keys:
                    keys.append(key)
        return keys

    def _get_index_from_record_keys(self, xtype, selector, value):
        #print "_get_index_from_record_keys locals: {locals}".format(locals=locals())
        gridpanel = self.get_basic_component(xtype, selector)
        keys = self._get_keys_from_record(xtype, selector)
        for index, val in enumerate(keys):
            script = gridpanel + ".getStore().findExact('" + val + "', '" + value + "');"
            i = self.execute_returned_ext(script)
            if type(i) == int and i is not -1:
                print "_get_index_from_record_keys Inside Type INT..."
                print self.execute_returned_ext(script)
                return self.execute_returned_ext(script)

    def _get_index_from_record_keys(self, xtype, selector, value):
        #print "_get_index_from_record_keys locals: {locals}".format(locals=locals())
        gridpanel = self.get_basic_component(xtype, selector)
        keys = self._get_keys_from_record(xtype, selector)
        for index, val in enumerate(keys):
            script = gridpanel + ".getStore().findExact('" + val + "', '" + value + "');"
            i = self.execute_returned_ext(script)
            if type(i) == int and i is not -1:
                print "_get_index_from_record_keys Inside Type INT..."
                print self.execute_returned_ext(script)
                return self.execute_returned_ext(script)

    def choose_specific_row(self, selector, value):
        BuiltIn().sleep('10s')
        gridpanel = self.get_basic_component('grid', selector)
        id = self._get_index_from_record_keys('grid', selector, value)
        script = gridpanel + ".getSelectionModel().select(" + str(id) + ")"
        print "choose_specific_row > script"
        print script
        return self.execute_ext(script)

    """ 
    Form Elements    
    """
    def return_script(self, script):
        print "return_script locals: {locals}".format(locals=locals())
        return script

    # Form FIelds

    def get_displayfield_value(self, selector, value, window):
        if window is True:
            displayfield = self.get_basic_component('displayfield', selector)
        else:    
            displayfield = self.get_basic_component('displayfield', selector)
        script = self.get_value(displayfield)
        print script
        self.return_script(script)
        self.ext_textfield_should_contain(selector, value)

    def set_textfield_value(self, selector, value, forceInput=None):
        sharedtextfield = self.get_basic_component('textfield', selector)
        if forceInput is None:
            script = self._check_before_set_value(sharedtextfield, value)
        else:      
            script = self.set_value(sharedtextfield, value)
        self.return_script(script)
        self.ext_textfield_should_contain(selector, value)

    def set_custom_textfield_value(self, customFieldName, value, forceInput=None):
        sharedtextfield = self.get_basic_component('textfield', customFieldName)
        if forceInput is None:
            script = self._check_before_set_value(sharedtextfield, value)
        else:      
            script = self.set_value(sharedtextfield, value)
        self.return_script(script)
        self.ext_textfield_should_contain(customFieldName, value)


    def set_radiofield_value(self, selector, value):
        sharedradiofield = self._get_radiofield_by_selector(selector)
        if (value == True) or (value == 'true'):
            self.return_set_unquote_value(sharedradiofield, value) 
            self.return_fire_event(sharedradiofield, 'click', sharedradiofield)
            print "AFTER > execute_returned_ext locals: {locals}".format(locals=locals())
            #self.execute_returned_ext(sharedradiofield + ".change(" + value + ")")
            print "AFTER > execute_returned_ext locals: {locals}".format(locals=locals())
            self.ext_radiofield_should_contain(selector, value)

    def set_role_radiogroup_value(self, value):
        radio_field = "Ext.ComponentQuery.query('#roleradiogroup')[0].items.items.filter(i => i.inputValue === '" + value + "')[0].setValue(true)"
        self.execute_ext(radio_field)

    def set_checkboxfield_value(self, selector, value):
        if str(value) == 'True':
            value = 'true'
            sharedcheckboxfield = self._get_checkboxfield_by_selector(selector)
            self.return_set_value(sharedcheckboxfield, value) 
            self.return_fire_event(sharedcheckboxfield, 'click', sharedcheckboxfield)
            self.ext_checkbox_should_contain(selector, value)
        #else: TODO: Uncheck the value if it's true and no longer want it checked

    def set_checkboxfield_raw_value(self, selector, value):
        sharedcheckboxfield = self.get_basic_component('checkboxfield', selector)
        if (value == True) or (value == 'true'):
            print " >>>>> Inisde Here"
            self.return_set_raw_value(sharedcheckboxfield, value)   #return 
            #self.return_fire_event(sharedcheckboxfield, 'click', sharedcheckboxfield)    #return 

    def set_radiofield_raw_value(self, selector, value):
        sharedradiofield = self.get_basic_component('radiofield', selector)
        if (value == True) or (value == 'true'):
            print " >>>>> Inisde Here"
            self.return_set_raw_value(sharedradiofield, value)   #return 
            #self.return_fire_event(sharedradiofield, 'click', sharedradiofield)    #return 

    def set_radiofield_scope_raw_value(self, selector, value, scope):
        sharedradiofield = self.get_basic_scope_component('radiofield:not(checkboxfield)', scope, selector)
        if (value is True) or (value == 'true'):
            self.return_set_raw_value(sharedradiofield, value)   #return
            #self.return_fire_value(sharedradiofield, 'change', sharedradiofield)  #return

    # Confirm FIelds are VIsible
    def confirm_textfield_visibile(self, selector):
        sharedtextfield = self.get_basic_component('textfield', selector)
        #print BuiltIn().log_to_console("Combobx Visiblity is" + boolean)
        if sharedtextfield != 'undefined':
            script = sharedtextfield + ".isVisible()"
            boolean = self.execute_returned_ext(script)
            print "BOOLEAN: "
            print boolean
            if boolean is 'true' or boolean is True:
                return True
            elif boolean is 'false':
                return False

    def confirm_combobox_visibile(self, selector):
        sharedcombobox = self.get_basic_component('combobox', selector)
        if sharedcombobox != 'undefined':
            script = sharedcombobox + ".isVisible()"
            boolean = self.execute_returned_ext(script)
            print "BOOLEAN: "
            print boolean
            if boolean is 'true' or boolean is True:
                return True
            elif boolean is 'false':
                return False

    def confirm_checkbox_visibile(self, selector):
        sharedCheckbox = self.get_basic_component('checkbox', selector)
        if sharedCheckbox != 'undefined':
            script = sharedCheckbox + ".isVisible()"
            boolean = self.execute_returned_ext(script)
            print "BOOLEAN: "
            print boolean
            if boolean is 'true' or boolean is True:
                return True
            elif boolean is 'false':
                return False


    """ 
    END Untested - DO NOT PLACE IN AUTOMATED TESTS YET :) 
    """

    def confirm_store_has_records(self, componentclass, selector):
        BuiltIn().log_to_console('Check to see if records are in store...')
        BuiltIn().sleep("24s") #The UI is Slow so we need to let it do it's thing before we check 
        component = self.get_basic_component(componentclass, selector)
        count = self.execute_returned_ext(component + ".getStore().count()")
        print "Store Count:" + str(count)
        if count > 0:
            BuiltIn().log_to_console('YES, Records Are Loaded Into Store', str(count))
            return True
        else:
            #raise ValueError("Records Are Not Loaded Yet:", count)
            BuiltIn().fail('Records Are Not Loaded Yet', str(count))
            return False

    def confirm_record_selected(self, selector, name, value):
        combobox = self.get_basic_component(selector, None)
        store = combobox + ".getStore()"
        count = store + ".count()"
        if count > 0:
            record = store + ".findRecord('" + name + "', '" + value + "')"
            if record != 'null':
                return True
            else:
                return False
        else:
            return False

    def get_record_id(self, component, value):
        store = component + ".getStore()"
        record = store + ".findRecord('name', '" + value + "')"
        script = record + ".get('id')"
        index = self.execute_returned_ext(script)
        return index
        


        script = record + ".get('id')"
        index = self.execute_returned_ext(script)
        return index

    def get_record_name(self, component, value):
        store = component + ".getStore()"
        record = store + ".findRecord('name', '" + value + "')"
        script = record + ".get('name')"
        index = self.execute_returned_ext(script)
        return index
 
    # Date FIelds
    def set_datefield_value(self, selector, value):
        datefield = self.get_basic_component('datefield', selector)
        print "Datefield" + datefield
        return self.set_value(datefield, value)

    # Display FIelds   
    def set_displayfield_value(self, selector, value):
        displayfield = self.get_basic_component('displayfield', selector)
        return self.set_value(displayfield, value)

    def confirm_displayfield_value(self, selector, value, expectedValue):
        displayfield = self.get_basic_component('displayfield', selector)
        return self.confirm_value(displayfield, value, expectedValue)


    # FIle FIelds   
    def set_filefield_value(self, selector, value):
        combobox = self.get_basic_component('filefield', selector)
        return self.set_value(combobox, value)
    
    # Display FIelds   
    def set_htmleditor_field_value(self, selector, value):
        combobox = self.get_basic_component('htmleditor', selector)
        return self.set_value(combobox, value)
    
    """ 
    END Untested - DO NOT PLACE IN AUTOMATED TESTS YET :)
    """

    #BuiltIn().sleep("10s")
    # Item Found by classname

    #BEGIN Custom Dom Queries
    def _dom_grid_selected_row(self, i, latency=None):
        return "document.getElementsByClassName('x-grid-row-selected')[" + i + "]"

    def _dom_grid_selected_row_cell(self, i, latency=None):
        row = self._dom_grid_selected_row(i)
        cell = row + ".getElementsByClassName('x-grid-cell')[0]"
        return cell

    def _dom_click(self, domElement, latency=None):
        returnedDomElement = self.execute_returned_ext(domElement)
        if returnedDomElement:
            script = domElement + ".click()"
            BuiltIn().sleep("" + latency + "") if latency != None else BuiltIn().sleep("1s")
            return self.execute_ext(script)
        else:
            raise AssertionError("FAIL: Element Was Not Defined '%s'" % (domElement))



    #END Custom Dom Queries

    def ext_filter_grids(self, array):
        return array + """.filter(function(it, i) { 
            var item = """ + array + """[i].getView().getEl().dom.getElementsByClassName('x-grid-row-selected')[0];
            return item;
        })""" #not closed witha semicolon becuse it is appended to more extjs outisde of ths method

    def _get_grid_index_from_gridlist(self, selector):
        grid = self.get_basic_component('gridpanel', selector)
        grids = "Ext.ComponentQuery.query('gridpanel{isVisible(true)}')"
        qualifiedGrids = self.ext_filter_grids(grids)
        return str(self.execute_returned_ext(qualifiedGrids + ".indexOf(" + grid + ")"))
    
    def click_selected_ext_gridrow(self, latency=None, selector=None):
        print "click_selected_ext_gridrow locals: {locals}".format(locals=locals())
        i = self._get_grid_index_from_gridlist(selector) if selector is not None else str(0)
        print "_get_grid_index_from_gridlist i variable:"
        print i
        #row = self._dom_grid_selected_row(i)
        cell = self._dom_grid_selected_row_cell(i)
        print "_dom_grid_selected_row_cell"
        print cell
        return self._dom_click(cell)

    # Combobox FIelds   
    def set_checkbox_value(self, selector, value):
        checkboxfield = self.get_basic_component('checkboxfield:not(radiofield)', selector)
        if (value == True) or (value == 'true'):
            self.return_set_value(checkboxfield, value)   #return
            #self.return_fire_event(checkboxfield, 'change', checkboxfield)  #return
            self.ext_checkbox_should_contain(selector, value)

    def set_checkbox_raw_value(self, selector, value):
        checkboxfield = self.get_basic_component('checkboxfield:not(radiofield)', selector)
        if (value == True) or (value == 'true'):
            self.return_set_raw_value(checkboxfield, value)   #return 
            self.return_fire_event(checkboxfield, 'change', checkboxfield)  #return 

    def set_checkbox_scope_raw_value(self, selector, value, scope):
        checkboxfield = self.get_basic_scope_component('checkboxfield:not(radiofield)', scope, selector)
        if (value == True) or (value == 'true'):
            self.return_set_raw_value(checkboxfield, value)
            #self.return_fire_event(checkboxfield, 'change', checkboxfield)

    def set_combobox_value(self, selector, value):
        combobox = self._get_combobox_by_selector(selector)
        return self.set_raw_value(combobox, value)
    
    # Buttons
    def click_ext_button(self, selector):
        button = self.get_basic_component('button', selector)
        return self._fire_event(button, 'click', button)

    def click_scoped_ext_button(self, parentXtype, selector):
        button = "Ext.ComponentQuery.query('" + parentXtype + "')[0].query('button" + selector + "{isVisible(true)}')[0]"
        #button = self.get_basic_scope_component('button', scope, selector)
        return self._fire_event(button, 'click', button)

    def click_ext_toolbar_button(self, selector):
        toolbarButton = self.get_basic_component('toolbarbutton', selector)
        return self._fire_event(toolbarButton, 'click', toolbarButton)

    def ext_button_firehandler(self, selector):
        button = self.get_basic_component('button', selector)
        script = button + ".fireHandler()"
        return self.execute_ext(script)

    def ext_messagebox_button_firehandler(self,selector):
        window = "Ext.WindowManager.getActive()"
        messageBox = self.execute_returned_ext(window + ".getXType()")
        if window:
            if messageBox == 'messagebox':
                button = self.get_basic_component_by_parent(window, 'button', selector)
                script = button + ".fireHandler()"
                return self.execute_ext(script)
            else:
                print "The window was not a mesagebox it is"  + messageBox
        else:
            print "No Window Exists"

    def override_and_enable_disabled_button(self, selector):
        button = self.get_basic_component('button', selector)
        script = button + ".enable()"
        return self.execute_ext(script)

    #Datefields
    def _random_math(self, n):
        number = self.execute_returned_ext("Math.floor(Math.random() * " + n + ") + 0")
        if n == '4':
            script = "new Date().getFullYear()" + "+" + str(number)
            return self.execute_returned_ext(script)
        elif n == '11':
            script = "new Date().getMonth()" + "+" + str(number)
            return self.execute_returned_ext(script)
        print "Here >> \n _random_math locals: {locals}".format(locals=locals())
         

    def _random_expiration(self):
        m = self._random_math('4')
        y = self._random_math('11')
        print "_random_expiration > random math MONTH: " + str(m)
        print "_random_expiration > random math YEAR: " + str(y)
        return str(m) + '/24/' + str(y)

    def random_expiration_month(self):
        random = self._random_expiration()
        script = self.execute_returned_ext("Ext.Date.format(new Date(" + random + "), 'm')")
        return script

    def random_expiration_year(self):
        random = self._random_expiration()
        script = self.execute_returned_ext("Ext.Date.format(new Date(" + random + "), 'y')")
        return script

    #Dates
    def _javascript_time(self, n=0):
        print "new Date(new Date().getTime()+(1000*60*60*24*" + n + "))"
        return "new Date(new Date().getTime()+(1000*60*60*24*" + n + "))" #1000*60*60*24*30

    def _set_days_ahead(self, number, format):
        #time = self._javascript_time(number)
        time = "new Date(new Date().getTime()+(1000*60*60*24*" + number + "))"
        print "TIME >>" + time
        script = self.execute_returned_ext("Ext.Date.format(" + time + ",'" + format + "')")
        print "_set_days_ahead > Days " + number + " Ahead " + str(script)
        return script

    def _set_days_behind(self, number, format):
        time = "new Date(new Date().getTime()+(-1000*60*60*24*" + number + "))"
        script = self.execute_returned_ext("Ext.Date.format(" + time + ", '" + format + "')")
        print "_set_days_behind > Days " + number + " Behind " + str(script)
        return script
    #used to be m/d/y but looks like it doesn't work without full year now
    def set_days_ahead(self, number, format='m/d/Y'): 
            print self._set_days_ahead(number, format)
            return self._set_days_ahead(number, format)

    def set_days_behind(self, number, format='m/d/Y'):
            print self._set_days_behind(number, format)
            return self._set_days_behind(number, format)

    #BEGIN > Pass/Fail Test Test
    def ext_combobox_should_contain(self, selector, value):
        print "Here >> \n ext_combobox_should_contain locals: {locals}".format(locals=locals())
        actual = self._get_combobox_disply_value(selector, value)
        actualName = self._get_combobox_name_value(selector, value)
        print "actual"
        print actual
        print "actualName"
        print actualName
        print "value"
        print value
        if actual != value and actualName != value:
            if actual != 'None' and actual != value:
                errorMessage = "FAIL: Value should have been '%s' but was (actual) '%s' " % (value, actual)
            elif actualName != 'None' and actualName != value:
                errorMessage = "FAIL: Value should have been '%s' but was (actualName) '%s' " % (value, actualName)
            raise AssertionError(errorMessage)
        print "PASS: Selected Combobox Value is '%s'." % value

    def ext_combobox_name_should_contain(self, selector, value):
        print "Here >> \n ext_combobox_name_should_contain locals: {locals}".format(locals=locals())
        actual = self._get_combobox_name_value(selector, value)
        if actual != value:
            raise AssertionError("FAIL: Value should have been '%s' but was '%s' " % (value, actual))
        print "PASS: Selected Combobox Value is '%s'." % value

    def ext_textfield_should_contain(self, selector, value):
        print "Here >> \n ext_textfield_should_contain locals: {locals}".format(locals=locals())
        actual = self._get_textfield_value(selector, value)
        if actual != value:
            raise AssertionError("FAIL: Value should have been '%s' but was '%s' " % (value, actual))
        print "PASS: Textfield Value is '%s'." % value
        
    def ext_checkbox_should_contain(self, selector, value):
        actual = self._get_checkbox_value(selector, value)
        capitalize = actual.capitalize()
        lower = actual.lower()
        if actual == value or capitalize == value or lower == value:
            print "PASS: Checkbox Value is '%s'." % value
        elif actual != value or capitalize != value or lower != value:
            print "Capitalize" + capitalize
            print "Lowercase" + lower
            raise AssertionError("FAIL: ACTUAL Value should have been '%s' but was '%s' " % (value, actual))

    def ext_radiofield_should_contain(self, selector, value):
        actual = self._get_radiofield_value(selector, value)
        capitalize = actual.capitalize()
        lower = actual.lower()
        if actual == value or capitalize == value or lower == value:
            print "PASS: RadioField Value is '%s'." % value
        elif actual != value or capitalize != value or lower != value:
            print "Capitalize" + capitalize
            print "Lowercase" + lower
            raise AssertionError("FAIL: ACTUAL Value should have been '%s' but was '%s' " % (value, actual))

    def selected_gridpanel_row_should_contain(self, selector, value, property=None):
        print "selected_gridpanel_row_should_contain locals: {locals}".format(locals=locals())
        gridpanel = self.get_basic_component(selector)
        if property is None:
            print "poperty is None"
            script = gridpanel + ".getStore().findRecord('name', '" + value + "').get('name')"
        else:
            print "THere Is A poperty" + property
            script = gridpanel + ".getStore().findRecord('" + property + "', '" + value + "').get('" + property + "')"
        executedScript = self.execute_returned_ext(script)
        print "Executed Scrpt..."
        return self.execute_returned_ext(script)

    #END > Pass/Fail Test Test

    #START > Request Mannagement

    def ajax_request_exception(self):
        print "ajax_request_exception locals: {locals}".format(locals=locals())
        #falseResponse = "function (proxy, response) { var obj = Ext.decode(response.responseText); if(obj.success === false) obj.errors[0];}"
        falseResponse = "function (proxy, response) { var response = Ext.decode(response.responseText); console.log(response); response;}"
        script = "Ext.data.proxy.Ajax.on('exception', " + falseResponse + ");"
        #script = "Ext.data.proxy.Ajax.on('exception', function (proxy, response) { var response = Ext.decode(response.responseText); console.log(response); response;});"
        response = self.execute_returned_ext(script)
        print "response"
        print response
        if response:
            print "start_ext_taskmanager locals: {locals}".format(locals=locals())
            print response
            #BuiltIn().log_to_console(response)
            BuiltIn().log("This is the Ajax Exception Response - Failure Occured" + response)
            return response

    #END > Request Management

    #START > Timed Tasks

    def start_ext_taskmanager(self, func, interval=str(10000)):
        print "start_ext_taskmanager locals: {locals}".format(locals=locals())
        #script = "Ext.TaskManager.start({ run: function() {" + func + "}, interval:" + interval + "});"
        # ALL EXT CODE... script = "Ext.TaskManager.start({ run: function() {Ext.data.proxy.Ajax.on('exception', function (proxy, response) { var response = Ext.decode(response.responseText); console.log(response); response;});}, interval:" + interval + "});"
        

        #return self.execute_returned_ext(script)

    #End > Timed Tasks
    
    #START > Requests

    def log_request_exception(self, interval=None):
        print "log_request_exception locals: {locals}".format(locals=locals())
        #exceptionFunction = self.ajax_request_exception()
        #script = self.start_ext_taskmanager(exceptionFunction, str(10000))
        script = "Ext.TaskManager.start({ run: function() {Ext.data.proxy.Ajax.on('exception', function (proxy, response) { var response = Ext.decode(response.responseText); console.log(response); return response;});}, interval:500});"
        response = self.execute_returned_ext(script)
        print response
        #BuiltIn().pause_execution
        #BuiltIn().log_to_console(response)
        BuiltIn().log("This is the Ajax Exception Response - Failure Occured")
        BuiltIn().log(response)
        return response

    #End > Timed Tasks

