#!/bin/bash

# Installation prompts
echo -e "This script will perform the following actions:"
echo -e " 1. Create a directory: $HOME/scripts/refind_banner_update"
echo -e " 2. Copy the 'refind_banner_update.sh' script to: $HOME/scripts/refind_banner_update/"
echo -e " 3. Install the 'rEFInd-Haruhi' theme to your rEFInd theme directory"
echo -e " 4. Optionally install a preconfigured 'refind.conf' to your ESP"
echo -e " 5. Backup existing 'refind.conf' (if present) to 'refind.conf.original_backupbyscript'"
echo -e " 6. Copy the new 'refind.conf' to the appropriate directory"
echo -e ""

# Proceed confirmation
read -p "Do you want to proceed? (yes/no) " yn
case "${yn,,}" in  # Convert input to lowercase for consistency
        yes ) echo -e "Ok, proceeding with installation...\n";;
        no ) echo -e "Installation cancelled. Exiting the program..."; exit;;
        * ) echo -e "Invalid response. Exiting the program..."; exit 1;;
esac

# Check for root privileges
if [ "$USER" == "root" ]; then
        echo -e "Do not run this script as root. Exiting the program..."
        exit 1
fi

# Create the scripts directory if it doesn't exist
if [ ! -d "$HOME/scripts" ]; then
        echo -e "Creating directory: $HOME/scripts..."
        mkdir -p "$HOME/scripts"
else
        echo -e "Directory $HOME/scripts already exists."
fi

# Create refind_banner_update directory and copy the script
if [ ! -d "$HOME/scripts/refind_banner_update" ]; then
        echo -e "Copying 'refind_banner_update.sh' to $HOME/scripts/refind_banner_update..."
        mkdir "$HOME/scripts/refind_banner_update/"
        cp "refind_banner_update.sh" "$HOME/scripts/refind_banner_update/refind_banner_update.sh"
else
        echo -e "'refind_banner_update' is already installed. Exiting the program..."
        exit 1
fi

# rEFInd theme installation
echo -e "Installing the 'rEFInd-Haruhi' theme to your rEFInd theme directory..."

# Check for ESP directories and install the theme
ESP_DIRS=("/boot/efi/EFI/refind" "/boot/EFI/refind")
REFIND_INSTALLED=false

for ESP_DIR in "${ESP_DIRS[@]}"; do
        if sudo test -d "$ESP_DIR"; then
                REFIND_INSTALLED=true
                THEME_DIR="$ESP_DIR/themes/rEFInd-Haruhi"
                if sudo test -d "$THEME_DIR"; then
                        echo -e "'rEFInd-Haruhi' theme is already installed. No further action is needed."
                else
                        echo -e "Copying the 'rEFInd-Haruhi' theme to $ESP_DIR/themes..."
                        sudo mkdir -p "$ESP_DIR/themes"
                        sudo cp -r "themes/rEFInd-Haruhi" "$ESP_DIR/themes/"
                        echo -e "'rEFInd-Haruhi' has been successfully installed to your ESP."
                fi
        fi
done

# If rEFInd is not installed, prompt the user to install it
if [ "$REFIND_INSTALLED" = false ]; then
        echo -e "ERROR: rEFInd is not installed on your system."
        read -p "Would you like to install rEFInd now? (YES/NO) " install_refind

        case "$install_refind" in
                YES ) echo -e "Proceeding with rEFInd installation...\n";
                      sudo apt install refind;  # For Debian/Ubuntu-based systems
                      ;;
                NO )  echo -e "Please install rEFInd manually before running this script again. Exiting...";
                      exit 1;;
                * )   echo -e "Invalid response. Please enter YES or NO."; exit 1;;
        esac
fi

# Prompt to install the preconfigured refind.conf
echo -e "We have a preconfigured rEFInd configuration file."
echo -e "Would you like to install it to your ESP/rEFInd/refind.conf?"
read -p "Do you want to proceed? (YES/NO) " YN

case "$YN" in
        YES ) echo -e "Proceeding with refind.conf installation...\n";;
        NO ) echo -e "Installation of refind.conf skipped. Thank you for using this script. Exiting..."; exit;;
        * ) echo -e "Invalid response. Please enter YES or NO."; exit 1;;
esac

# Backup and install refind.conf
REFIND_CONF="$ESP_DIR/refind/refind.conf"
if sudo test -f "$REFIND_CONF"; then
        echo -e "Backing up the existing refind.conf to refind.conf.original_backupbyscript..."
        sudo cp "$REFIND_CONF" "${REFIND_CONF}.original_backupbyscript"
fi
sudo cp "refind.conf" "$REFIND_CONF"
echo -e "Preconfigured refind.conf has been successfully copied to $REFIND_CONF."
