@echo off
echo Removing RustDesk silently...

:: Stop and kill all running RustDesk instances, force if needed and suppress all errors
taskkill /f /im RustDesk.exe >nul 2>&1

:: Use Windows Installer to Uninstall RustDesk silently
msiexec /x {F8D88AC9-C61E-4DDF-B7D8-B26FCF9EB0B3} /quiet /norestart

:: Wait 10 seconds
timeout /t 10 /nobreak >nul

:: Stop and delete RustDesk Windows Service
sc stop RustDesk >nul 2>&1
sc delete RustDesk >nul 2>&1

:: Force delete the RustDesk folders in Program Files and Program Files (x86)
rmdir /s /q "C:\Program Files\RustDesk" >nul 2>&1
rmdir /s /q "C:\Program Files (x86)\RustDesk" >nul 2>&1

:: Delete RustDesk folder in AppData\Roaming and AppData\Local for all user profiles
for /d %%i in (C:\Users\*) do (
  rmdir /s /q "%%i\AppData\Roaming\RustDesk" >nul 2>&1
  rmdir /s /q "%%i\AppData\Local\RustDesk" >nul 2>&1
)

:: Delete RustDesk folder in the Start Menu
rmdir /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\RustDesk" >nul 2>&1

:: Delete RustDesk shortcut in the Start Menu
del /q /f "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\RustDesk.lnk" >nul 2>&1

:: Delete RustDesk folder in ProgramData
rmdir /s /q "C:\ProgramData\RustDesk" >nul 2>&1

:: Remove any Desktop Shortcuts of RustDesk
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Desktop\RustDesk.lnk" >nul 2>&1
)

:: Wait 1 second
timeout /t 1 /nobreak >nul

:: Delete RustDesk files in user profile folders and files with *RustDesk as description
for /d %%i in (C:\Users\*) do (
  del /q /f "%%i\Downloads\*rustdesk*" >nul 2>&1
  del /q /f "%%i\Documents\*rustdesk*" >nul 2>&1
  del /q /f "%%i\Desktop\*rustdesk*" >nul 2>&1
)

:: Remove RustDesk Printer and suppress errors
printui /dl /n "RustDesk Printer" >nul 2>&1 || echo Failed to remove RustDesk Printer
