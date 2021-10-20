import inspect
from time import sleep

import wrapt
from selenium.common.exceptions import StaleElementReferenceException
from selenium import webdriver


from selenium.webdriver import ActionChains
from Selenium2Library import Selenium2Library
from Libraries.Selenium.Selenium2LibraryMBExtended.utils import _SynchronizationKeywords
import webdrivermonkeypatches
from robot.libraries.BuiltIn import BuiltIn

__version__ = "1.1"


@wrapt.decorator
def _return_if_question_mark(wrapped, instance, args, kwargs):
    if '?' in args or '?' in kwargs.values():
        print "Value '?' found in arguments, returning from keyword!"
        return
    return wrapped(*args, **kwargs)


@wrapt.decorator
def _rerun_on_defined_exceptions(wrapped, instance, args, kwargs):
    try:
        return wrapped(*args, **kwargs)
    except StaleElementReferenceException:
        sleep(0.5)
        return wrapped(*args, **kwargs)


class Selenium2LibraryMBExtended(
    _SynchronizationKeywords,
):
    __doc__ = Selenium2Library.__doc__

    def __init__(self, timeout=5.0, implicit_wait=0.0, run_on_failure='Capture Page Screenshot',
                 screenshot_root_directory=None, data_driven=False, safe_mode=True):
        self.data_driven = data_driven
        self.safe_mode = safe_mode
        Selenium2Library.__init__(self, timeout, implicit_wait, run_on_failure, screenshot_root_directory)

        self._element_finder._strategies['qa-id'] = self._mx_qa_id_strategy

        if self.data_driven:
            self._decorate_all_unbound_methods(_return_if_question_mark, Selenium2LibraryMBExtended)
        if self.safe_mode:
            self._decorate_all_unbound_methods(_rerun_on_defined_exceptions, Selenium2LibraryMBExtended)

    def _mx_qa_id_strategy(self, browser, criteria, tag, constraints):
        xpath = "//*[@qa-id='{}']".format(criteria)
        return self._element_finder._filter_elements(
            browser.find_elements_by_xpath(xpath),
            tag, constraints)

    def _decorate_all_unbound_methods(self, decorator, cls):
        for name, method in inspect.getmembers(cls, inspect.ismethod):
            if not name.startswith('_'):
                setattr(cls, name, decorator(method))

    def move_to_element_with_offset(self, locator, x_offset, y_offset):
        self._info("Simulating Mouse Over on element with offset '%s'" % locator)
        element = self._element_find(locator, True, False)
        if element is None:
            raise AssertionError("ERROR: Element %s not found." % locator)
        ActionChains(self._current_browser()) \
            .move_to_element_with_offset(element, x_offset, y_offset) \
            .perform()

    def draw_rectangle_over_element(self, locator, source_x_offset, source_y_offset, width, height):
        element = self._element_find(locator, True, False)
        target_x_offset = int(source_x_offset) + int(width)
        target_y_offset = int(source_y_offset) + int(height)
        if element is None:
            raise AssertionError("ERROR: Element %s not found." % locator)
        ActionChains(self._current_browser()) \
            .move_to_element_with_offset(element, source_x_offset, source_y_offset) \
            .click_and_hold() \
            .move_to_element_with_offset(element, target_x_offset, target_y_offset) \
            .release() \
            .perform()

    def log_source(self, loglevel='NONE'):
        pass
    
    def create_firefox_webdriver_with_proxy(self, proxy_host, proxy_port):
        """
        Creates an instance of a Firefox WebDriver with a certain proxy.
        Examples:
        | Create Firefox Webdriver With Proxy | localhost | 8080 |
        """
        fp = webdriver.FirefoxProfile()
        fp.set_preference("network.proxy.type", 1)
        fp.set_preference("network.proxy.http", proxy_host)
        fp.set_preference("network.proxy.http_port", int(proxy_port))
        fp.update_preferences()
        driver = webdriver.Firefox(firefox_profile=fp)
        return self._cache.register(driver)
    
    def mx_confirm_action(self):
        """
        Confirm new dialog box.
        """
        variables = BuiltIn().get_variables()
        if '${VER_EXT}' in variables:
            version = variables.get('${VER_EXT}')
            if version.startswith("0."):
                self.confirm_action()
            else:
                self.wait_until_element_is_visible("xpath=//md-dialog-content")
                if self._is_visible("xpath=//button/*[contains(text(), 'Yes')]"):
                    self.click_element("xpath=//button/*[contains(text(), 'Yes')]")
                elif self._is_visible("xpath=//button/*[contains(text(), 'Ok')]"):
                    self.click_element("xpath=//button/*[contains(text(), 'Ok')]")
                else:
                    self._info("No proper button. Expect 'Ok' or 'Yes'.")
        else:
            self._info("VER_EXT not defined. Using standard 'confirm action'.")
            self.confirm_action()

    def mx_textfield_should_contain(self, locator, expected, message=''):
        """Verifies text field identified by `locator` contains text `expected`.

        `message` can be used to override default error message.

        Key attributes for text fields are `id` and `name`. See `introduction`
        for details about locating elements.
        """

        actual = (self._get_value(locator, 'text field')).encode('utf8')
        if not expected in actual.decode('utf8'):
            if not message:
                message = "Text field '%s' should have contained text '%s' " \
                          "but it contained '%s'" % (locator, expected, actual.decode('utf8'))
            raise AssertionError(message)
        self._info("Text field '%s' contains text '%s'." % (locator, expected))