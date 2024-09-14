# rEFInd-Haruhi: Dynamic rEFInd Theme with Haruhi Suzumiya and Star Wars Wallpapers

A dynamic rEFInd theme that changes its background daily, inspired by the anime **The Melancholy of Haruhi Suzumiya** and featuring elements from **Star Wars**. The theme automatically switches the background based on the day of the week, much like Haruhi’s changing hairstyles in the anime.

[Discussion thread - Reddit](https://www.reddit.com/r/unixporn/comments/1d4rdh6/refind_my_rice_for_refind_haruhi_suzumiya/) | [Discussion thread - Hong Kong Golden Forum](https://forum.hkgolden.com/thread/7845052/page/14)

## Project Overview

This repository consists of **two main parts**:
1. **The Theme**: A fork of the [rEFInd-ultra theme](https://github.com/JaimeStill/rEFInd-ultra), which has been heavily modified to include a dynamic background system based on *The Melancholy of Haruhi Suzumiya* and *Star Wars* wallpapers.
2. **The Script**: A custom Bash script designed to dynamically modify the `theme.conf` file to update the background image daily or based on the user's input.

### Theme

The theme files handle the visuals for rEFInd, including the customized backgrounds, icons, and layout. These were forked from the original theme and modified to fit the Haruhi Suzumiya and Star Wars style.

### Script

The **`refind_banner_update.sh`** script is designed to:
- Automatically update the `theme.conf` file to set a different background image depending on the current day of the week.
- Be manually triggered to set a specific background for any day chosen by the user.
- Supports multiple languages for help messages.

### Automation & Root Privileges

By itself, the script does not run automatically. While it determines the current day and sets the corresponding background, **manual invocation** by the user is required. However, you can integrate it with system automation tools like:
- **`crontab`**, **`systemd services`**, **`/etc/rc.local`**, or **`/lib/systemd/system-shutdown/`** for automatic daily execution or startup/shutdown routines.

Since the `theme.conf` file is located in the EFI System Partition (ESP), running the script prompts for root privileges to modify the file. This is a normal behavior, as files in the following locations require administrative access:
- **Fedora**: `/boot/efi/EFI/refind`
- **Arch Linux and other distros**: `/boot/EFI/refind`

### Example Commands:

```bash
# Update background based on current day
./refind_banner_update.sh

# Manually set background for Monday
./refind_banner_update.sh -s Monday

# Use human-readable numbers (1 = Monday, 7 = Sunday)
./refind_banner_update.sh -sh 1

# List available backgrounds and corresponding weekdays
./refind_banner_update.sh -l

# Show current configuration in theme.conf
./refind_banner_update.sh -c

