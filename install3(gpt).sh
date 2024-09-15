#!/bin/bash

# Function to display the main menu
display_menu() {
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

# Function to handle user choices
handle_choice() {
	case "$1" in
		a)
			echo "Installing all components..."
			# Add your installation logic here
			;;
		b)
			# 檢查是否安裝了 rEFInd-Haruhi theme
			if [ "$theme_status" = "Installed" ]; then
				echo -e "Listing installed rEFInd-Haruhi Backgrounds in ESP:"
				# 列出安裝於ESP中的背景圖片
				sudo ls -1 /boot/efi/EFI/refind/themes/rEFInd-Haruhi/Background || echo "No installed backgrounds found in ESP."
				echo -e "==============\n" #分隔線
			fi

			# 列出可安裝的背景圖片
			echo "Listing available Haruhi Backgrounds to install..."
			ls -1 themes/rEFInd-Haruhi/Background || echo "No available backgrounds found in the current directory."
			echo -e "==============\n" #分隔線
			;;
		c)
			echo "Checking current installed rEFInd theme..."
			# Check and list current rEFInd themes
			sudo ls /boot/efi/EFI/refind/themes || echo "No themes found."
			;;
		d)
			echo "Deleting Haruhi theme..."
			# Add your deletion logic here
			;;
		e)
			echo "Entering edit mode..."
			# Add logic to toggle options here
			;;
		f)
			echo "Rolling back to default configuration..."
			# Add your rollback logic here
			;;
		g)
			echo "Installing selected components..."
			# Add your installation logic here
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
	# Display menu
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
