pushd C:\p4\TotalTransact\Robot\sbps\main\TotalTransact
set PYTHONPATH=^
C:\p4\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/Environments;^
C:\p4\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/Util;^
C:\p4\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/Extenders/Faker;^
C:\p4\TotalTransact\Robot\sbps\main\TotalTransact/Libraries/UI/Ext/MVC;
rem  --variable url:http://bob-sbps-local.netdeposit.com ^
rem  --variable url:http://localhost:8084 ^
rem --variable testServer:AzureDevint ^
rem --variable enable_burp_proxy:true ^

python -m robot ^
--console verbose ^
TestCases\Headless
start log.html
popd