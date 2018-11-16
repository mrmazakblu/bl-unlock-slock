if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
::visit https://t.me/huaweihax

::Set our Window Title
@title HUAWEI UNLOCK Tool V-3

::Set our default parameters
@echo off
color 0b
cd "%~dp0"
SET PATH=%PATH%;"%~dp0"
IF EXIST "%~dp0files" SET PATH=%PATH%;"%~dp0\files"
cls
echo(
echo(
cecho  {0c} ***************************************************{#}{\n}
cecho   *  {0E}   DO YOU WANT TO DOWNLOAD LATEST SCRIPT {#}      *{\n}
cecho   *  {06}   OR RUN CURRENT VERSION??  %ver%           {#}       *{\n}
cecho   {0c}***************************************************{#}{\n}
echo(
echo( 
CHOICE  /C 12 /M "   1=RUN  or   2=UPDATE"
IF ERRORLEVEL 2 GOTO update
IF ERRORLEVEL 1 GOTO run
:update
IF EXIST "%~dp0unlock-tool-update" rd /s /q "%~dp0unlock-tool-update" /Q
IF NOT EXIST "%~dp0unlock-tool-update" mkdir "%~dp0unlock-tool-update"
IF NOT EXIST "%~dp0update-logs" mkdir "%~dp0update-logs"
echo @echo off > %~dp0unlock-tool-update\unlock-tool-update.bat
echo( >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo timeout 10 >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo IF EXIST "%~dp0unlock-tool-update\bl-unlock-slock-master\files" rd /s /q "%~dp0files" /Q >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo IF EXIST %~dp0unlock-tool-update\bl-unlock-slock-master\files echo d ^| xcopy /Y /E /H  %~dp0unlock-tool-update\bl-unlock-slock-master\files %~dp0files >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo echo f ^| xcopy /Y %~dp0UNLOCK_TOOL.bat %~dp0UNLOCK_TOOL.bak >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo IF EXIST %~dp0unlock-tool-update\bl-unlock-slock-master\UNLOCK_TOOL.bat echo f ^| xcopy /Y %~dp0unlock-tool-update\bl-unlock-slock-master\UNLOCK_TOOL.bat %~dp0UNLOCK_TOOL.bat >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo timeout 5 >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo start %~dp0UNLOCK_TOOL.bat >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo timeout 2 >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo exit >> %~dp0unlock-tool-update\unlock-tool-update.bat
echo Downloading files from GitHub Repo
files\wget.exe -P %~dp0unlock-tool-update\ https://github.com/mrmazakblu/bl-unlock-slock/archive/master.zip 2> update-logs\tool-download-log.txt
%~dp0files\unzip.exe -u %~dp0unlock-tool-update\master.zip -d %~dp0unlock-tool-update\
start %~dp0unlock-tool-update\unlock-tool-update.bat
echo DONE WITH DOWNLOAD. EXITING NOW TO UPDATE THE FILES AND THIS SCRIPT
timeout 3
exit
:run
cls
echo(
echo(


:menuLOOP

	call:header
	::Print our header
	::call:header
	if %mode%=="DISCONNECTED-STATE" ( echo.-----------------------------------------------
		echo [***] PHONE NOT CONNECTED
		echo [***] Some Functions Will Fail )
	::Load up our menu selections
	echo.--------------------------------------------------------------------------------
	for /f "tokens=1,2,* delims=_ " %%A in ('"C:/Windows/system32/findstr.exe /b /c:":menu_" "%~f0""') do echo.  %%B  %%C
	
	call:printstatus

	set choice=
	echo.&set /p choice= Please make a selection or hit ENTER to exit: ||exit
	echo.&call:menu_%choice%
	
GOTO:menuLOOP
:menu_1  Slock
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] This step is to be done FIRST
echo [*] If you reboot Phone Before Flahing TwRP
echo [*] You will Need to Start Over
echo.--------------------------------------------------------------------------------
echo.
for /f "tokens=1,2,* delims=_ " %%A in ('"C:/Windows/system32/findstr.exe /b /c:":slock_" "%~f0""') do echo.  %%B  %%C
	set choice=
	echo.&set /p choice= Please make a selection or hit ENTER to return to last menu: ||GOTO:EOF
	echo.&call:slock_%choice%
color 0b	
cls
GOTO:EOF

:slock_1 GET_info
cls
if %mode%=="DISCONNECTED-STATE" ( echo.-----------------------------------------------
echo [**] This process will not work While phone shows not connected 
pause
GOTO:EOF )
if %mode%=="ADB" ( echo [*] REBOOTING TO BOOTLOADER
files\adb.exe reboot bootloader
echo.--------------------------------------------------------------------------------
echo [*] When Fastboot has loaded Press any key to continue
echo [*] 
echo.--------------------------------------------------------------------------------
echo.
pause )
files\fastboot.exe oem hwdog certify begin 2> fblock.txt
files\fastboot.exe oem get-product-model 2>> fblock.txt
timeout 3
if exist fblock.txt ( echo.--------------------------------------------------------------------------------
	echo [*] Now data has been pulled from phone. Send the fblock.txt
	echo [*] To telegram support group at https://t.me/huaweihax
	echo [*] Tag it with #niceguys. 
	echo [*] Leave phone in fastboot untill you get a response with slock.bin
	echo [*] You can leave from this menu
	echo [*] Return with Menu 1 "Slock" then when you have received the file
	echo [*] When You have the file received from support group
	echo [*] Copy that file "res" to same Directory as "fblock.txt" 
	echo [*] Then option 3 "FLASH_slock" Or Option 2 to convert if needed
	echo.-------------------------------------------------------------------------------- )
if not exist fblock.txt ( echo.--------------------------------------------------------------------------------
	echo [*] SOMETHING HAS GONE WRONG the fblock.txt was NOT FOUND
	echo [*] Restart the Step to see if it works
	echo.-------------------------------------------------------------------------------- )
echo.
pause
color 0b	
cls
GOTO:EOF

:slock_2 Convert Slock-txt_to_RES
cls
echo.--------------------------------------------------------------------------------
echo [*] When You receive the long string of characters (512 to be exact)
echo [*] from the niceguys at https://t.me/huaweihax copy it to a txt file in this 
echo [*] Folder %~dp0  
echo [*] Name the file "slock.txt"
echo.--------------------------------------------------------------------------------
echo.
pause
if exist slock.txt (
	type slock.txt | files/xxd.exe -r -p > res
	echo.--------------------------------------------------------------------------------
	echo [*] Now Run option 3 "FLASH_slock"
	echo.--------------------------------------------------------------------------------
) else (
	echo.--------------------------------------------------------------------------------
	echo [**] RES file not found. Make sure you copied code received from #niceguys)
	echo.--------------------------------------------------------------------------------
echo.
pause
color 0b	
cls
GOTO:EOF

:slock_3 FLASH_slock_RES
cls
if %mode%=="ADB" ( echo.--------------------------------------------------------------------------------
echo [*] Phone has been rebooted, Your code in no longer VALID 
echo [*] Start over with get-slock
echo.
pause 
GOTO:EOF )
if %mode%=="DISCONNECTED-STATE" ( echo.--------------------------------------------------------------------------------
echo [*] Phone NOT DETECTED, MAKE SURE CABLE IS CONNECTED, TRY AGAIN
echo.
pause 
GOTO:EOF )
echo.--------------------------------------------------------------------------------
echo [*] Now We flash the "res" file to slock. This will cause bootloader to be 
echo [*] Unlocked to allow twrp on erecovery.
echo.--------------------------------------------------------------------------------
echo.
pause
if exist res (
	files\fastboot.exe flash slock res 2> flash-slock-message.txt
	echo.--------------------------------------------------------------------------------
	echo [*] Slock file should have Been flashed, error checking hapens next. 
	echo [*] 
	echo.--------------------------------------------------------------------------------
) else (
	echo.--------------------------------------------------------------------------------
	echo [**] RES file not found. Make sure you copied received patched file from #niceguys
	echo [**] And placd it into same directory as the fblock.txt
	echo.--------------------------------------------------------------------------------
	pause
	GOTO:EOF )
echo.
pause
if not exist flash-slock-message.txt ( echo.--------------------------------------------------------------------------------
	echo [*] flash-slock-message.txt was NOT created for unknown reason. 
	echo [*] CANNOT VERIFY IF SLOCK was FLASHED
	echo [*] Flashing Recovery May Fail. Cannot determine at this time.
	echo [*] Return to last step again and FLASH-SLOCK Again
	pause
	GOTO:EOF )
set slock-status=""
for /f "tokens=1" %%A in ('"C:/Windows/system32/findstr.exe /b /i /c:"FAIL" "flash-slock-message.txt""') do set slock-status="%%A"
if %slock-status%=="" ( echo [*]--------------------------------------------------------------------
	echo [*] Fail message not found 
	set erecovery="slocked" )
::find /i "FAILED" "flash-slock-message.txt"
::if errorlevel 1 ( echo some bull-shit here )
pause
color 0b	
cls
GOTO:EOF


:menu_2 Flash_custom_recovery  MVNE       
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] This step is to be done ONLY AFTER you flash SLOCK.bin 
echo [*] If you reboot Phone Before Flahing TwRP
echo [*] You will Need to Start Over with step 1 Get-Slock.bin
echo [*] 
echo.--------------------------------------------------------------------------------
echo.
for /f "tokens=1,2,* delims=_ " %%A in ('"C:/Windows/system32/findstr.exe /b /c:":recovery_" "%~f0""') do echo.  %%B  %%C
	set choice=
	echo.&set /p choice= Please make a selection or hit ENTER to exit: ||GOTO:EOF
	echo.&call:recovery_%choice%
color 0b	
cls
GOTO:EOF


:recovery_1 Flash TwRP_on_erecovery
cls
color 0b
if %mode%=="DISCONNECTED-STATE" ( echo.--------------------------------------------------------------------------------
echo [*] Phone NOT DETECTED, MAKE SURE CABLE IS CONNECTED, TRY AGAIN
echo.
pause 
GOTO:EOF )
if %mode%=="ADB" ( echo.--------------------------------------------------------------------------------
echo [*] Phone has been rebooted, Your code in no longer VALID 
echo [*] Start over with get-slock
echo.
pause 
GOTO:EOF )
echo.--------------------------------------------------------------------------------
echo [*] Phone should already be in Fastboot Mode
echo [*] If It is Not Something has Gone Wrong And You Probably need to Start Over
echo [*] If you reboot Phone Before Flahing TwRP
echo [*] You will Need to Start Over with step 1 Get-Slock.bin
echo.--------------------------------------------------------------------------------
pause
cls
echo.--------------------------------------------------------------------------------
echo [*] press any key to continue the script.
echo.--------------------------------------------------------------------------------
pause > nul
if %erecovery%=="slocked" ( files\fastboot.exe flash erecovery_ramdisk files\TWRP_kirin.img
	timeout 5
	echo.--------------------------------------------------------------------------------
	echo [*] You must Boot to TWRP Manualy
	echo [*] Hold volume up AFTER the phone vibrates
	echo [*] Twrp should boot up. If not, reboot it and try it again
	echo.--------------------------------------------------------------------------------
	echo [*] Do NOT continue the modifying phone till mvne is edited
	echo [*] As long as twrp has booted, do 2,3,4 to modify mvne to unlock bootloader
	echo.--------------------------------------------------------------------------------
) else (
	echo [*] Slock Flashing HAS FAILED, YOU CANNOT FLASH RECOVERY YET
	echo [*] Try Again To Flash Slock, If fails Again YOU NEED TO START FROM BEGINNING )
pause
files\fastboot.exe reboot
color 0b	
pause
cls
GOTO:EOF


:recovery_2 Read mvne
echo.--------------------------------------------------------------------------------
echo [*] This part of tool MUST be done from TWRP (as root is needed)
echo.--------------------------------------------------------------------------------
pause
files\adb.exe shell dd if=/dev/block/bootdevice/by-name/nvme of=/tmp/nvme
files\adb.exe pull /tmp/nvme original-nvme
if exist original-nvme (
	files\dd.exe if=original-nvme of=modified-nvme
) else (
	echo [**] NVME file not found. Make sure twrp is loaded and adb is working )
pause
cls
GOTO:EOF

:recovery_3 Modify mvne
echo.--------------------------------------------------------------------------------
echo [*] This part of tool requires only the tool itself
echo.--------------------------------------------------------------------------------
pause
if exist modified-nvme (
	call files\JREPL.BAT "\x46\x42\x4C\x4F\x43\x4B\x00\x00\x01\x00\x00\x00\x01" "\x46\x42\x4C\x4F\x43\x4B\x00\x00\x01\x00\x00\x00\x00" /m /x /f modified-nvme /o -
) else (
	echo [**] NVME file not found. Make sure You performed Step 2 First)
pause
cls
GOTO:EOF

:recovery_4 Flash Modifyed_mvne
echo.--------------------------------------------------------------------------------
echo [*] This part of tool requires to be done from TWRP (as root is needed)
echo.--------------------------------------------------------------------------------
pause
if exist modified-nvme (
	files\adb.exe push modified-nvme /tmp/modified-nvme
	files\adb.exe shell dd if=/tmp/modified-nvme of=/dev/block/bootdevice/by-name/nvme
) else (
	echo [**] NVME file not found. Make sure twrp is loaded and adb is working)
pause
cls
GOTO:EOF

:recovery_5 Flash TWRP(optional)_ONLY-AFTER-#4-IS-DONE 
cls
color 0b
echo.--------------------------------------------------------------------------------
echo First you must turn on ADB DEBUGGING in your settings 
echo go to device options then click on build number 7 times to enable 
echo developer options then in developer options turn on Enable adb option.
echo also make sure your drivers are installed 
echo.--------------------------------------------------------------------------------
pause
cls
files\adb.exe reboot bootloader
cls
echo.--------------------------------------------------------------------------------
echo [*] NOTE this will not work unless your fastboot drivers are installed
echo [*] Once the screen says fastboot
echo [*] press any key to continue the script.
echo.--------------------------------------------------------------------------------
pause > nul
files\fastboot.exe flash recovery_ramdisk files\TWRP_kirin.img
timeout 5
echo.--------------------------------------------------------------------------------
pause
files\fastboot.exe reboot
color 0b	
cls
GOTO:EOF

:menu_3 Root        
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] Magisk can Simply be flashed in TwrP
echo [*] If You prefer to patch ramdisk instead, This can Help. (if needed)
echo.--------------------------------------------------------------------------------
echo.
for /f "tokens=1,2,* delims=_ " %%A in ('"C:/Windows/system32/findstr.exe /b /c:":root_" "%~f0""') do echo.  %%B  %%C
	set choice=
	echo.&set /p choice= Please make a selection then hit ENTER:
	echo.&call:root_%choice%
color 0b	
cls
GOTO:EOF

:root_1 Pull_ramdisk_with_twrp 
cls
color 0b
echo [*] This step will reboot into TWRP (IF INSTALLED)and Copy the currently
echo [*] Instaled ramdisk to your pc, then reboot back to Android
echo [*] Then it will copy that file back into the Download folder.
echo [*] From inside android you will use the magisk manager to "patch" it.
echo.--------------------------------------------------------------------------------
files\adb.exe reboot recovery
echo [*] Press any key to continue ONLY when twrp has loaded
pause 
files\adb.exe shell dd if=/dev/block/bootdevice/by-name/ramdisk of=/tmp/ramdisk
files\adb.exe pull /tmp/ramdisk current-ramdisk.img
files\adb.exe reboot
echo [*] Press any key to continue ONLY when Device has loaded
pause 
files\adb.exe push current-ramdisk.img /sdcard/Download
timeout 3 > nul
GOTO:EOF

:root_2 Download_Magisk
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] You should get latest release of the magisk manager.
echo [*] A new internet tab/ Window should open next on your PC
echo [*] For you to Download the magisk manager
echo [*] Download and install on device
echo [*] Run the app and select to install root. select patch only.
echo [*] When done Run Step 3
timeout 5 > nul
rundll32 url.dll,FileProtocolHandler https://github.com/topjohnwu/Magisk/releases
GOTO:EOF

:root_3 Pull_and _flash-patched_ramdisk
cls
color 0b
echo.--------------------------------------------------------------------------------
files\adb.exe pull /sdcard/Download/patched_boot.img
timeout 4 > nul
if exist patched_boot.img (
	files\adb.exe reboot bootloader
	files\fastboot.exe devices
	files\fastboot.exe flash ramdisk patched_boot.img
	files\fastboot.exe reboot
	timeout 3 > nul
	GOTO:EOF
) else (
	echo [*] Patched_boot.img not found
	timeout 3 > nul
	GOTO:EOF)

:header  
cls        
color 0e
echo.          
echo           """"""""""""""""""""""""""""""""""""""""""""""""""""""          
echo           " ______ _         _   _                          _  "
echo           " | ___ (_)       | | | |                        (_) "
echo           " | |_/ /_  __ _  | |_| |_   _  __ ___      _____ _  "
echo           " | ___ \ |/ _` | |  _  | | | |/ _` \ \ /\ / / _ \ | "
echo           " | |_/ / | (_| | | | | | |_| | (_| |\ V  V /  __/ | "
echo           " \____/|_|\__, | \_| |_/\__,_|\__,_| \_/\_/ \___|_| "
echo           "           __/ |                                    "
echo           "          |___/                                     "
echo           "          _____           _       _ _               "
echo           "         |  ___|         | |     (_) |              "
echo           "         | |____  ___ __ | | ___  _| |_ ___         "
echo           "         |  __\ \/ / '_ \| |/ _ \| | __/ __|        "
echo           "         | |___>  <| |_) | | (_) | | |_\__ \        "
echo           "         \____/_/\_\ .__/|_|\___/|_|\__|___/        "
echo           "                   | |                              "
echo           "                   |_|                              "
echo           """"""""""""""""""""""""""""""""""""""""""""""""""""""
echo.--------------------------------------------------------------------------------
echo.
echo [*] Force restarting the adb server. Just in case it might be needed
files\adb.exe kill-server
files\adb.exe start-server
echo.--------------------------------------------------------------------------------
set mode="DISCONNECTED-STATE"
echo [*] Checking for attached devices with adb (inside android)
for /f "skip=1 tokens=*" %%i in ('files\adb.exe devices') do set mode="ADB"
timeout 3
echo [*] Now Checking for attached devices with fastboot (inside bootloader)
for /f "tokens=*" %%i in ('files\fastboot.exe devices') do set mode="FASTBOOT"
timeout 3
cls	
files\adb.exe kill-server
color 0b
GOTO:EOF

:printstatus
echo. 
echo.--------------------------------------------------------------------------------
echo. [*]Phone is Currently IN %mode%
echo. [*]Running From %~dp0
echo. 
echo. [**]CHOOSE OPTION TO RUN
echo.--------------------------------------------------------------------------------
GOTO:EOF

