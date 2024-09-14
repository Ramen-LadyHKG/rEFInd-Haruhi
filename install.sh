#
echo -e "This program will install following:"
echo -e " 1. Create Directory $HOME/scripts/refind_banner_update"
echo -e "2. Copy "refind_banner_update.sh" to "/$HOME/scripts/refind_banner_update/""
echo -e ""
#
read -p "Do you want to proceed? (yes/no) " yn

case $yn in
	yes ) echo -e "ok, we will proceed\n\n";;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac


# Create directory `script` on your $HOME directory
# 
if [ "$USER" == "root" ]; then
	echo -e "Do not run this script as root\nexiting the program"
	exit 1
fi

if test -d "$HOME/scripts"; then
	echo -e "scripts/ directory already exists\n"
else
	echo -e "scripts/ DNS\n"
	echo -e "createing $HOME/scripts/ now\n"
	mkdir "$HOME/scripts"
fi

if test -d "$HOME/scripts/refind_banner_update"; then
	echo -e "refind_banner_update is already installed\nexiting the program"
	exit 1
else
	cp -r "refind_banner_update" "$HOME/scripts/refind_banner_update"
fi

echo -e "Installing theme 'rEFInd-Haruhi' to your rEFInd theme directory"

if sudo test -d "/boot/efi/EFI/refind"; then

	if sudo test -d "/boot/efi/EFI/refind/themes/rEFInd-Haruhi"; then
		echo -e "rEFInd-Haruhi is already installed on your ESP, do nothing."

	elif sudo test -d "/boot/efi/EFI/refind/themes/"; then
		echo -e "Copying theme 'rEFInd-Haruhi' to your rEFInd theme directory"	
		sudo cp -r themes/rEFInd-Haruhi "/boot/efi/EFI/refind/themes/rEFInd-Haruhi"
		echo -e "rEFInd-Haruhi has been installed on your ESP, Thank you"
	else
		echo -e "refind/themes/ directory does not exist, creating one"
		sudo mkdir "/boot/efi/EFI/refind/themes"
		sudo cp -r themes/rEFInd-Haruhi "/boot/efi/EFI/refind/themes/rEFInd-Haruhi"
		echo -e "rEFInd-Haruhi has been installed on your ESP, Thank you"
	fi

elif sudo test -d "/boot/EFI/refind"; then
	
	if sudo test -d "/boot/EFI/refind/themes/rEFInd-Haruhi"; then
		echo -e "rEFInd-Haruhi is already installed on your ESP, do nothing."

	elif sudo test -d "/boot/EFI/refind/themes/"; then
		echo -e "Copying theme 'rEFInd-Haruhi' to your rEFInd theme directory"	
		sudo cp -r themes/rEFInd-Haruhi "/boot/EFI/refind/themes/rEFInd-Haruhi"
		echo -e "rEFInd-Haruhi has been installed on your ESP, Thank you"
	else
		echo -e "refind/themes/ directory does not exist, creating one"
		sudo mkdir "/boot/EFI/refind/themes"
		sudo cp -r themes/rEFInd-Haruhi "/boot/EFI/refind/themes/rEFInd-Haruhi"
		echo -e "rEFInd-Haruhi has been installed on your ESP, Thank you"
	fi
else

	echo -e "ERROR, ESP or refind directory does not exist"
	echo -e "Please make sure refind is installed correctly before running the script"
	echo -e "exiting the program with error"
	exit 1
fi

echo "We have a preconfigured refind configuration, would you like to install to your ESP/refind/refind.conf?
read -p "Do you want to proceed? (YES/NO) " YN

case $YN in
        YES ) echo -e "ok, we will proceed\n\n";;
        NO ) echo -e "Everything has done, Thank you for using our script, please enjoy!\nexiting...";
                exit;;
        * ) echo invalid response;
                exit 1;;
esac

echo -e "Installing to your ESP...."

if sudo test -d "/boot/efi/EFI/refind"; then

	if sudo test -f "/boot/efi/EFI/refind/refind.conf"; then
		echo -e "Your original refind.conf will be rename as refind.conf.original_backupbyscript"
		sudo cp "/boot/efi/EFI/refind/refind.conf" "/boot/efi/EFI/refind/refind.conf.original_backupbyscript"
		sudo cp refind.conf "/boot/efi/EFI/refind/refind.conf"
		echo -e "preconfigured refind configuration has copied to /boot/efi/EFI/refind/refind.conf"
	else
		sudo cp refind.conf "/boot/efi/EFI/refind/refind.conf"
		echo -e "preconfigured refind configuration has copied to /boot/efi/EFI/refind/refind.conf"
	fi

elif sudo test -d "/boot/EFI/refind"; then
	
	if sudo test -f "/boot/EFI/refind/refind.conf"; then
		echo -e "Your original refind.conf will be rename as refind.conf.original_backupbyscript"
		sudo cp "/boot/efi/EFI/refind/refind.conf" "/boot/EFI/refind/refind.conf.original_backupbyscript"
		sudo cp refind.conf "/boot/EFI/refind/refind.conf"
		echo -e "preconfigured refind configuration has copied to /boot/EFI/refind/refind.conf"
	else
		sudo cp refind.conf "/boot/EFI/refind/refind.conf"
		echo -e "preconfigured refind configuration has copied to /boot/EFI/refind/refind.conf"
	fi
else

	echo -e "ERROR, ESP or refind directory does not exist"
	echo -e "Please make sure refind is installed correctly before running the script"
	echo -e "exiting the program with error"
	exit 1
fi
