@echo off
:: Run as Administrator: right-click -> Run as administrator
:: Restarts Jenkins so global credential dockerhub-credentials is loaded from JENKINS_HOME.
net stop Jenkins
timeout /t 5 /nobreak >nul
net start Jenkins
echo.
echo Jenkins restarted. Open http://localhost:8080 and run Build Now on job Construction.
pause
