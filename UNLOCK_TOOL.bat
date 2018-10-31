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
:menu_1  Get_Slock.bin
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] This step is to be done FIRST
echo [*] If you reboot Phone Before Flahing TwRP
echo [*] You will Need to Start Over
echo.--------------------------------------------------------------------------------
echo.
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
files\mystery-binary1 fblock.txt slock.bin
files\fastboot.exe flash slock slock.bin 
echo.--------------------------------------------------------------------------------
echo [*] Slock file should have Been flashed, Now do menu step 2 
echo [*] To Flash TWRP on Device (on E-recovery)
echo.--------------------------------------------------------------------------------
echo.
timeout 5
color 0b	
cls
GOTO:EOF


:menu_2 Flash_custom_recovery         
cls
color 0b
echo.--------------------------------------------------------------------------------
echo [*] This step is to be done AFTER you flash SLOCK.bin 
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
echo First you must turn on ADB DEBUGGING in your settings 
echo go to device options then click on build number 7 times to enable 
echo developer options then in developer options turn on Enable adb option.
echo also make sure your drivers are installed 
echo.--------------------------------------------------------------------------------
pause
cls
echo.--------------------------------------------------------------------------------
echo [*] NOTE this will not work unless your fastboot drivers are installed
echo [*] 
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
files\adb.exe shell dd if=/dev/block/bootdevice/by-name/nvme of=/tmp/nvme
files\adb.exe pull /tmp/nvme
files\mystery-binary2 nvme nvme-patched
files\adb.exe push nvme-patched /tmp/nvme-patched
files\adb.exe shell dd if=/tmp/nvme-patched of=/dev/block/bootdevice/by-name/nvme
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
echo [*] Then it will copy that file into the Download folder.
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
files\adb.exe kill-server
files\adb.exe start-server
echo.--------------------------------------------------------------------------------
echo [*] Checking for attached devices, both adb or fastboot
files\adb.exe devices
timeout 5 > nul
files\fastboot.exe devices
timeout 3 > nul
files\adb.exe kill-server
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

