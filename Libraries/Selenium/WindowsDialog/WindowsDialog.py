from time import sleep, clock

from selenium.webdriver import DesiredCapabilities

from Libraries.Selenium import SeleniumGroup
import os.path

try:
    from pywinauto import Application, MatchError
    from pywinauto.timings import TimeoutError
except ImportError:
    Application = None
    MatchError = None
    TimeoutError = None


class WindowsDialog(SeleniumGroup):
    """
    Library with keywords for downloading and uploading files.
    Library Selenium2LibraryMBExtended must be loaded prior to WindowsDialog.
    This library works only under Windows OS.

    This library is part of the ${fusionresource}

    Examples:
    | Library | Selenium2LibraryMBExtended |
    | Resource | ${fusionresource} |

    | Library | Selenium2LibraryMBExtended |
    | Library | WindowsDialog |
    """
    def mx_open_file(self, file_path):
        """
        Uploads the file. For this keyword, native upload window must be opened.
        | Mx Open File | ${CURDIR}\\\\workspace.zip |
        """
        if Application is None:
            raise AssertionError("This keyword is supported on Windows platform only.")
        app = Application()
        open_file_dialog = self._get_open_file_dialog(app)
        open_file_dialog.Edit.SetText(file_path)
        sleep(1)
        open_file_dialog.Open.ClickInput()

    def mx_save_file(self, file_path):
        """
        Downloads the file. For this keyword, native download window must be opened.
        | Mx Save File | ${CURDIR}\\\\workspace.zip |
        """
        if Application is None:
            raise AssertionError("This keyword is supported on Windows platform only.")
        self._save_file(file_path)

    def mx_is_save_file_window_visible(self):
        if Application is None:
            raise AssertionError("This keyword is supported on Windows platform only.")
        app = Application()
        browser_name = self.seleniumlib._current_browser().name
        if browser_name == DesiredCapabilities.INTERNETEXPLORER['browserName']:
            ieframe = app.IEFrame
            try:
                ieframe.FrameNotificationBar.Wait('visible')
            except TimeoutError:
                self.seleniumlib._log("Save file notification window is not visible")
                raise
        else:
            raise AssertionError("This keyword is supported on Internet Explorer browser only.")

    def _save_file(self, file_path):
        app = Application()
        browser_name = self.seleniumlib._current_browser().name
        if browser_name == DesiredCapabilities.INTERNETEXPLORER['browserName']:
            ieframe = app.IEFrame
            ieframe.FrameNotificationBar.ClickInput()
            ieframe.TypeKeys('%n')
            ieframe.TypeKeys('{TAB}')
            ieframe.TypeKeys('{DOWN 2}')
            ieframe.TypeKeys("{ENTER}")
        save_file_dialog = self._get_save_file_dialog(app)
        save_file_dialog.Edit.SetText(file_path)
        sleep(1)
        save_file_dialog.Save.ClickInput()
        self._wait_for_file(file_path)

    def _wait_for_file(self, file_path):
        t0 = clock()
        while not os.path.exists(file_path):
            t1 = clock()
            if t1 - t0 > self.seleniumlib.get_selenium_timeout():
                raise AssertionError("Could not find file under the path: {}. Waited {}".format(
                    file_path,
                    self.seleniumlib.get_selenium_timeout()
                ))

    def mx_delete_file_if_exists_and_save_file(self, file_path):
        """
        Deletes the file before saving new one.
        | Mx Delete File If Exists And Save File | ${CURDIR}\\\\workspace.zip |
        """
        if Application is None:
            raise AssertionError("This keyword is supported on Windows platform only.")
        if os.path.isfile(file_path):
            os.remove(file_path)
        self._save_file(file_path)

    def _get_save_file_dialog(self, app):
        browser_name = self.seleniumlib._current_browser().name
        if browser_name == DesiredCapabilities.FIREFOX['browserName']:
            try:
                save_file_dialog = app.EnterNameOfFileToSaveTo
            except MatchError as e_en:
                try:
                    save_file_dialog = app.ZapiszJako
                except MatchError as e_pl:
                    raise Exception(e_en, e_pl)
        else:
            save_file_dialog = app.SaveAs
        return save_file_dialog

    def _get_open_file_dialog(self, app):
        browser_name = self.seleniumlib._current_browser().name
        if browser_name == DesiredCapabilities.CHROME['browserName']:
            open_file_dialog = app.Open
        elif browser_name == DesiredCapabilities.INTERNETEXPLORER['browserName']:
            open_file_dialog = app.ChooseFileToUpload
        elif browser_name == DesiredCapabilities.FIREFOX['browserName']:
            try:
                open_file_dialog = app.FileUpload
            except MatchError as e_en:
                try:
                    open_file_dialog = app.WysylaniePliku
                except MatchError as e_pl:
                    raise Exception(e_en, e_pl)
        else:
            raise Exception("Uploading for browser: {} is not supported.".format(browser_name))
        return open_file_dialog
