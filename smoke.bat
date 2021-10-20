set PYTHONPATH=^
C:\Users\akhil.kumar\Perforce\akhil.kumar_TRV-LT-AKHILK_9539\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/Environments;^
C:\Users\akhil.kumar\Perforce\akhil.kumar_TRV-LT-AKHILK_9539\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/Util;^
C:\Users\akhil.kumar\Perforce\akhil.kumar_TRV-LT-AKHILK_9539\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/Extenders/Faker;^
C:\Users\akhil.kumar\Perforce\akhil.kumar_TRV-LT-AKHILK_9539\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/UI/Ext/MVC;



call robot -i Smoke -T -d Results Headless\AdminPortal.robot
call robot -i Smoke -T -d Results Headless\PaymentPortal.robot
call robot -i Smoke -T -d Results Headless\DHL.robot



