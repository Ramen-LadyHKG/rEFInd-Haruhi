#!/bin/bash

# Function to detect ESP mount point
detect_esp() {
    if sudo test -d "/boot/efi/EFI/refind"; then
        ESP_location="/boot/efi/EFI"
    elif sudo test -d "/boot/EFI/refind"; then
        ESP_location="/boot/EFI"
    else
        echo "ESP not found. Please ensure your EFI partition is mounted."
        exit 1
    fi
}

# Detect ESP location at the beginning
detect_esp

# Display welcome message and installation status
echo "====== Welcome to rEFInd-Haruhi Install script ======"
echo ""

# Function to detect rEFInd installation status
detect_refind() {
    if sudo test -d "$ESP_location/refind"; then
        echo "rEFInd install [status: Installed]"
        refind_status="Installed"
    else
        echo "rEFInd install [status: Not Installed]"
        refind_status="Not Installed"
    fi
}

# Function to detect refind_banner_update.sh installation status
detect_banner_update() {
    if test -f "$HOME/scripts/refind_banner_update/refind_banner_update.sh"; then
        echo "refind_banner_update.sh install [status: Installed] ($HOME/scripts/refind_banner_update/refind_banner_update.sh)"
        banner_update_status="Installed"
    else
        echo "refind_banner_update.sh install [status: Not Found]"
        banner_update_status="Not Found"
    fi
}

# Function to detect preconfigured refind.conf
detect_refind_conf() {
    if sudo test -f "$ESP_location/refind/refind.conf.original_backupbyscript"; then
        echo "Preconfigured refind.conf? [Installed]"
        refind_conf_status="Installed"
    else
        echo "Preconfigured refind.conf? [Not Installed]"
        refind_conf_status="Not Installed"
    fi
}

# Function to detect rEFInd-Haruhi theme
detect_theme() {
    if sudo test -d "$ESP_location/refind/themes/rEFInd-Haruhi"; then
        echo "rEFInd-Haruhi: [Installed]"
        theme_status="Installed"
    else
        echo "rEFInd-Haruhi: [Not Installed]"
        theme_status="Not Installed"
    fi
}

# Function to detect Secure-Boot status
detect_secure_boot() {
    sb_status=$(mokutil --sb-state 2>/dev/null)
    if [[ "$sb_status" == *"enabled"* ]]; then
        echo "Secure-Boot: [Enabled]"
        secure_boot_status="Enabled"
    elif [[ "$sb_status" == *"disabled"* ]]; then
        echo "Secure-Boot: [Disabled]"
        secure_boot_status="Disabled"
    else
        echo "Secure-Boot: [UNKNOWN]"
        secure_boot_status="UNKNOWN"
    fi
}

# Display the installation status
detect_refind
detect_banner_update
detect_refind_conf
detect_theme
detect_secure_boot

# Menu system
while true; do
    echo ""
    echo "Select an option:"
    echo "a. Automatically install all components"
    echo "b. Background List (by listing themes/rEFInd-Haruhi/Background)"
    echo "c. Current Installed rEFInd theme"
    echo "d. Delete Haruhi theme from your rEFInd theme directory"
    echo "e. Edit installation components"
    echo "f. Rollback to default configuration"
    echo "g. Install the selected components"
    echo "q. Exit the program"
    read -p "Enter your choice: " choice

    case $choice in
        a)
            echo "Automatically installing all components..."
            # Add installation commands for rEFInd, banner, conf, theme, etc.
            ;;
        b)
            echo "Listing backgrounds..."
            ls "$ESP_location/refind/themes/rEFInd-Haruhi/Background"
            ;;
        c)
            echo "Checking current installed rEFInd theme..."
            ls "$ESP_location/refind/themes/"
            ;;
        d)
            echo "Deleting Haruhi theme..."
            sudo rm -rf "$ESP_location/refind/themes/rEFInd-Haruhi"
            ;;
        e)
            echo "Edit installation components"
            echo "1. rEFInd installation: $refind_status"
            echo "2. refind_banner_update.sh installation: $banner_update_status"
            echo "3. Preconfigured refind.conf: $refind_conf_status"
            echo "4. rEFInd-Haruhi theme: $theme_status"
            echo "5. Secure Boot: $secure_boot_status"
            read -p "Select a number to edit (1-5): " edit_choice
            # Add logic to modify the selected component status
            ;;
        f)
            echo "Rolling back to default configuration..."
            sudo mv "$ESP_location/refind/refind.conf" "$ESP_location/refind/refind.conf.haruhi"
            sudo mv "$ESP_location/refind/refind.conf.original_backupbyscript" "$ESP_location/refind/refind.conf"
            ;;
        g)
            echo "Installing selected components..."
            # Add installation commands for selected components
            ;;
        q)
            echo "Exiting the program."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
