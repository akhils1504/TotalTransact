

class TotaltUtilities:

    def create_proxied_ff_profile(self):
        from selenium import webdriver
        fp =webdriver.FirefoxProfile()
        fp.set_preference("network.proxy.http", "127.0.0.1")
        fp.set_preference("network.proxy.http_port", 8080)
        fp.set_preference("network.proxy.ssl", "127.0.0.1")
        fp.set_preference("network.proxy.ssl_port", 8080)
        fp.set_preference("network.proxy.type", 1)
        # the following sets the download folder
        # fp.set_preference("browser.download.folderList",2)
        # fp.set_preference("browser.download.manager.showWhenStarting",False)
        # fp.set_preference("browser.download.dir",path)
        # fp.set_preference("browser.helperApps.neverAsk.saveToDisk",'application/csv')
        fp.update_preferences()
        return fp.path

