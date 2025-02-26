@echo off
echo Removing TeamViewer silently...

:: Check for administrator privileges
net session >nul 2>&1 || (echo Please run this script as an administrator & exit /b)

:: Force stop and kill all running TeamViewer processes and services, instances and executables, force if needed and suppress all errors
taskkill /f /im TeamViewer.exe >nul 2>&1
taskkill /f /im TeamViewer_Service.exe >nul 2>&1

:: Use Windows Installer Service to uninstall TeamViewer silently
powershell -command "Start-Process msiexec.exe -Wait -ArgumentList '/x \"TeamViewer_Full.msi\" /quiet'"

:: Additional silent uninstall commands
"C:\Program Files (x86)\TeamViewer\uninstall.exe" /S >nul 2>&1
"C:\Program Files\TeamViewer\uninstall.exe" /S >nul 2>&1

:: Delete the TeamViewer Windows Service
sc delete TeamViewer_Service >nul 2>&1
sc delete TeamViewer_Service_x86 >nul 2>&1

:: Wait 20 seconds
timeout /t 20 /nobreak >nul

:: Take ownership of folder AppData\Local\TeamViewer in all user profiles
for /d %%i in (C:\Users\*) do (
  if exist "%%i\AppData\Local\TeamViewer" (
    takeown /f "%%i\AppData\Local\TeamViewer" /r /d y >nul 2>&1
    icacls "%%i\AppData\Local\TeamViewer" /grant administrators:F /t >nul 2>&1
    del /q /f "%%i\AppData\Local\TeamViewer\*" >nul 2>&1
    rmdir /s /q "%%i\AppData\Local\TeamViewer" >nul 2>&1
  )
)

:: Take ownership of folder AppData\Roaming\TeamViewer in all user profiles
for /d %%i in (C:\Users\*) do (
  if exist "%%i\AppData\Roaming\TeamViewer" (
    takeown /f "%%i\AppData\Roaming\TeamViewer" /r /d y >nul 2>&1
    icacls "%%i\AppData\Roaming\TeamViewer" /grant administrators:F /t >nul 2>&1
    rmdir /s /q "%%i\AppData\Roaming\TeamViewer" >nul 2>&1
  )
)

:: Force delete the TeamViewer folders located in the Program Files and Program Files (x86) directories
rmdir /s /q "C:\Program Files\TeamViewer" >nul 2>&1
rmdir /s /q "C:\Program Files (x86)\TeamViewer" >nul 2>&1

:: Force delete the TeamViewer folder located at C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
rmdir /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TeamViewer" >nul 2>&1

:: Force delete the TeamViewer shortcut located at C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
del /q /f "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TeamViewer.lnk" >nul 2>&1

:: Force delete the TeamViewer folder located at C:\ProgramData\
rmdir /s /q "C:\ProgramData\TeamViewer" >nul 2>&1

:: Force delete any files containing TeamViewer in the description in all user profiles' downloads, documents, or desktop folders
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Downloads\*teamviewer*" >nul 2>&1
  del /q /f "%%i\Documents\*teamviewer*" >nul 2>&1
  del /q /f "%%i\Desktop\*teamviewer*" >nul 2>&1
)

:: Wait 2 seconds
timeout /t 2 /nobreak >nul

:: Use a .reg file to delete the registry key
echo Windows Registry Editor Version 5.00 > "%temp%\remove_teamviewer.reg"
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\TeamViewer] >> "%temp%\remove_teamviewer.reg"

:: Use a .reg file to delete all known TeamViewer registry entries
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer] >> "%temp%\remove_teamviewer.reg"
echo [-HKEY_CURRENT_USER\Software\TeamViewer] >> "%temp%\remove_teamviewer.reg"

:: Use a .reg file to delete TeamViewer Outlook add-in
echo [-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamViewerMeetingAddin.AddinModule] >> "%temp%\remove_teamviewer.reg"
echo [-HKEY_CURRENT_USER\Software\Microsoft\Office\Outlook\Addins\TeamViewerMeetingAddin.AddinModule] >> "%temp%\remove_teamviewer.reg"
regedit /s "%temp%\remove_teamviewer.reg"
del "%temp%\remove_teamviewer.reg"

:: Wait 2 seconds
timeout /t 2 /nobreak >nul

:: Remove any Desktop Shortcuts of TeamViewer
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Desktop\TeamViewer.lnk" >nul 2>&1
)

:: Remove TeamViewer Printer and suppress errors
printui /dl /n "TeamViewer Printer" >nul 2>&1 || echo Failed to remove TeamViewer Printer, continuing... >nul 2>&1

:: Remove TeamViewer VPN
net stop TeamViewerVPN >nul 2>&1
sc delete TeamViewerVPN >nul 2>&1
rmdir /s /q "C:\Program Files (x86)\TeamViewer\TeamViewer VPN" >nul 2>&1

echo TeamViewer and all associated components have been completely removed silently.
echo The window will close automatically.
timeout /t 5 /nobreak >nul
exit
