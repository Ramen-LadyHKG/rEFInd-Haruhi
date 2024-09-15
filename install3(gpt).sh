#!/bin/bash

echo -e "Note that, the script will need root previlege"
echo -e "Because files in ESP is only readable or editable by root."
echo -e "Disclaimer: Please review that code before executing further."

# Function to check the status of installed components
check_status() {
	# Check rEFInd installation
	if sudo test -d "/boot/efi/EFI/refind" || sudo test -d "/boot/EFI/refind"; then
		refind_status="Installed"
	else
		refind_status="Not Installed"
	fi

	# Check refind_banner_update.sh installation
	if [ -f "$HOME/scripts/refind_banner_update/refind_banner_update.sh" ]; then
		banner_status="Installed"
	else
		banner_status="Not Installed"
	fi

	# Check preconfigured refind.conf installation
	if sudo test -f "/boot/efi/EFI/refind/refind.conf.original_backupbyscript"; then
		conf_status="Installed"
	else
		conf_status="Not Installed"
	fi

	# Check rEFInd-Haruhi theme installation
	if sudo test -d "/boot/efi/EFI/refind/themes/rEFInd-Haruhi" || sudo test -d "/boot/EFI/refind/themes/rEFInd-Haruhi"; then
		theme_status="Installed"
	else
		theme_status="Not Installed"
	fi

	# Check Secure Boot status
	sb_status=$(mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled" && echo "Enabled" || echo "Disabled")

	# Check Distro using the 'ID' field and 'ID_LIKE' field from /etc/os-release
	distro=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
	distro_like=$(grep "^ID_LIKE=" /etc/os-release | cut -d'=' -f2 | tr -d '"')

	# List of supported distros
	supported_distros=("fedora" "ubuntu" "debian" "arch")
	
	# Check if distro or distro_like is supported
	if [[ " ${supported_distros[@]} " =~ " ${distro} " ]] || [[ " ${supported_distros[@]} " =~ " ${distro_like} " ]]; then
		distro_status="Supported [$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')]"
	else
		distro_status="Not Supported [$(grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')]"
	fi
}

# Function to display the main menu
display_menu() {
	# Update status before displaying the menu
	check_status

	echo "====== Welcome to rEFInd-Haruhi Install script ======"
	echo "Installation Status:"
	echo "1. rEFInd install: $refind_status"
	echo "2. refind_banner_update.sh install: $banner_status"
	echo "3. Preconfigured refind.conf: $conf_status"
	echo "4. rEFInd-Haruhi: $theme_status"
	echo "5. Secure-Boot: $sb_status"
	echo "6. Distro: $distro_status"
	echo "----------------------------------------------------"
	echo "a. Automatically install all components"
	echo "b. Background List"
	echo "c. Current Installed rEFInd theme"
	echo "d. Delete Haruhi theme"
	echo "e. Edit installation options"
	echo "f. Rollback configuration"
	echo "g. Install selected components"
	echo "q. Exit the program"
	echo "----------------------------------------------------"
}


# Function to install refind_banner_update.sh
install_refind_banner_update() {
	if [ "$banner_status" == "Installed" ]; then
		echo "refind_banner_update.sh is already installed."
	else
		echo "Installing refind_banner_update.sh..."
		mkdir -p "$HOME/scripts/refind_banner_update"
		cp "refind_banner_update.sh" "$HOME/scripts/refind_banner_update/"
	fi
}

# Function to install preconfigured refind.conf
install_preconfigured_conf() {
	if [ "$conf_status" == "Installed" ]; then
		echo "Preconfigured refind.conf is already installed."
	else
		echo "Installing preconfigured refind.conf..."
		sudo cp refind.conf /boot/efi/EFI/refind/refind.conf
	fi
}

# Function to install rEFInd-Haruhi theme
install_haruhi_theme() {
	if [ "$theme_status" == "Installed" ]; then
		echo "rEFInd-Haruhi theme is already installed."
	else
		echo "Installing rEFInd-Haruhi theme..."
		sudo cp -r "themes/rEFInd-Haruhi" "/boot/efi/EFI/refind/themes/"
	fi
}

# Function to install Secure Boot (stubbed for now)
install_secure_boot() {
	echo "Secure Boot installation steps go here..."
}

# Function to list backgrounds
list_backgrounds() {
	# List installed backgrounds if rEFInd-Haruhi theme is installed
	if [ "$theme_status" = "Installed" ]; then
		echo -e "Listing installed rEFInd-Haruhi Backgrounds in ESP:"
		sudo ls -1 /boot/efi/EFI/refind/themes/rEFInd-Haruhi/Background || echo "No installed backgrounds found in ESP."
		echo -e "==============\n"
	fi

	# List available backgrounds in the local directory
	echo "Listing available Haruhi Backgrounds to install..."
	ls -1 themes/rEFInd-Haruhi/Background || echo "No available backgrounds found in the current directory."
	echo -e "==============\n"
}

# Function to display current theme
current_theme() {
	echo "Current Installed rEFInd theme..."
	sudo ls /boot/efi/EFI/refind/themes/
}

# Function to delete Haruhi theme
delete_haruhi_theme() {
	echo "Deleting rEFInd-Haruhi theme..."
	sudo rm -rf "/boot/efi/EFI/refind/themes/rEFInd-Haruhi"
	echo "Haruhi theme deleted."
}

# Function to rollback configuration
rollback_config() {
	echo "Rolling back to default configuration..."
	sudo mv /boot/efi/EFI/refind/refind.conf.haruhi /boot/efi/EFI/refind/refind.conf
}

# Function for edit menu
edit_menu() {
	while true; do
		echo "Toggle (1-5) which component to install:"
		echo "1. rEFInd Boot Manager [$refind_status]"
		echo "2. refind_banner_update.sh [$banner_status]"
		echo "3. Preconfigured refind.conf [$conf_status]"
		echo "4. rEFInd-Haruhi [$theme_status]"
		echo "5. Secure-Boot [$sb_status]"
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
		echo "====================================="
		echo "Result of selected option:"
		echo "====================================="
		sleep 2
		echo
	done
}

# Function to install selected components
install_selected_components() {
	install_refind
	install_refind_banner_update
	install_preconfigured_conf
	install_haruhi_theme
	install_secure_boot
	echo "Installation complete!"
}

# Functions to toggle options
toggle_refind() {
	if [ "$refind_status" == "Installed" ]; then
		refind_status="Not Installed"
	else
		refind_status="Installed"
	fi
}

toggle_banner_update() {
	if [ "$banner_status" == "Installed" ]; then
		banner_status="Not Installed"
	else
		banner_status="Installed"
	fi
}

toggle_conf() {
	if [ "$conf_status" == "Installed" ]; then
		conf_status="Not Installed"
	else
		conf_status="Installed"
	fi
}

toggle_haruhi_theme() {
	if [ "$theme_status" == "Installed" ]; then
		theme_status="Not Installed"
	else
		theme_status="Installed"
	fi
}

toggle_secure_boot() {
	if [ "$sb_status" == "Enabled" ]; then
		sb_status="Disabled"
	else
		sb_status="Enabled"
	fi
}

# Function to install all components
install_all_components() {
	echo "Starting automatic installation of all components..."
	install_refind
	install_refind_banner_update
	install_preconfigured_conf
	install_haruhi_theme
	install_secure_boot
	echo "Installation complete!"
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
