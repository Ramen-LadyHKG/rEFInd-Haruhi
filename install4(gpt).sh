#!/bin/bash

# Define the version of rEFInd going to install
refind_version="0.14.2"


echo -e "Note that, the script will need root previlege"
echo -e "Because files in ESP is only readable or editable by root."
echo -e "Disclaimer: Please review that code before executing further."

# Function to check the status of installed components
check_status() {
	# Check ESP location
 	if sudo test -d "/boot/efi/EFI" ; then
		ESP_location="/boot/efi/EFI"
   	elif sudo test -d "/boot/EFI/"; then
    		ESP_location="/boot/EFI"
   	else
       		echo -e "I Could not find your ESP, please make sure it's UEFI / mount EFI correctly."
	 	echo -e "Exiting the program due to Error(ESP not found)"
   		exit 1
   	fi
	# Check rEFInd installation
	if sudo test -d "$ESP_location/refind" ; then
		refind_status="Installed"
  		refind_location="$ESP_location/refind"
  	elif sudo test -d "$ESP_location/refind" ; then
   		refind_status="Installed"
       		refind_location="$ESP_location/refind"
	else
		refind_status="Not Installed"
	fi

	# Check refind_banner_update.sh installation
	if [ -f "$HOME/scripts/refind_banner_update/refind_banner_update.sh" ]; then
		update_script_status="Installed"
  		update_script_status="$HOME/scripts/refind_banner_update/refind_banner_update.sh"
	else
		update_script_status="Not Installed"
    		update_script_status="Unknown"

	fi

	# Check preconfigured refind.conf installation
	if sudo test -f "$ESP_location/refind/refind.conf.original_backupbyscript"; then
		conf_status="Installed"
	else
		conf_status="Not Installed"
	fi

	# Check rEFInd-Haruhi theme installation
	if sudo test -d "$ESP_location/refind/themes/rEFInd-Haruhi" || sudo test -d "/boot/EFI/refind/themes/rEFInd-Haruhi"; then
		theme_status="Installed"
	else
		theme_status="Not Installed"
	fi

	# Check Secure Boot status
	command -v mokutil >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		# Mokutil is installed, proceed
		sb_status=$(mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled" && echo "Enabled" || echo "Disabled")
	else
		# Mokutil is not installed, take it as disabled
		sb_status="Mokutil Not Installed, Marked as Disabled"
	fi
 
  

	# Check Distro using the 'ID' field and 'ID_LIKE' field from /etc/os-release
	distro=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
	distro_like=$(grep "^ID_LIKE=" /etc/os-release | cut -d'=' -f2 | tr -d '"')

	# List of supported distros
	supported_distros=("fedora" "ubuntu" "debian" "arch")
	
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

	echo "====== Welcome to rEFInd-Haruhi Install script ======"
	echo "Installation Status:"
	echo "1. rEFInd install: $refind_status ($refind_location)"
	echo "2. refind_banner_update.sh install: $update_script_status ($update_script_status)"
	echo "3. Preconfigured refind.conf: ($conf_status)"
	echo "4. rEFInd-Haruhi: $theme_status"
	echo "5. Secure-Boot: $sb_status"
	echo "6. Distro: $distro_status"
	echo "----------------------------------------------------"
	echo "a. Automatically install all components"
	echo "b. Background List"
	echo "c. Current Installed rEFInd theme"
	echo "d. Delete Haruhi theme"
	echo "e. Edit & Install selected components"
	echo "f. Rollback configuration"
	echo "g. ""
	echo "q. Exit the program"
	echo -e "----------------------------------------------------\n"
}

# ========= Actions Begins here =========

# Define Default Install State
if [ "$refind_status" == "Installed" ]; then
	refind_install = "NO"
else
	refind_install = "YES"
fi

if [ "$update_script_status" == "Installed" ]; then
	update_script_install = "NO"
else
	update_script_install = "YES"
fi

if [ "$conf_status" == "Installed" ]; then
	conf_install = "NO"
else
	conf_install = "YES"
fi

if [ "$theme_status" == "Installed" ]; then
	theme_install = "NO"
else
	theme_install = "YES"
fi

if [ "$sb_status" == "Enabled" ]; then
	sb_install = "YES"
else
	sb_install = "NO"
fi

# Function to install Secure Boot Component
install_secure_boot_component() {
	echo "Secure Boot installation steps go here..."

 	if [ "$distro_like" == "debian" ]; then
  		sudo apt install sbsigntool openssl mokutil
    	elif [ "$distro_like" == "fedora" ]; then
     		sudo  apt install
	
  	
       	echo -e "\n----------------------------------------------------\n"
}

# Function to install rEFInd without secure boot
install_refind() {


wget https://sourceforge.net/projects/refind/files/$(refind_version)/refind-bin-gnuefi-$(refind_version).zip
unzip -a refind-bin-gnuefi-$(refind_version).zip

sudo cp 
}
# Function to install refind_banner_update.sh
install_refind_banner_update() {
	if [ "$update_script_status" == "Installed" ]; then
		echo "refind_banner_update.sh is already installed, skipping..."
  		echo -e "\n----------------------------------------------------\n"
	else
		echo "Installing refind_banner_update.sh..."
		mkdir -p "$HOME/scripts/refind_banner_update"
		cp "refind_banner_update.sh" "$HOME/scripts/refind_banner_update/"
  		echo "(refind_banner_update.sh) has been installed."
  		echo -e "\n----------------------------------------------------\n"

	fi
}

# Function to install preconfigured refind.conf
install_preconfigured_conf() {
	if [ "$conf_status" == "Installed" ]; then
		echo "(Preconfigured refind.conf) is already installed, skipping."
    		echo -e "\n----------------------------------------------------\n"

	else
		echo "Installing preconfigured refind.conf..."
		sudo cp refind.conf $ESP_location/refind/refind.conf
    		echo "(Preconfigured refind.conf) has been installed."
    		echo -e "\n----------------------------------------------------\n"

	fi
}

# Function to install rEFInd-Haruhi theme
install_haruhi_theme() {
	if [ "$theme_status" == "Installed" ]; then
		echo "(rEFInd-Haruhi theme) is already installed, skipping..."
    		echo -e "\n----------------------------------------------------\n"
	else
		echo "Installing rEFInd-Haruhi theme..."
		sudo cp -r "themes/rEFInd-Haruhi" "$ESP_location/refind/themes/"
      		echo "(rEFInd-Haruhi theme) has been installed."
      		echo -e "\n----------------------------------------------------\n"
	fi
}

# Function to list backgrounds
list_backgrounds() {
	# List installed backgrounds if rEFInd-Haruhi theme is installed
	if [ "$theme_status" = "Installed" ]; then
		echo -e "Listing installed rEFInd-Haruhi Backgrounds in ESP:"
		sudo ls -1 $ESP_location/refind/themes/rEFInd-Haruhi/Background || echo "No installed backgrounds found in ESP."
      		echo -e "\n----------------------------------------------------\n"
	fi

	# List available backgrounds in the local directory
	echo "Listing available Haruhi Backgrounds to install..."
	ls -1 themes/rEFInd-Haruhi/Background || echo "No available backgrounds found in the current directory."
      		echo -e "\n----------------------------------------------------\n"
}

# Function to display current theme
current_theme() {
	echo "Current Installed rEFInd theme..."
	sudo ls -1 $ESP_location/refind/themes/
       	echo -e "\n----------------------------------------------------\n"
}

# Function to delete Haruhi theme
delete_haruhi_theme() {
        if [ "$theme_status" == "Installed" ]; then
		echo -e "Deleting rEFInd-Haruhi theme..."
		sudo rm -rf "$ESP_location/refind/themes/rEFInd-Haruhi"
		echo -e "rEFInd-Haruhi theme deleted."
 	      	echo -e "\n----------------------------------------------------\n"
	else
		echo -e "(rEFInd-Haruhi theme) is not installed, skipping..."
   	      	echo -e "\n----------------------------------------------------\n"
        fi

}

# Function to rollback configuration
rollback_config() {
	echo "Rolling back to default configuration..."
	sudo mv $ESP_location/refind/refind.conf.haruhi $ESP_location/refind/refind.conf
        echo -e "\n----------------------------------------------------\n"

}

# Function for edit menu
edit_menu() {
	while true; do
		echo "update_script_status (1-5) which component to install:"
		echo "1. rEFInd Boot Manager [$refind_status] {$refind_install}"
		echo "2. refind_banner_update.sh [$update_script_status] {$update_script_install}"
		echo "3. Preconfigured refind.conf [$conf_status] {$preconf_install}"
		echo "4. rEFInd-Haruhi [$theme_status] {$theme_install}"
		echo "5. Secure-Boot [$sb_status] {$sb_install}"
		echo "x. Begin installation with options above"
		echo "b. Back to main menu"
		read -p "Enter your choice: " edit_choice

		case $edit_choice in
			1) toggle_refind ;;
			2) toggle_banner_update ;;
			3) toggle_conf ;;
			4) toggle_haruhi_theme ;;
			5) toggle_secure_boot ;;
			x) install_selected_components; break ;;
			b) break ;;
			*) echo "Invalid choice, please try again." ;;
		esac
		
		# Add a separation line before returning to the main menu
		echo
	        echo -e "\n----------------------------------------------------\n"
		echo "Result of selected option:"
	        echo -e "\n----------------------------------------------------\n"
		sleep 2
		echo
	done
}

# Function to install all components (install based on secure boot status)
install_all_components() {
	echo "Starting automatic installation of all components..."
 	if [ "$sb_status" == "Enabled" ]; then
		install_refind_sb
 	else
  		install_refind
    	fi
     
 	install_refind_banner_update
	if [ refind_status="Installed" ]; then
   		install_preconfigured_conf
		install_haruhi_theme
	else
		echo -e "ERROR: We cannot proceed if rEFInd isn't installed"
	fi

	echo "Installation complete!"
        echo -e "\n----------------------------------------------------\n"
}

# Function to install selected components
install_selected_components() {

	if [ "$refind_install" == "YES" ]; then
 		if [ "sb_install" == "YES" ]; then
			install_refind_sb
   		else
     			install_refind
		fi
	fi
 
	if [ "$update_script_install" == "YES" ]; then
		echo -e "(refind_banner_update.sh) is already installed, skipping..."
	else
  		install_refind_banner_update
	fi

	if [ refind_status="Installed" ]; then
		if [ "$preconf_install" == "YES" ]; then
			echo -e "(Preconfigured refind.conf) is already installed, skipping..."
		else
			install_preconfigured_conf
		fi

		if [ "$theme_install" == "YES" ]; then
			theme_install="NO"
		else
			install_haruhi_theme
		fi
	else
		echo -e "ERROR: We cannot proceed if rEFInd isn't installed"
	fi

	echo "Installation complete!"
        echo -e "\n----------------------------------------------------\n"
}

# Functions to toggle options
toggle_refind() {
	if [ "$refind_install" == "YES" ]; then
		refind_install="NO"
	else
		refind_install="YES"
	fi
}

toggle_banner_update() {
	if [ "$update_script_install" == "YES" ]; then
		update_script_install="NO"
	else
		update_script_install="YES"
	fi
}

toggle_conf() {
	if [ "$preconf_install" == "YES" ]; then
		preconf_install="NO"
	else
		preconf_install="YES"
	fi
}

toggle_haruhi_theme() {
	if [ "$theme_install" == "YES" ]; then
		theme_install="NO"
	else
		theme_install="YES"
	fi
}

toggle_secure_boot() {
	if [ "$sb_install" == "YES" ]; then
		sb_install="NO"
	else
		sb_install="YES"
	fi
}

# Function to handle user choices
handle_choice() {
	case "$1" in
		a)
			echo "Installing all components..."
			install_all_components
			;;
		b)
			list_backgrounds
			;;
		c)
			echo "Checking current installed rEFInd theme..."
			sudo ls /boot/efi/EFI/refind/themes || echo "No themes found."
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
			install_selected_components
			;;
		q)
			echo "Exiting the program."
			exit 0
			;;
		*)
			echo "Invalid choice, please try again."
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
	echo "Press Enter to return to the menu..."
	read
done
