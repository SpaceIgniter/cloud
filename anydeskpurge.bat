@echo off
echo Removing AnyDesk silently...

:: Check for administrator privileges
net session >nul 2>&1 || (echo Please run this script as an administrator & exit /b)

:: Stop and kill all running AnyDesk instances, force if needed and suppress all errors
taskkill /f /im AnyDesk.exe >nul 2>&1

:: Use Windows Installer Service to uninstall AnyDesk silently
powershell -command "Start-Process msiexec.exe -Wait -ArgumentList '/x \"AnyDesk.msi\" /quiet'"

:: Uninstall AnyDesk silently
"C:\Program Files (x86)\AnyDesk\AnyDesk.exe" --silent --remove >nul 2>&1
"C:\Program Files\AnyDesk\AnyDesk.exe" --silent --remove >nul 2>&1

:: Wait 20 seconds
timeout /t 20 /nobreak >nul

:: Stop and delete the AnyDesk Windows Service
sc stop AnyDesk_Service >nul 2>&1
sc delete AnyDesk_Service >nul 2>&1

:: Delete the entire AnyDesk folder located in Program Files or Program Files (x86)
rmdir /s /q "C:\Program Files\AnyDesk" >nul 2>&1
rmdir /s /q "C:\Program Files (x86)\AnyDesk" >nul 2>&1

:: Delete the AnyDesk folder located at C:\ProgramData\Microsoft\Windows\Start Menu\Programs
rmdir /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AnyDesk" >nul 2>&1

:: Delete the AnyDesk folder located at C:\ProgramData
rmdir /s /q "C:\ProgramData\AnyDesk" >nul 2>&1

:: Delete the AnyDesk folder located in users' AppData\Roaming
for /d %%i in (C:\Users\*) do (
  rmdir /s /q "%%i\AppData\Roaming\AnyDesk" >nul 2>&1
)

:: Delete the gcapi.dll file located in any user profile downloads, documents, or desktop folder
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Downloads\gcapi.dll" >nul 2>&1
  del /q /f "%%i\Documents\gcapi.dll" >nul 2>&1
  del /q /f "%%i\Desktop\gcapi.dll" >nul 2>&1
)

:: Delete the file: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\AnyDesk.lnk
del /q /f "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\AnyDesk.lnk" >nul 2>&1

:: Wait 2 seconds
timeout /t 2 /nobreak >nul

:: Remove any Desktop Shortcuts of AnyDesk
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Desktop\AnyDesk.lnk" >nul 2>&1
)

:: Force delete any files containing AnyDesk in the description in all users' profiles downloads, documents, or desktop folder
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Downloads\*AnyDesk*" >nul 2>&1
  del /q /f "%%i\Documents\*AnyDesk*" >nul 2>&1
  del /q /f "%%i\Desktop\*AnyDesk*" >nul 2>&1
)

:: Use a .reg file to force remove these registry entries
echo Windows Registry Editor Version 5.00 > "%temp%\remove_anydesk.reg"
echo [-HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store] >> "%temp%\remove_anydesk.reg"
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\AnyDesk] >> "%temp%\remove_anydesk.reg"
echo [-HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules] >> "%temp%\remove_anydesk.reg"
echo [-HKEY_LOCAL_MACHINE\Software\RegisteredApplications] >> "%temp%\remove_anydesk.reg"
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Clients\Media\AnyDesk\Capabilities] >> "%temp%\remove_anydesk.reg"
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Clients\Media\AnyDesk] >> "%temp%\remove_anydesk.reg"
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\AnyDesk] >> "%temp%\remove_anydesk.reg"
regedit /s "%temp%\remove_anydesk.reg"
del "%temp%\remove_anydesk.reg"

:: Remove the AnyDesk Printer and attempt to suppress any printer error messages
printui /dl /n "AnyDesk Printer" >nul 2>&1 || echo Failed to remove AnyDesk Printer, continuing... >nul 2>&1

echo AnyDesk and all associated components have been completely removed silently.
echo The window will close automatically.
timeout /t 5 /nobreak >nul
exit
