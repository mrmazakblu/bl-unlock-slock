#!/bin/bash

clear
chmod a+x ./Unlock-tool.sh
chmod a+x ./files/*
ADB="./files/adblinux"
FASTBOOT="./files/fastbootlinux"
function fast_check() {
$ADB kill-server
$ADB start-server
$ADB devices -l > working/adb_devices.txt
sleep 5
if grep -q "product:" "working/adb_devices.txt"; then
	echo adb device found
	$ADB reboot bootloader
	echo sleeping 20 seconds To allow device to reboot in BOOTLOADER
	sleep 20
fi
sudo $FASTBOOT devices -l > working/fast_devices.txt
sleep 5
if grep -q "fastboot" "working/fast_devices.txt"; then
	echo fastboot detected
	return
else
	echo "No Fastboot devices found "
	echo "No Fastboot devices found "
	echo "press enter to exit"
	read \n
	bash ./Unlock-tool.sh
	exit
fi
}
echo   """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo             """"""""""""""""""""""""""""""""""""""""""""""""""""""
echo             " ______ _         _   _                          _  "
echo             " | ___ (_)       | | | |                        (_) "
echo             " | |_/ /_  __ _  | |_| |_   _  __ ___      _____ _  "
echo             " | ___ \ |/ _' | |  _  | | | |/ _' \ \ /\ / / _ \ | "
echo             " | |_/ / | (_| | | | | | |_| | (_| |\ V  V /  __/ | "
echo             " \____/|_|\__, | \_| |_/\__,_|\__,_| \_/\_/ \___|_| "
echo             "           __/ |                                    "
echo             "          |___/                                     "
echo             "          _____           _       _ _               "
echo             "         |  ___|         | |     (_) |              "
echo             "         | |____  ___ __ | | ___  _| |_ ___         "
echo             "         |  __\ \/ / '_ \| |/ _ \| | __/ __|        "
echo             "         | |___>  <| |_) | | (_) | | |_\__ \        "
echo             "         \____/_/\_\ .__/|_|\___/|_|\__|___/        "
echo             "                   | |                              "
echo             "                   |_|                              "
echo             """"""""""""""""""""""""""""""""""""""""""""""""""""""
echo   """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "----------------------------------------------------------------------------"
PS3='Please enter your choice number: '
options=("Get HW Certify Code 1" "Convert TXT string To Bin 2" "Flash Slock Bin 3" "Flash TWRP 4" "Read MVNE 5" "Convert MVNE 6" "Flash MVNE 7" "finished 8")
select opt in "${options[@]}"
	do
		case $opt in
			"Get HW Certify Code 1")
				fast_check
				sudo $FASTBOOT oem hwdog certify begin 2> "./working/fblock.txt"
				sudo $FASTBOOT oem get-product-model 2>> "./working/fblock.txt"
				sudo $FASTBOOT oem get-build-number 2>> "./working/fblock.txt"
				echo -e "\e[1;31m Share the file fblock.txt in the folder working with telegram group \e[0m"
				echo -e "\e[1;30m Wait for received file, DO NOT power off or reboot device \e[0m"
				echo -e "\e[1;32m If you do the code received will not work \e[0m"
				echo "press enter to Return To Menu"
					read \n
				bash ./Unlock-tool.sh
				exit
			;;
			"Convert TXT string To Bin 2")
				echo "If Received Slock file From telegram group is Long list on numbers, letters"
				echo "Continue this step"
				echo "copy the received long string as new file named slock.txt"
				echo "Save the file in the working directory"
				echo "If the received file is already a *.bin, then skip. Close sh and reopen to step 3"
				slock=$(<./working/slock.txt)
				echo -ne $(sed 's/../\\x&/g' <<<  $slock) > ./working/res.bin
				echo "press enter to Return To Menu"
					read \n
				bash ./Unlock-tool.sh
				exit 
			;;
			"Flash Slock Bin 3")
				echo "--------------------------------------------------------------------------------"
				sudo $FASTBOOT flash slock ./working/res.bin 2> "./log/flash_slock_message.txt"
				slock_message=$(<./log/flash_slock_message.txt)
				echo $slock_message
				echo "Slock file has been flashed now need to install twrp"
				echo "[*] press enter to Return To Menu"
					read \n
				bash ./Unlock-tool.sh
				exit
			;;
			"Flash TWRP 4")
				echo "--------------------------------------------------------------------------------"
				sudo $FASTBOOT flash erecovery_ramdisk ./files/TWRP_kirin.img 2> "./log/flash_twrp_message.txt"
				twrp_message=$(<./log/flash_twrp_message.txt)
				echo $twrp_message
				echo "Next Phone should reboot to Android system"
				echo "Ensure device is fully boots before continueing to step 5"
				echo "[*] press enter to Reboot and Return To Menu"
					read \n
				sudo $FASTBOOT reboot
				bash ./Unlock-tool.sh
				exit
			;;
			"Read MVNE 5")
				echo "--------------------------------------------------------------------------------"
				$ADB reboot erecovery
				echo waiting to allow phone to boot TWRP
				echo "[*] press enter to Continue When Phone Fully Booted in TWRP"
					read \n
				echo "You should now be in TWRP"
				echo "Now we will read and copy the MVNE file to be edited"
				$ADB shell dd if=/dev/block/bootdevice/by-name/nvme of=/tmp/nvme
				$ADB pull /tmp/nvme ./original_nvme
				echo "[*] press enter to Return To Menu"
					read \n
				bash ./Unlock-tool.sh
				exit
			;;
			"Convert MVNE 6")
				echo "Now to convert the MVNE FIle"
				sed 's/\x46\x42\x4C\x4F\x43\x4B\x00\x00\x01\x00\x00\x00\x01/\x46\x42\x4C\x4F\x43\x4B\x00\x00\x01\x00\x00\x00\x00/g' ./original_nvme > ./modified_nvme
				echo "[*] press enter to Return To Menu"
					read \n
				bash ./Unlock-tool.sh
				exit
			;;
			"Flash MVNE 7")
				$ADB push ./modified_mvne /tmp/modified_nvme
				$ADB shell dd if=/tmp/modified_nvme of=/dev/block/bootdevice/by-name/nvme
				echo "[*] press enter to Return To Menu"
					read \n
				bash ./Unlock-tool.sh
				exit
			;;
			"finished 8")
				rm -f ./working/*.txt
				exit
			;;
			*) echo invalid option;;
		esac
	done