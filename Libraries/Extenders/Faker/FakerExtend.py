from robot.libraries.BuiltIn import BuiltIn

class FakerExtend:
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    selenium = ''
        
    def hello(self, name):
        print "Hello, %s!" % name
        
    def add_selenium_library_to_extmvc(self):
        self.selenium = BuiltIn().get_library_instance('SeleniumLibrary')
    
    
    #Basic Javascript Execution Script to wrap Ext In... 
    def execute_ext(self, script):
        return self.selenium.execute_javascript(script)
        
    
    #Wait for Ext Elements
    def wait_for_ext_condition(self, script):
        return self.selenium.wait_for_condition(script)


    #Conditions
    # .... @component - accounttypeformpanelscontainer
    # .... @timeout - 30 seconds
    #def wait_and_confirm_vivisible_condition(self, component, queryScope):
    #    return self.wait_for_ext_condition("["+ queryScope +"].query(" + component + ")[0].isVisible()" == true timeout=30 seconds error=None)

    
    #Form FIelds
    def set_textfield_value(self, itemId, value):
        return self.execute_ext("Ext.ComponentQuery.query('sharedtextfield#" + itemId + "{isVisible(true)}')[0].setValue('" + value + "')")
        
    def set_combobox_value(self, itemId, value):
        return self.execute_ext("Ext.ComponentQuery.query('combobox#" + itemId + "{isVisible(true)}')[0].setValue('" + value + "')")




    #Buttons
    def get_ext_button(self, itemid, queryScope):
        return self.execute_ext("["+ queryScope +"].query('button#" + itemid + "{isVisible(true)')[0]")

    def click_button(self,itemId, queryScope):
        button = self.get_ext_button(itemId, queryScope)
        return self.execute_ext(button + ".fireEvent('click'," +  button + ")")