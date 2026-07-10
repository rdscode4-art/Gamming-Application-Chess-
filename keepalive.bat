@echo off
:loop
adb reverse tcp:7893 tcp:7893 >nul 2>&1
timeout /t 5 /nobreak >nul
goto loop
