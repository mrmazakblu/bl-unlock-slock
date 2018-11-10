if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
::visit https://t.me/huaweihax

::Set our Window Title
@title HUAWEI UNLOCK Tool

::Set our default parameters
@echo off
color 0b



:menuLOOP

	call:header
	::Print our header
	::call:header
	
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
files\adb.exe reboot bootloader
echo.--------------------------------------------------------------------------------
echo [*] When Fastboot has loaded Press any key to continue
echo [*] 
echo.--------------------------------------------------------------------------------
echo.
pause
files\fastboot.exe oem hwdog certify begin 2> fblock.txt
files\fastboot.exe oem get-product-model 2>> fblock.txt
:: convert fblock.txt and model into 512 byte file signed with rsa key
:: This part just waiting on process to add key to fblock >> to slock.txt
::type slock.txt | files/xxd.exe -r -p > binary-slock 
::files\fastboot.exe flash slock binary-slock
echo.--------------------------------------------------------------------------------
::echo [*] Slock file should have Been flashed, Now do menu step 2 
::echo [*] To Flash TWRP on Device (on E-recovery)
echo [*] Now data has been pulled from phone. Send the fblock.txt
echo [*] To telegram support group at https://t.me/huaweihax
echo [*] Tag it with #niceguys. 
echo [*] Leave phone in fastboot untill you get a response with slock.bin
echo [*] You can leave from this menu
echo [*] You can Return to Menu 1 "Slock" then "Flash_slock" when you have received the file
echo [*] When You have the file received from support group (file name likely named "res")
echo [*] Copy that file to same Directory as "fblock.txt" and select option 1 "slock" 
echo [*] Then option 2 "FLASH_slock"
echo.--------------------------------------------------------------------------------
echo.
pause
color 0b	
cls
GOTO:EOF

:slock_2 FLASH_slock
cls
echo.--------------------------------------------------------------------------------
echo [*] Now We flash the "res" file to slock. This will cause bootloader to be 
echo [*] Unlocked to allow twrp on erecovery.
echo.--------------------------------------------------------------------------------
echo.
pause
if exist res (
	files\fastboot.exe flash slock res
	echo.--------------------------------------------------------------------------------
	echo [*] Slock file should have Been flashed, Now do menu step 2 
	echo [*] To Flash TWRP on Device (on E-recovery)
	echo.--------------------------------------------------------------------------------
) else (
	echo.--------------------------------------------------------------------------------
	echo [**] RES file not found. Make sure you copied received patched file from #niceguys
	echo [**] And placd it into same directory as the fblock.txt)
	echo.--------------------------------------------------------------------------------
echo.
pause
color 0b	
cls
GOTO:EOF


:menu_2 Flash_custom_recovery         
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] This step is to be done AFTER you flash SLOCK.bin 
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
files\fastboot.exe flash erecovery_ramdisk files\TWRP_kirin.img
timeout 5
echo.--------------------------------------------------------------------------------
echo [*] You must Boot to TWRP Manualy
echo [*] Hold volume up AFTER the phone vibrates
echo [*] Twrp should boot up. If not, reboot it and try 3d again
echo.--------------------------------------------------------------------------------
pause
files\fastboot.exe reboot
color 0b	
echo.--------------------------------------------------------------------------------
echo [*] Do NOT continue the script until TWRP is booted
echo.--------------------------------------------------------------------------------
pause
echo.--------------------------------------------------------------------------------
echo [*] As long as twrp has booted, next run 1.5 to modify mvne to unlock bootloader
echo.--------------------------------------------------------------------------------
pause
cls
GOTO:EOF


:recovery_1.5 Read modify-reflash_mvne
echo.--------------------------------------------------------------------------------
echo [*] This part of tool requires to be done from TWRP (as root is needed)
echo.--------------------------------------------------------------------------------
pause
files\adb.exe shell dd if=/dev/block/bootdevice/by-name/nvme of=/tmp/nvme
files\adb.exe pull /tmp/nvme original-nvme
if exist original-nvme (
	files\dd.exe if=original-nvme of=modified-nvme
	call files\nvme-edit.bat
	files\adb.exe push modified-nvme /tmp/modified-nvme
	files\adb.exe shell dd if=/tmp/modified-nvme of=/dev/block/bootdevice/by-name/nvme
) else (
	echo [**] NVME file not found. Make sure twrp is loaded and adb is working)
pause
cls
GOTO:EOF

:recovery_2 Flash TWRP(optional)_ONLY-AFTER-#1-IS-DONE 
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
echo           """""""""""""""""""""""""""""""""""""""""""""""""""""          
echo           "______ _         _   _                          _  "
echo           "| ___ (_)       | | | |                        (_) "
echo           "| |_/ /_  __ _  | |_| |_   _  __ ___      _____ _  "
echo           "| ___ \ |/ _` | |  _  | | | |/ _` \ \ /\ / / _ \ | "
echo           "| |_/ / | (_| | | | | | |_| | (_| |\ V  V /  __/ | "
echo           "\____/|_|\__, | \_| |_/\__,_|\__,_| \_/\_/ \___|_| "
echo           "          __/ |                                    "
echo           "         |___/                                     "
echo           "         _____           _       _ _               "
echo           "        |  ___|         | |     (_) |              "
echo           "        | |____  ___ __ | | ___  _| |_ ___         "
echo           "        |  __\ \/ / '_ \| |/ _ \| | __/ __|        "
echo           "        | |___>  <| |_) | | (_) | | |_\__ \        "
echo           "        \____/_/\_\ .__/|_|\___/|_|\__|___/        "
echo           "                  | |                              "
echo           "                  |_|                              "
echo           """""""""""""""""""""""""""""""""""""""""""""""""""""
echo.--------------------------------------------------------------------------------
echo.
echo [*] Force restarting the adb server. Just in case it might be needed
files\adb.exe kill-server
files\adb.exe start-server
echo.--------------------------------------------------------------------------------
echo [*] Checking for attached devices with adb (inside android)
files\adb.exe devices
timeout 3 > nul
echo [*] Now Checking for attached devices with fastboot (inside bootloader)
files\fastboot.exe devices
timeout 3 > nul
cls	
color 0b
GOTO:EOF

:printstatus
echo.
echo. CHOOSE OPTION TO RUN
echo. 
echo.
echo.--------------------------------------------------------------------------------
GOTO:EOF

