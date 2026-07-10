@echo off
echo ====================================================
echo Opening Windows Firewall for Chess App (Port 7893)
echo ====================================================
netsh advfirewall firewall add rule name="Allow Chess Backend" dir=in action=allow protocol=TCP localport=7893
echo.
echo Firewall rule added! 
echo Now multiple devices on Wi-Fi can connect to the app!
echo.
pause
