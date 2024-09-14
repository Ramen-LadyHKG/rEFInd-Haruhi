#!/bin/bash
#
# ----- rEFInd_banner_update -----
# ----- Version 4 -----
# ----- Made by Ramen_LadyHKG -----
# ----- Code was optimised with ChatGPT -----
#
#--------------------------------------------------------------
# The BEGIN of USER Preferences
#--------------------------------------------------------------

# Define the path to your theme.conf file (adjust if needed)
#theme_conf="/boot/efi/EFI/refind/themes/rEFInd-Haruhi/theme.conf"

#### DEBUG theme.conf PATH ####
RunUserDir="$(getent passwd $SUDO_USER | cut -d: -f6)"
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

# Define Colours
RED='\033[0;1;4;31m'
DARK_RED='\033[0;1;31m'
GREEN='\033[0;1;4;92m'
YELLOW='\033[0;1;4;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

#--------------------------------------------------------------
# The END of USER Preferences
#--------------------------------------------------------------

#--------------------------------------------------------------
# The BEGIN of Function Define
#--------------------------------------------------------------

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
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
  echo -e "${YELLOW}Current banner path in theme.conf${NC}:${BLUE}\n $current_banner_path"
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message

}

# Function to set the banner based on the weekday number
set_banner_by_weekday() {
  local weekday_num="$1"
  local desired_image="${background_images[$weekday_num]}"

  if sudo sed -i "s|^\s*banner\s\+.*|banner $desired_image|" "$theme_conf"; then
    echo -e "${NC}Setting Banner to (${BLUE}${weekdays[$weekday_num]}${NC})..."
    echo -e "${GREEN}Successfully updated banner to${NC}:\n${BLUE} $desired_image"
    echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
  else
    error_rollback "Failed to update theme.conf"
  fi
}

# Function to check for errors and revert to the original file
error_rollback() {
  echo "Error: $1"
  if [ -f "$backup_file" ]; then
    echo -e "${RED}Reverting to original theme.conf...${NC}"
    echo ""  # Skip a line after the message
    sudo cp "$backup_file" "$theme_conf" || echo "${RED}Failed to revert!${NC}"
  fi
  exit 1
}

# Function to display help message in English (default)
display_help_en() {
  cat << EOF
--------------------------------------------------------------
Usage: ./refind_banner_update.sh [OPTIONS]

Options:
  -s, --set <weekday>
      Set the banner image based on the specified weekday.
      Valid values are: Mon, Tuesday, 0 (for Monday), etc.

  -sh, --set-human-readable <weekday>
      Set the banner image based on the specified human-readable weekday number.
      For example, 1 for Monday, 2 for Tuesday, etc.

  -h, --help
      Display this help message and exit.

  -he, --help-english
      Display this help message in English and exit.

  -hj, --help-japanese
      Display this help message in Japanese and exit.

  -hc, --help-cantonese
      Display this help message in Cantonese (Hong Kong) and exit.

  -htc, --help-traditional-chinese
      Display this help message in Traditional Chinese (Taiwan) and exit.

  -l, --list
      List the available background images and their corresponding weekdays.

  -c, --config
      Display the current banner path in theme.conf.

Description:
  This script updates the banner image in the theme.conf file
  for the rEFInd boot manager based on the current day of the
  week or a user-specified weekday. It backs up the existing
  theme.conf("theme.conf.original") before making any changes. The images are selected
  from the (themes/rEFInd-Haruhi/Background) array according to the weekday.

Notes:
  This script is inspired by the character Haruhi Suzumiya from
  the popular Japanese light novel series "The Melancholy of Haruhi Suzumiya."
  Haruhi's hairstyle changes according to the day of the week:
  - Monday: Long straight hair (Yellow)
  - Tuesday: Ponytail (Red)
  - Wednesday: Two pigtails (Blue)
  - Thursday: Three braids (Green)
  - Friday: Four ribbons (Gold)
  - Saturday: Unknown (Brown)
  - Sunday: Unknown (White)

  For Haruhi, Monday is represented by 0, Tuesday by 1, and so on.
  The colors and hairstyles repeat weekly.

Examples:
  ./refind_banner_update.sh
      Update the banner image based on the current day of the week.

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      Set the banner image to the one for Monday.

  ./refind_banner_update.sh --help
      Display this help message.

Example Color Table:
  Day       | Number | Color
  -------------------------
  Monday    | 0     | Yellow
  Tuesday   | 1     | Red
  Wednesday | 2     | Blue
  Thursday  | 3     | Green
  Friday    | 4     | Gold
  Saturday  | 5     | Brown
  Sunday    | 6     | White

EOF
}

# Function to display help message in Japanese
display_help_jp() {
  cat << EOF

使用法: ./refind_banner_update.sh [OPTIONS]

オプション:
  -s, --set <曜日>
      指定された曜日に基づいてバナー画像を設定します。
      有効な値は: 月曜日、火曜日、0（月曜日用）、などです。

  -sh, --set-human-readable <曜日>
      指定された人間が読める曜日番号に基づいてバナー画像を設定します。
      例えば、1は月曜日、2は火曜日、などです。

  -h, --help
      このヘルプメッセージを表示して終了します。

  -he, --help-english
      英語でこのヘルプメッセージを表示して終了します。

  -hj, --help-japanese
      日本語でこのヘルプメッセージを表示して終了します。

  -hc, --help-cantonese
      広東語（香港）でこのヘルプメッセージを表示して終了します。

  -htc, --help-traditional-chinese
      繁体字中国語（台湾）でこのヘルプメッセージを表示して終了します。

  -l, --list
      利用可能な背景画像とその対応する曜日を表示します。

  -c, --config
      現在のtheme.conf内のバナーのパスを表示します。

説明:
  このスクリプトは、rEFIndブートマネージャのtheme.confファイル内の
  バナー画像を現在の日付またはユーザー指定の曜日に基づいて更新します。
  変更を行う前に既存のtheme.conf("theme.conf.original")をバックアップします。画像は
  曜日に応じて(themes/rEFInd-Haruhi/Background)配列から選択されます。

注意:
  このスクリプトは、人気のライトノベルシリーズ「涼宮ハルヒの憂鬱」の
  キャラクター涼宮ハルヒに触発されています。ハルヒの髪型は曜日によって
  変わります:
  - 月曜日: 長いストレートヘア (黄色)
  - 火曜日: ポニーテール (赤)
  - 水曜日: 2つのポニーテール (青)
  - 木曜日: 3つの編み込み (緑)
  - 金曜日: 4つのリボン (金)
  - 土曜日: 不明な髪型 (茶色)
  - 日曜日: 不明な髪型 (白)

  ハルヒにとって、月曜日は0、火曜日は1と表されます。
  色と髪型は毎週繰り返します。

例:
  ./refind_banner_update.sh
      現在の曜日に基づいてバナー画像を更新します。

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      月曜日用のバナー画像に設定します。

  ./refind_banner_update.sh --help
      このヘルプメッセージを表示します。

例色表:
  曜日       | 数字 | 色
  -------------------------
  月曜日     | 0    | 黄色
  火曜日     | 1    | 赤
  水曜日     | 2    | 青
  木曜日     | 3    | 緑
  金曜日     | 4    | 金
  土曜日     | 5    | 茶色
  日曜日     | 6    | 白

EOF
}

# Function to display help message in Cantonese (Hong Kong)
# 用來顯示香港粵語幫助訊息嘅函數
display_help_hk() {
  cat << EOF
使用方法: ./refind_banner_update.sh [OPTIONS]

選項:
  -s, --set <星期>
      根據指定嘅星期設置橫額圖片。
      有效值包括：星期一、星期二、0（代表星期一）等等。

  -sh, --set-human-readable <星期>
      根據指定嘅人類可讀星期數字設置橫額圖片。
      例如，1 代表星期一，2 代表星期二，等等。

  -h, --help
      顯示呢個幫助訊息並退出。

  -he, --help-english
      顯示呢個幫助訊息（英文）並退出。

  -hj, --help-japanese
      顯示呢個幫助訊息（日文）並退出。

  -hc, --help-cantonese
      顯示呢個幫助訊息（粵語）並退出。

  -htc, --help-traditional-chinese
      顯示呢個幫助訊息（繁體中文）並退出。

  -l, --list
      列出可用嘅背景圖片同埋佢哋對應嘅星期。

  -c, --config
      顯示當前 theme.conf 內的橫額圖片路徑。

描述:
  呢個腳本會根據當前日期或者用戶指定嘅星期去更新 rEFInd 啟動管理器入面
  theme.conf 檔案嘅橫額圖片。腳本會喺進行更改之前備份現有嘅 theme.conf ("theme.conf.original")。
  圖片會根據星期喺 (themes/rEFInd-Haruhi/Background) 陣列中揀選。

注意:
  呢個腳本受日本輕小說系列《涼宮春日的憂鬱》中角色涼宮春日啟發。
  春日嘅髮型會根據星期改變：
  - 星期一: 長直髮 (黃色)
  - 星期二: 馬尾 (紅色)
  - 星期三: 兩個辮子 (藍色)
  - 星期四: 三條辮子 (綠色)
  - 星期五: 四條絲帶 (金色)
  - 星期六: 未知 (棕色)
  - 星期日: 未知 (白色)

  對於春日，星期一係 0，星期二係 1，等等。
  顏色同髮型每星期循環一次。

示例:
  ./refind_banner_update.sh
      根據當前星期更新橫額圖片。

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      設置為星期一嘅橫額圖片。

  ./refind_banner_update.sh --help
      顯示呢個幫助訊息。

顏色示例表:
  星期       | 數字 | 顏色
  -------------------------
  星期一     | 0    | 黃色
  星期二     | 1    | 紅色
  星期三     | 2    | 藍色
  星期四     | 3    | 綠色
  星期五     | 4    | 金色
  星期六     | 5    | 棕色
  星期日     | 6    | 白色

EOF
}

# Function to display help message in Traditional Chinese (Taiwan)
display_help_tc() {
  cat << EOF
使用方法: ./refind_banner_update.sh [OPTIONS]

選項:
  -s, --set <星期>
      根據指定的星期設定橫幅圖片。
      有效值包括：星期一、星期二、0（代表星期一）等等。

  -sh, --set-human-readable <星期>
      根據指定的人類可讀星期數字設定橫幅圖片。
      例如，1 代表星期一，2 代表星期二，等等。

  -h, --help
      顯示此幫助訊息並退出。

  -he, --help-english
      顯示此幫助訊息（英文）並退出。

  -hj, --help-japanese
      顯示此幫助訊息（日文）並退出。

  -hc, --help-cantonese
      顯示此幫助訊息（廣東話）並退出。

  -htc, --help-traditional-chinese
      顯示此幫助訊息（繁體中文）並退出。

  -l, --list
      列出可用的背景圖片及其對應的星期。

  -c, --config
      顯示目前 theme.conf 內的橫幅路徑。

描述:
  此腳本會根據當前日期或用戶指定的星期來更新 rEFInd 啟動管理器的
  theme.conf 文件中的橫幅圖片。腳本會在更改之前備份現有的 theme.conf ("theme.conf.original")。
  圖片會根據星期從 (themes/rEFInd-Haruhi/Background) 陣列中選擇。

注意:
  此腳本受到日本輕小說系列《涼宮春日的憂鬱》中角色涼宮春日的啟發。
  春日的髮型會根據星期改變：
  - 星期一: 長直髮 (黃色)
  - 星期二: 馬尾 (紅色)
  - 星期三: 兩條辮子 (藍色)
  - 星期四: 三條辮子 (綠色)
  - 星期五: 四條絲帶 (金色)
  - 星期六: 未知 (棕色)
  - 星期日: 未知 (白色)

  對於春日來說，星期一是 0，星期二是 1，等等。
  顏色和髮型每週循環一次。

示例:
  ./refind_banner_update.sh
      根據當前星期更新橫幅圖片。

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      設定為星期一的橫幅圖片。

  ./refind_banner_update.sh --help
      顯示此幫助訊息。

顏色示例表:
  星期       | 數字 | 顏色
  -------------------------
  星期一     | 0    | 黃色
  星期二     | 1    | 紅色
  星期三     | 2    | 藍色
  星期四     | 3    | 綠色
  星期五     | 4    | 金色
  星期六     | 5    | 棕色
  星期日     | 6    | 白色

EOF
}

# Function to display help messages
display_help() {
  case "$1" in
    -he|--help-english)
      display_help_en
      ;;
    -hj|--help-japanese)
      display_help_jp
      ;;
    -hc|--help-cantonese)
      display_help_hk
      ;;
    -htc|--help-traditional-chinese)
      display_help_tc
      ;;
    *)
      display_help_en
      ;;
  esac
  exit 0
}

# Function to check if root privileges are required
check_root() {
  if [ "$(id -u)" != "0" ]; then
    echo -e "${YELLOW}This script requires root privileges for this operation.${NC}"
    echo -e "${RED}Attempting to run with sudo...${NC}"
    sudo "$0" "$@"  # Re-run the script with sudo
    exit 0
  fi
}

#--------------------------------------------------------------
# The END of Function Define
#--------------------------------------------------------------

#--------------------------------------------------------------
# The BEGIN of Main Program
#--------------------------------------------------------------

# Handle script parameters
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -s|--set)
      user_input_weekday="$2"
      shift 2
      ;;
    -sh|--set-human-readable)
      user_input_weekday="$(($2-1))"
      shift 2
      ;;
    -l|--list)
      echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
      echo -e "${YELLOW}Available background images and their corresponding weekdays${NC}:"
      for i in "${!background_images[@]}"; do
        echo -e "$i: ${BLUE}${background_images[$i]}${NC}"
      done
      echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
      exit 0
      ;;
    -c|--config)
      display_current_banner
      exit 0
      ;;
    -h|--help|-he|--help-english|-hj|--help-japanese|-hc|--help-cantonese|-htc|--help-traditional-chinese)
      display_help "$1"
      ;;
    *)
      echo -e "${RED}Unknown option${NC}: ${BLUE}$1${NC}"
      exit 1
      ;;
  esac
done

# Check if root privileges are needed
if [[ -z "$user_input_weekday" && ! "$1" =~ ^(help|help-english|help-japanese|help-cantonese|help-traditional-chinese|list|config)$ ]] || \
   [[ "$1" =~ ^(s|set|sh|set-human-readable)$ ]]; then
  echo -e "${YELLOW}This script requires root privileges for this operation.${NC}"
  echo -e "${RED}Attempting to run with sudo...${NC}"
  check_root "$@"
fi

# Only perform the following actions if no options or options requiring root privileges are used
if [[ -z "$user_input_weekday" || "$user_input_weekday" =~ ^[0-6]$ || "$user_input_weekday" =~ ^(mon|monday|Mon|MON|Monday|tue|tuesday|Tue|TUE|Tuesday|wed|wednesday|Wed|WED|Wednesday|thu|thursday|Thu|THU|Thursday|fri|friday|Fri|FRI|Friday|sat|saturday|Sat|SAT|Saturday|sun|sunday|Sun|SUN|Sunday)$ ]]; then
  # Check if theme.conf exists
  if [ ! -f "$theme_conf" ]; then
    error_rollback "theme.conf file not found!"
  fi

  # Backup the original theme.conf
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
  echo -e "${NC}Config's Backup will be saved as ${BLUE}theme.conf.original${NC}"

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
      mon|monday|Mon|MON|Monday|0)
        weekday_number=0
        ;;
      tue|tuesday|Tue|TUE|Tuesday|1)
        weekday_number=1
        ;;
      wed|wednesday|Wed|WED|Wednesday|2)
        weekday_number=2
        ;;
      thu|thursday|Thu|THU|Thursday|3)
        weekday_number=3
        ;;
      fri|friday|Fri|FRI|Friday|4)
        weekday_number=4
        ;;
      sat|saturday|Sat|SAT|Saturday|5)
        weekday_number=5
        ;;
      sun|sunday|Sun|SUN|Sunday|6)
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

#--------------------------------------------------------------
# The END of Main Program
#--------------------------------------------------------------
