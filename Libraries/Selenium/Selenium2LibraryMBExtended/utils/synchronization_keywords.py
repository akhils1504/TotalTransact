from Selenium2Library import Selenium2Library


class _SynchronizationKeywords(Selenium2Library):
    spinner_locator = '//*[contains(@class, "spinner-layer")]'

    def mx_wait_for_spinners(self, timeout=None):
        self.wait_until_page_does_not_contain_element(self.spinner_locator, timeout)

    def _get_visible_item(self, locator):
        elements = self._element_finder.find(self._current_browser(), locator)
        for element in elements:
            if self._is_element_present(element) and self._is_visible(element):
                return element

    def _wait_and_get_visible_item(self, locator, timeout=None):
        error = "Element '%s' was not visible in %s" % (locator, self._format_timeout(timeout))
        self._wait_until(timeout, error, self._get_visible_item, locator)
        return self._get_visible_item(locator)

    def _wait_for_jquery(self):
        self.wait_for_condition("return Boolean(window.jQuery);")
