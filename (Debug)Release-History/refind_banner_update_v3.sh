#!/bin/bash

# Define the path to your theme.conf file (adjust if needed)
#theme_conf="/boot/efi/EFI/refind/themes/rEFInd-Haruhi/theme.conf"

#### DEBUG theme.conf PATH ####
if [ "$USER" != "root" ]; then
  RunUserDir="$HOME"
else
  RunUserDir="$(getent passwd $SUDO_USER | cut -d: -f6)"
fi
theme_conf="$RunUserDir/scripts/refind_banner_update/themes/rEFInd-Haruhi/theme.conf"
#### DEBUG theme.conf PATH ####

# Define the backup filename
backup_file="${theme_conf}.original"

# Define weekday image paths (adjusted for 0-based indexing, where 0 = Monday)
background_images=(
  "themes/rEFInd-Haruhi/Background/0-(MON)-Original.png"  # Monday
  "themes/rEFInd-Haruhi/Background/1-(TUE)-Haruhi_Kyon.png"  # Tuesday
  "themes/rEFInd-Haruhi/Background/2-(WED)-Haruhi_left_corner-tree.png"  # Wednesday
  "themes/rEFInd-Haruhi/Background/3-(THU)-Haruhi_middle_galaxy.png"  # Thursday
  "themes/rEFInd-Haruhi/Background/4-(FRI)-Anakin.png"  # Friday
  "themes/rEFInd-Haruhi/Background/5-(SAT)-BinarySunset.png"  # Saturday
  "themes/rEFInd-Haruhi/Background/6-(SUN)-Kyon-Yuki.png"  # Sunday
)

# Define weekday names for display
weekdays=("Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday")

# Function to get the current weekday (0-based, with 0 as Monday)
get_weekday_number() {
  local day
  day=$(date +%u)  # %u gives 1 (Monday) to 7 (Sunday)
  echo $((day - 1))  # Convert to 0-based (0=Monday, 6=Sunday)
}

# Function to display the current banner path from theme.conf
display_current_banner() {
  local current_banner_path
  current_banner_path=$(grep -Eo '^\s*banner\s+(.+)' "$theme_conf" | awk '{print $2}')
  echo "Current banner path in theme.conf: $current_banner_path"
}

# Function to set the banner based on the weekday number
set_banner_by_weekday() {
  local weekday_num="$1"
  local desired_image="${background_images[$weekday_num]}"

  if sudo sed -i "s|^\s*banner\s\+.*|banner $desired_image|" "$theme_conf"; then
    echo "Successfully updated banner to: $desired_image"
    echo ""  # Skip a line after the success message
  else
    error_rollback "Failed to update theme.conf"
  fi
}

# Function to check for errors and revert to the original file
error_rollback() {
  echo "Error: $1"
  if [ -f "$backup_file" ]; then
    echo "Reverting to original theme.conf..."
    echo ""  # Skip a line after the message
    sudo cp "$backup_file" "$theme_conf" || echo "Failed to revert!"
  fi
  exit 1
}

# Function to display help message in English (default)
display_help_en() {
  cat << EOF
"... skipped English"
EOF
}

# Function to display help message in Japanese
display_help_jp() {
  cat << EOF
"... skipped Japanese"
EOF
}

# Function to display help message in Cantonese (Hong Kong)
display_help_hk() {
  cat << EOF
"... skipped Cantonese"
EOF
}

# Function to display help message in Traditional Chinese (Taiwan)
display_help_tc() {
  cat << EOF
"... skipped Traditional Chinese"
EOF
}

# Function to check if root privileges are required
check_root() {
  if [ "$(id -u)" != "0" ] && [[ "$1" =~ ^(set|set-human-readable|config)$ ]]; then
    echo "This script requires root privileges for the option $1. Attempting to run with sudo..."
    sudo "$0" "$@"  # Re-run the script with sudo
    exit 0
  fi
}

# Handle script parameters
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -s|--set)
      user_input_weekday="$2"
      check_root "set"
      shift 2
      ;;
    -sh|--set-human-readable)
      user_input_weekday="$2"
      check_root "set-human-readable"
      shift 2
      ;;
    -l|--list)
      echo "Available background images and their corresponding weekdays:"
      for i in "${!background_images[@]}"; do
        echo "$i: ${background_images[$i]}"
      done
      exit 0
      ;;
    -c|--config)
      display_current_banner
      exit 0
      ;;
    -h|--help)
      display_help_en
      exit 0
      ;;
    -he|--help-english)
      display_help_en
      exit 0
      ;;
    -hj|--help-japanese)
      display_help_jp
      exit 0
      ;;
    -hc|--help-cantonese)
      display_help_hk
      exit 0
      ;;
    -htc|--help-traditional-chinese)
      display_help_tc
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Only perform the following actions if no options or options requiring root privileges are used
if [[ -z "$user_input_weekday" || "$user_input_weekday" =~ ^[0-6]$ || "$user_input_weekday" =~ ^(mon|Mon|Monday|tue|Tue|Tuesday|wed|Wed|Wednesday|thu|Thu|Thursday|fri|Fri|Friday|sat|Sat|Saturday|sun|Sun|Sunday)$ ]]; then
  # Check if theme.conf exists
  if [ ! -f "$theme_conf" ]; then
    error_rollback "theme.conf file not found!"
  fi

  # Backup the original theme.conf
  if ! sudo cp "$theme_conf" "$backup_file"; then
    error_rollback "Failed to create backup of theme.conf"
  fi

  # Display current banner path
  display_current_banner

  # Determine the weekday to set
  if [[ -z "$user_input_weekday" ]]; then
    # If no user input, use current day
    weekday_number=$(get_weekday_number)
  else
    # Handle user input: string (Mon, Monday, etc.) or number
    case "$user_input_weekday" in
      mon|Mon|Monday|0)
        weekday_number=0
        ;;
      tue|Tue|Tuesday|1)
        weekday_number=1
        ;;
      wed|Wed|Wednesday|2)
        weekday_number=2
        ;;
      thu|Thu|Thursday|3)
        weekday_number=3
        ;;
      fri|Fri|Friday|4)
        weekday_number=4
        ;;
      sat|Sat|Saturday|5)
        weekday_number=5
        ;;
      sun|Sun|Sunday|6)
        weekday_number=6
        ;;
      *)
        echo "Invalid weekday input: $user_input_weekday"
        exit 1
        ;;
    esac
  fi

  # Set the banner based on the determined weekday number
  set_banner_by_weekday "$weekday_number"
else
  echo "Invalid option or argument. Use -h for help."
  exit 1
fi

