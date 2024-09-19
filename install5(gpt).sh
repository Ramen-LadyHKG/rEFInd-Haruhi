#!/bin/bash

# Define the version of rEFInd going to install
refind_version="0.14.2"
shim_version="15.8+ubuntu+1.58"

echo -e "----------------------------------------------------\n"
echo -e "Make sure you have Network Connection and DO NOT RUN as ROOT\n"
echo -e "Note that, the script will need root privilege"
echo -e "Because files in ESP are only readable or editable by root."
echo -e "Disclaimer: Please review this code before executing further."
echo -e "----------------------------------------------------\n"

echo -e "Press Enter to return to the menu..."
read

clear

# Function to check the status of installed components
check_status() {
	# Check ESP location
 	if sudo test -d "/boot/efi/EFI" ; then
		ESP_location="/boot/efi/EFI"
   	elif sudo test -d "/boot/EFI/"; then
    		ESP_location="/boot/EFI"
   	else
       		echo -e "I could not find your ESP, please make sure it's UEFI / mount EFI correctly."
	 	echo -e "Exiting the program due to Error (ESP not found)"
   		exit 1
   	fi
	# Check rEFInd installation
	if sudo test -d "$ESP_location/refind" ; then
		refind_status="Installed"
  		refind_location="$ESP_location/refind"
	else
		refind_status="Not Installed"
		refind_location="Unknown"
	fi

	# Check refind_banner_update.sh installation
	if [ -f "$HOME/scripts/refind_banner_update/refind_banner_update.sh" ]; then
		update_script_status="Installed"
  		update_script_location="$HOME/scripts/refind_banner_update/refind_banner_update.sh"
	else
		update_script_status="Not Installed"
    		update_script_location="Unknown"
	fi

	# Check preconfigured refind.conf installation
	if sudo test -f "$ESP_location/refind/refind.conf.original_backupbyscript"; then
		conf_status="Installed"
	else
		conf_status="Not Installed"
	fi

	# Check rEFInd-Haruhi theme installation
	if sudo test -d "$ESP_location/refind/themes/rEFInd-Haruhi"; then
		theme_status="Installed"
	else
		theme_status="Not Installed"
	fi
	preconf_install="YES"
	# Check Secure Boot status
	command -v mokutil >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		sb_status=$(mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled" && echo "Enabled" || echo "Disabled")
	else
		sb_status="Mokutil Not Installed, Marked as Disabled"
	fi

	# Check Distro using the 'ID' field and 'ID_LIKE' field from /etc/os-release
	distro=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
	distro_like=$(grep "^ID_LIKE=" /etc/os-release | cut -d'=' -f2 | tr -d '"')

	# List of supported distros
	supported_distros=("fedora" "ubuntu" "debian" "arch" "suse")
	
	# Check if distro or distro_like is supported
	if [[ " ${supported_distros[@]} " =~ " ${distro} " ]] || [[ " ${supported_distros[@]} " =~ " ${distro_like} " ]]; then
		distro_status="Supported [$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')] ($distro_like)"
	else
		distro_status="Not Supported [$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')] ($distro_like)"
	fi
}

# Function to display the main menu
display_menu() {
	# Update status before displaying the menu
	check_status
	
 	echo -e ""
	echo -e "====== Welcome to rEFInd-Haruhi Install script ======"
	echo -e "Installation Status:"
	echo -e "1. rEFInd install: $refind_status ($refind_location)"
	echo -e "2. refind_banner_update.sh install: $update_script_status ($update_script_location)"
	echo -e "3. Preconfigured refind.conf: ($conf_status)"
	echo -e "4. rEFInd-Haruhi: $theme_status"
	echo -e "5. Secure Boot: $sb_status"
	echo -e "6. Distro: $distro_status"
	echo -e "----------------------------------------------------"
	echo -e "a. Automatically install all components"
	echo -e "b. Background List"
	echo -e "c. Current Installed rEFInd theme"
	echo -e "d. Delete Haruhi theme"
	echo -e "e. Edit & Install selected components"
	echo -e "f. Fallback configuration"
 	echo -e "g. Gather the absolute path of Background list"
	echo -e "q. Exit the program"
	echo -e "----------------------------------------------------\n"
}

# ========= Actions Begins here =========

# Define Default Install State
if [ "$refind_status" == "Installed" ]; then
	refind_install="NO"
else
	refind_install="YES"
fi

if [ "$update_script_status" == "Installed" ]; then
	update_script_install="NO"
else
	update_script_install="YES"
fi

if [[ "$conf_status" == "Installed" ]]; then
	conf_install="NO"
else
	conf_install="YES"
fi

if [[ "$theme_status" == "Installed" ]]; then
	theme_install="NO"
else
	theme_install="YES"
fi

if [[ "$sb_status" == "Enabled" ]]; then
	sb_install="YES"
else
	sb_install="NO"
fi

# Function to install Secure Boot Component
install_secure_boot_component() {
	echo -e "" #Skip 1 line to print
	echo -e "Secure Boot Components {openssl mokutil sbsigntools} installing..."

 	if [[ "$distro_like" =~ "debian" ]]; then
  		sudo apt install openssl mokutil sbsigntool
    	elif [[ "$distro_like" =~ "fedora" ]]; then
     		sudo dnf install openssl mokutil sbsigntools 
    	elif [[ "$distro_like" =~ "suse" ]]; then
		sudo zypper install openssl mokutil sbsigntools
  	elif [[ "$distro_like" =~ "arch" ]]; then
   		sudo pacman -S openssl mokutil sbsigntools
     	else
      		echo -e "ERROR: We cannot install Secure Boot Component on your distro, skipping..."
		echo -e "Press Enter to return to the menu..."
		read
  		return 1
  	fi
   	mkdir shim-signed && cd shim-signed
   	wget "http://archive.ubuntu.com/ubuntu/pool/main/s/shim-signed/shim-signed_${shim_version##*+ubuntu+}+${shim_version%%+ubuntu*}-0ubuntu1_amd64.deb"
	bsdtar -vxOf "shim-signed_1.58+15.8-0ubuntu1_amd64.deb" data.tar.xz | bsdtar -vx usr/share/doc/shim-signed/copyright
 	bsdtar -vxOf "shim-signed_1.58+15.8-0ubuntu1_amd64.deb" data.tar.xz | bsdtar -vx usr/lib/shim/
  	cp -v "usr/share/doc/shim-signed/copyright" "LICENSE"
   	cp -v "usr/lib/shim/shimx64.efi.signed.latest" "shimx64.efi"
    	cp -v "usr/lib/shim/"{mm,fb}x64".efi" "."
     	cd ..
   	echo -e "Install secure boot components successfully on ($distro_like), proceed... "
  	
       	echo -e "\n----------------------------------------------------\n"
	
	echo -e "Press Enter to proceed..."
	read
}

# Function to install rEFInd without secure boot
install_refind() {
	echo -e "" #Skip 1 line to print

	if sudo test -d "$ESP_location/refind" ; then
		echo ""
		echo -e "rEFInd is already installed on your system, skipping..."
	else
	 	echo -e "Downloading and Extract rEFInd installation ..."
 		wget https://sourceforge.net/projects/refind/files/${refind_version}/refind-bin-gnuefi-${refind_version}.zip
		unzip -a refind-bin-gnuefi-$(refind_version).zip
 
  		echo -e "Installing (rEFInd without Secure Boot) ..."
		sudo ./refind-bin-$(refind_version)/refind-install
		sudo cp -rf refind-bin-$(refind_version)/fonts/ $ESP_location/refind

		if sudo test -d "$ESP_location/refind" ; then
			echo -e "rEFInd has successfully installed on your system, proceed..."
  			echo -e "Press Enter to proceed..."
			read
		else
 			echo -e "ERROR: For some reason, rEFInd couldn't install on you system. Exiting..."
   			echo -e "Press Enter to return to the menu..."
			read
     			return 1
  	   	fi
	fi
}

# Function to install rEFInd with secure boot
install_refind_sb() {
	echo -e "" #Skip 1 line to print

	if sudo test -f "$ESP_location/refind/shimx64.efi" ; then
		echo -e "(rEFInd with Secure Boot) is already installed on your system, skipping..."
	else
 		echo -e "Downloading and Extract rEFInd installation ..."
 	 	wget https://sourceforge.net/projects/refind/files/$(refind_version)/refind-bin-gnuefi-$(refind_version).zip
		unzip -a refind-bin-gnuefi-$(refind_version).zip

 		echo -e "Installing (rEFInd with Secure Boot) ..."

 		install_secure_boot_component
 		echo -e "Executing (refind-install --shim "$(pwd)/shim-signed/shimx64.efi" --localkeys) ..."
		sudo ./refind-bin-$(refind_version)/refind-install --shim "$(pwd)/shim-signed/shimx64.efi" --localkeys
  		echo -e "Executing (refind-healthcheck) ..."
 		sudo ./refind-bin-$(refind_version)/refind-healthcheck
		sudo cp -rf refind-bin-$(refind_version)/fonts/ $ESP_location/refind

		if sudo test -d "$ESP_location/refind" ; then
			echo -e "rEFInd with Secure Boot has successfully installed on your system, proceed..."
			echo -e "Press Enter to proceed..."
			read
		else
 			echo -e "ERROR: For some reason, rEFInd couldn't install on you system. Exiting..."
   			echo -e "Press Enter to return to the menu..."
			read
     			exit 1
     		fi
	fi
}

# Function to install refind_banner_update.sh
install_refind_banner_update() {
	echo -e "" #Skip 1 line to print

	if [[ "$update_script_status" == "Installed" ]]; then
		echo -e "refind_banner_update.sh is already installed, skipping..."
  		echo -e "\n----------------------------------------------------\n"
		echo -e "Press Enter to proceed..."
		read
	else
		echo -e "Installing refind_banner_update.sh..."
		mkdir -p "$HOME/scripts/refind_banner_update"
		cp "refind_banner_update.sh" "$HOME/scripts/refind_banner_update/"
  		
    		echo -e "(refind_banner_update.sh) has been installed successfully."
  		echo -e "\n----------------------------------------------------\n"
		echo -e "Press Enter to proceed..."
		read
	fi
}

# Function to install preconfigured refind.conf
install_preconfigured_conf() {
	echo -e "" #Skip 1 line to print

	if [[ "$conf_status" == "Installed" ]]; then
		echo -e "(Preconfigured refind.conf) is already installed, skipping."
    		echo -e "\n----------------------------------------------------\n"
		echo -e "Press Enter to proceed..."
		read
	else
		echo -e "Your original refind.conf will be rename as refind.conf.original_backupbyscript"
  		sudo cp "$ESP_location/refind/refind.conf" "$ESP_location/refind/refind.conf.original_backupbyscript"		
  		echo -e "Installing preconfigured refind.conf..."
		sudo cp refind.conf $ESP_location/refind/refind.conf
    		echo -e "(Preconfigured refind.conf) has been installed successfully."
    		echo -e "\n----------------------------------------------------\n"
		echo -e "Press Enter to proceed..."
		read
	fi
}

# Function to install rEFInd-Haruhi theme
install_haruhi_theme() {
	echo -e "" #Skip 1 line to print

	if [[ "$theme_status" == "Installed" ]]; then
		echo -e "(rEFInd-Haruhi theme) is already installed, skipping..."
    		echo -e "\n----------------------------------------------------\n"
		echo -e "Press Enter to proceed..."
		read
	else
		echo -e "Installing rEFInd-Haruhi theme..."
		sudo cp -r "themes/rEFInd-Haruhi" "$ESP_location/refind/themes/"
  
      		echo -e "(rEFInd-Haruhi theme) has been installed successfully."
      		echo -e "\n----------------------------------------------------\n"
		echo -e "Press Enter to proceed..."
		read
	fi
}

# Function to list backgrounds
list_backgrounds() {
	echo -e "" #Skip 1 line to print

	# List installed backgrounds if rEFInd-Haruhi theme is installed
	if [[ "$theme_status" = "Installed" ]]; then
		echo -e "Listing installed rEFInd-Haruhi Backgrounds in ESP:\n"
		sudo ls -1 $ESP_location/refind/themes/rEFInd-Haruhi/Background/ || echo -e "No installed backgrounds found in ESP."
      		echo -e "\n----------------------------------------------------\n"
	fi

	# List available backgrounds in the local directory
	echo -e "Listing available Haruhi Backgrounds to install...\n"
	ls -1 themes/rEFInd-Haruhi/Background/ || echo -e "No available backgrounds found in the current directory."
      	echo -e "\n----------------------------------------------------\n"
	echo -e "Press Enter to return to the menu..."
	read
}

# Function to list backgrounds in absolute path
list_backgrounds_absolute_path() {
	echo -e "" #Skip 1 line to print

	# List installed backgrounds if rEFInd-Haruhi theme is installed
	if [[ "$theme_status" = "Installed" ]]; then
		echo -e "Listing installed rEFInd-Haruhi Backgrounds in ESP:\n"
		sudo ls -1d $ESP_location/refind/themes/rEFInd-Haruhi/Background/* || echo -e "No installed backgrounds found in ESP."
      		echo -e "\n----------------------------------------------------\n"
	fi


	# List available backgrounds in the local directory
	echo -e "Listing available Haruhi Backgrounds to install...\n"
	ls -1d "$PWD"/themes/rEFInd-Haruhi/Background/* || echo -e "No available backgrounds found in the current directory."
      	echo -e "\n----------------------------------------------------\n"
	echo -e "Press Enter to return to the menu..."
	read
}


# Function to display current theme
current_theme() {
	echo -e "" #Skip 1 line to print

	# Check if the themes directory exists
	if [ -d "$ESP_location/refind/themes/" ]; then
		# Check if theme directory is not empty
		if [ "$(ls -A "$ESP_location/refind/themes/")" ]; then
			# List the contents with absolute paths
			sudo ls -1d "$ESP_location/refind/themes/"*/
		else
			echo "Theme directory exists but is empty."
		fi
	else
		echo "The themes directory does not exist."
	fi

       	echo -e "\n----------------------------------------------------\n"
	echo -e "Press Enter to return to the menu..."
	read
}

# Function to delete Haruhi theme
delete_haruhi_theme() {
	echo -e "" #Skip 1 line to print

        if [[ "$theme_status" == "Installed" ]]; then
		echo -e "Deleting rEFInd-Haruhi theme..."
		sudo rm -rf "$ESP_location/refind/themes/rEFInd-Haruhi"
  		
		echo -e "rEFInd-Haruhi theme deleted."
 	      	echo -e "\n----------------------------------------------------\n"
	 	echo -e "Press Enter to return to the menu..."
		read
	else
		echo -e "(rEFInd-Haruhi theme) is not installed, skipping..."
   	      	echo -e "\n----------------------------------------------------\n"
	   	echo -e "Press Enter to return to the menu..."
		read
        fi

}

# Function to rollback configuration
rollback_config() {
	echo -e "" #Skip 1 line to print

	if [[ "$conf_status" == "Installed" ]] ; then
		echo -e "Rolling back original configuration..."
		sudo mv $ESP_location/refind/refind.conf.original_backupbyscrip $ESP_location/refind/refind.conf

 		echo -e "Your  refind.conf has rolled back to (refind.conf.original_backupbyscript)"

	else
 		echo -e "Original (refind.conf) backup file DOES NOT EXIT, skipping..."
	fi
 
 	echo -e "\n----------------------------------------------------\n"
	echo -e "Press Enter to return to the menu..."
	read

}

# Functions to toggle options
toggle_refind() {
	if [[ "$refind_install" == "YES" ]]; then
		refind_install="NO"
	else
		refind_install="YES"
	fi
}

toggle_banner_update() {
	if [[ "$update_script_install" == "YES" ]]; then
		update_script_install="NO"
	else
		update_script_install="YES"
	fi
}

toggle_conf() {
	if [[ "$preconf_install" == "YES" ]]; then
		preconf_install="NO"
	else
		preconf_install="YES"
	fi
}

toggle_haruhi_theme() {
	if [[ "$theme_install" == "YES" ]]; then
		theme_install="NO"
	else
		theme_install="YES"
	fi
}

toggle_secure_boot() {
	if [[ "$sb_install" == "YES" ]]; then
		sb_install="NO"
	else
		sb_install="YES"
	fi
}

# Function for edit menu
edit_menu() {
	while true; do
		echo -e "update_script_status (1-5) which component to install:"
		echo -e "1. rEFInd Boot Manager [$refind_status] {$refind_install}"
		echo -e "2. refind_banner_update.sh [$update_script_status] {$update_script_install}"
		echo -e "3. Preconfigured refind.conf [$conf_status] {$preconf_install}"
		echo -e "4. rEFInd-Haruhi [$theme_status] {$theme_install}"
		echo -e "5. Secure-Boot [$sb_status] {$sb_install}"
		echo -e "x. Begin installation with options above"
		echo -e "b. Back to main menu"
		read -p "Enter your choice: " edit_choice

		case $edit_choice in
			1) toggle_refind ;;
			2) toggle_banner_update ;;
			3) toggle_conf ;;
			4) toggle_haruhi_theme ;;
			5) toggle_secure_boot ;;
			x) install_selected_components; break ;;
			b) break ;;
			*) echo -e "Invalid choice, please try again." ;;
		esac
		
		# Add a separation line before returning to the main menu
		echo
	        echo -e "\n----------------------------------------------------\n"
		echo -e "Result of selected option:"
	        echo -e "\n----------------------------------------------------\n"
		sleep 2
		echo
	done
}

# Function to install all components (install based on secure boot status)
install_all_components() {
	echo -e "Starting automatic installation of all components..."
 	if [[ "$sb_status" == "Enabled" ]]; then
		install_refind_sb
 	else
  		install_refind
    	fi
     
 	install_refind_banner_update
	if [[ "$refind_status" == "Installed" ]]; then
   		install_preconfigured_conf
		install_haruhi_theme
	else
		echo -e "ERROR: We cannot proceed if rEFInd isn't installed"
	fi

	echo -e "Installation complete!"
        echo -e "\n----------------------------------------------------\n"
}

# Function to install selected components
install_selected_components() {

	if [[ "$refind_install" == "YES" ]]; then
 		if [ "sb_install" == "YES" ]; then
			install_refind_sb
   		else
     			install_refind
		fi
	fi
 
	if [[ "$update_script_install" == "YES" ]]; then
		echo -e "(refind_banner_update.sh) is already installed, skipping..."
	else
  		install_refind_banner_update
	fi

	if [[ refind_status="Installed" ]]; then
		if [ "$preconf_install" == "YES" ]; then
			echo -e "(Preconfigured refind.conf) is already installed, skipping..."
		else
			install_preconfigured_conf
		fi

		if [[ "$theme_install" == "YES" ]]; then
			theme_install="NO"
		else
			install_haruhi_theme
		fi
	else
		echo -e "ERROR: We cannot proceed if rEFInd isn't installed"
	fi

	echo -e "Installation complete!"
        echo -e "\n----------------------------------------------------\n"
}

# Function to handle user choices
handle_choice() {
	case "$1" in
		a)
			echo -e "Installing all components..."
			install_all_components
			;;
		b)
			list_backgrounds
			;;
		c)
			current_theme
			;;
		d)
			delete_haruhi_theme
			;;
		e)
			edit_menu
			;;
		f)
			rollback_config
			;;
		g)
			list_backgrounds_absolute_path
			;;
		q)
			echo -e "Exiting the program."
			exit 0
			;;
		*)
			echo -e "Invalid choice, please try again."
			;;
	esac
}

# Main loop
while true; do
	clear  # Clear screen to ensure fresh menu display
	display_menu

	# Read user choice
	read -p "Select an option: " user_choice

	# Handle user choice
	handle_choice "$user_choice"

	# Add a pause after each action to allow the user to see the output before menu refreshes
	echo -e "Press Enter to return to the menu..."
	readit 1
done
