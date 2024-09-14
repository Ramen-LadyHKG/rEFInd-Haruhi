#!/bin/bash

# Define the path to your theme.conf file (adjust if needed)
#theme_conf="/boot/efi/EFI/refind/themes/rEFInd-Haruhi/theme.conf"

#### DEBUG theme.conf PATH ####
if [ "$USER" != "root" ]; then
  RunUserDir="$HOME"
else
  RunUserDir="$(getent passwd $SUDO_USER | cut -d: -f6)"
fi

theme_conf="$RunUserDir/scripts/refind_banner_update/theme.conf"
#### DEBUG theme.conf PATH ####

# Define the backup filename
backup_file="${theme_conf}.original"

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

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
  echo "This script requires root privileges. Attempting to run with sudo..."
  sudo "$0" "$@"
  exit $?
fi

# Check if theme.conf exists
if [ ! -f "$theme_conf" ]; then
  error_rollback "theme.conf file not found!"
fi

# Backup the original theme.conf
if ! cp "$theme_conf" "$backup_file"; then
  error_rollback "Failed to create backup of theme.conf"
fi

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

# Main script logic
user_input_weekday=""

# Handle script parameters
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -s|--set)
      user_input_weekday="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

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
      error_rollback "Invalid weekday input: $user_input_weekday"
      ;;
  esac
fi

# Set the banner based on the determined weekday
set_banner_by_weekday "$weekday_number"
