#!/bin/bash
#
# ----- rEFInd_banner_update -----
# ----- Version 6 -----
# ----- Made by Ramen_LadyHKG -----
# ----- Code was optimised with ChatGPT -----
#
#--------------------------------------------------------------
# The BEGIN of USER Preferences
#--------------------------------------------------------------



# Define the path to your theme.conf file (adjust if needed)
#theme_conf="/boot/efi/EFI/refind/themes/rEFInd-Haruhi/theme.conf"
#Background_Dir="/boot/efi/EFI/refind/themes/rEFInd-Haruhi/Background"

#### DEBUG theme.conf PATH ####
if [ "$USER" != "root" ]; then
  RunUserDir="$HOME"
else
  RunUserDir="$(getent passwd $SUDO_USER | cut -d: -f6)"
fi

theme_conf="$RunUserDir/scripts/refind_banner_update/themes/rEFInd-Haruhi/theme.conf"
Background_Dir="$RunUserDir/scripts/refind_banner_update/themes/rEFInd-Haruhi/Background"
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

# Define version of the script
version="6"

#--------------------------------------------------------------
# The END of USER Preferences
#--------------------------------------------------------------

#--------------------------------------------------------------
# The BEGIN of Function Define
#--------------------------------------------------------------

# Preserve arguments in case while loop erase $@
saved_args=("$@")

# Function to get the current weekday (0-based, with 0 as Monday)
get_weekday_number() {
  local day
  day=$(date +%u)  # %u gives 1 (Monday) to 7 (Sunday)
  echo $((day - 1))  # Convert to 0-based (0=Monday, 6=Sunday)
}

# Function to display the current banner path from theme.conf
display_current_banner() {
  local current_banner_path
  echo -e "${YELLOW}This script requires root privileges for this operation.${NC}"
  echo -e "${RED}Attempting to run with sudo...${NC}"
  current_banner_path=$(sudo grep -Eo '^\s*banner\s+(.+)' "$theme_conf" | awk '{print $2}')
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
  echo -e "${YELLOW}Current banner path in theme.conf${NC}:${BLUE}\n $current_banner_path"
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
}

list_absolute_path() {
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
  echo -e "${YELLOW}Current Configuration ${NC}:"
  for i in "${!background_images[@]}"; do
      echo -e "$i: ${BLUE}${background_images[$i]}${NC}"
      done
  echo -e "${DARK_RED}--------------------------------------------------------------"  # Separate message
  echo -e "\n${YELLOW}This script requires root privileges for this operation.${NC}"
  echo -e "${RED}Attempting to run with sudo...${NC}"
  echo -e "\n${YELLOW}Absolute Path to the Backgrounds${NC}:"
  sudo find $Background_Dir  -maxdepth 1 -type f | sort -V
}
  

# Function to set the banner based on the weekday number
set_banner_by_weekday() {
  local weekday_num="$1"
  local desired_image="${background_images[$weekday_num]}"
  
##### DEBUG variables: will be removed ######
echo "5th_weekday_number = $weekday_number"
echo "5th_weekday_num = $weekday_num"
echo "commmand line = $0"

echo "arguements = $@"
echo "saved_args = ${saved_args[@]}"
echo "unknown = $#"
echo ""
##### DEBUG variables: will be removed ######

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
  if sudo test -f "$backup_file" ; then
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
Usage: ./refind_banner_update.sh [options]

[Options]:
(Update rEFInd banner configuration)
  No options
      Updates the background image based on the current <day of the week>.

  -s, --set <day of the week>
      Sets the background image according to the specified <day of the week>.
      Valid values include: mon, monday, Mon, MON, Monday, 0 (for Monday), etc.

  -sh, --set-human-readable <weekday number>
      Sets the banner image according to the specified human-readable <weekday number>.
      For example, 1 for Monday, 2 for Tuesday, and so on. (Valid values are [1~7])

(Current Settings / Status)
  -c, --config
      Displays the current background image path in theme.conf.

  -l, --list
      Lists available background images and their corresponding days.

  -lp, --list-absolute-path
      Lists available background images' <absolute paths> and their corresponding days.

  -v, --version
      Displays the script version.

(Help / Manual / How to use?)
  -h, --help
      Displays this help message and exits.

  -he, --help-english
      Displays this help message in English and exits.

  -hj, --help-japanese
      Displays this help message in Japanese and exits.

  -hc, --help-cantonese
      Displays this help message in Cantonese (Hong Kong) and exits.

  -htc, --help-traditional-chinese
      Displays this help message in Traditional Chinese (Taiwan) and exits.

[Description]:
  This script updates the rEFInd boot manager's banner image in the theme.conf file based on the current date or user-specified day of the week. The script backs up the existing theme.conf ("theme.conf.original") before making any changes. Images are selected from the (themes/rEFInd-Haruhi/Background) array according to the day of the week.

[Note]:
  This script is inspired by the character Haruhi Suzumiya from the popular Japanese light novel series "The Melancholy of Haruhi Suzumiya". Haruhi's hairstyle changes according to the day of the week:
  - Monday: Long straight hair (Yellow)
  - Tuesday: Ponytail (Red)
  - Wednesday: Two pigtails (Blue)
  - Thursday: Three braids (Green)
  - Friday: Four ribbons (Gold)
  - Saturday: Unknown (Brown)
  - Sunday: Unknown (White)

  For Haruhi, Monday is 0, Tuesday is 1, and so on.
  The color and hairstyle repeat weekly.

[Examples]:
  ./refind_banner_update.sh
      Updates the banner image based on the current <day of the week>.

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      Sets the background image to <Monday>.

  ./refind_banner_update.sh --help
      Displays this help message (in English).

[Color Example Table]:
  Day       | Number | Color
  -------------------------
  Monday    | 0      | Yellow
  Tuesday   | 1      | Red
  Wednesday | 2      | Blue
  Thursday  | 3      | Green
  Friday    | 4      | Gold
  Saturday  | 5      | Brown
  Sunday    | 6      | White

EOF
}

# Function to display help message in Japanese
display_help_jp() {
  cat << EOF
--------------------------------------------------------------
使い方: ./refind_banner_update.sh [オプション]

[オプション]:
(rEFInd バナー設定の更新)
  オプションなし
      現在の<曜日>に基づいて背景画像を更新します。

  -s, --set <曜日>
      指定された<曜日>に基づいて背景画像を設定します。
      有効な値には、mon、monday、Mon、MON、Monday、0 (月曜日を表す) などが含まれます。

  -sh, --set-human-readable <曜日番号>
      指定された人間が読める<曜日番号>に基づいてバナー画像を設定します。
      例として、月曜日は1、火曜日は2、などがあります。(有効な値は[1~7])

(現在の設定 / 状態)
  -c, --config
      現在の theme.conf 内の背景画像パスを表示します。

  -l, --list
      使用可能な背景画像とその曜日をリスト表示します。

  -lp, --list-absolute-path
      使用可能な背景画像の<絶対パス>とその曜日をリスト表示します。

  -v, --version
      スクリプトのバージョンを表示します。

(ヘルプ / マニュアル / 使用方法)
  -h, --help
      このヘルプメッセージを表示して終了します。

  -he, --help-english
      (英語)でこのヘルプメッセージを表示して終了します。

  -hj, --help-japanese
      (日本語)でこのヘルプメッセージを表示して終了します。

  -hc, --help-cantonese
      (広東語[香港])でこのヘルプメッセージを表示して終了します。

  -htc, --help-traditional-chinese
      (繁体字中国語[台湾])でこのヘルプメッセージを表示して終了します。

[説明]:
  このスクリプトは、現在の日付またはユーザー指定の曜日に基づいて rEFInd ブートマネージャーのバナー画像を theme.conf ファイルで更新します。スクリプトは変更を行う前に既存の theme.conf をバックアップします ("theme.conf.original")。画像は曜日に応じて (themes/rEFInd-Haruhi/Background) 配列から選択されます。

[注意]:
  このスクリプトは、日本の人気ライトノベルシリーズ「涼宮ハルヒの憂鬱」のキャラクター涼宮ハルヒからインスパイアされています。ハルヒの髪型は曜日に応じて変わります：
  - 月曜日: (黄色)|長いストレートヘア
  - 火曜日: (赤)|ポニーテール
  - 水曜日: (青)|2つのツインテール
  - 木曜日: (緑)|3つの三つ編み
  - 金曜日: (金)|4つのリボン
  - 土曜日: (茶色)|不明
  - 日曜日: (白)|不明

  ハルヒにとって、月曜日は0、火曜日は1、などになります。
  色と髪型は週ごとに繰り返されます。

[例]:
  ./refind_banner_update.sh
      現在の<曜日>に基づいてバナー画像を更新します。

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      背景画像を<月曜日>に設定します。

  ./refind_banner_update.sh --help
      このヘルプメッセージを表示します（英語）。

[色の例表]:
  曜日     | 数字 | 色
  -------------------------
  月曜日  | 0    | 黄色
  火曜日  | 1    | 赤
  水曜日  | 2    | 青
  木曜日  | 3    | 緑
  金曜日  | 4    | 金
  土曜日  | 5    | 茶色
  日曜日  | 6    | 白

EOF
}


# Function to display help message in Cantonese (Hong Kong)
display_help_hk() {
  cat << EOF
--------------------------------------------------------------
使用方法: ./refind_banner_update.sh [選項]

【選項】:
(更新 rEFInd 標誌配置)
  無選項
      根據當前嘅<星期幾>去更新背景圖片。

  -s, --set <星期幾>
      根據指定嘅<星期幾>去設置背景圖片。
      有效值包括: mon、monday、Mon、MON、Monday、0 (代表星期一) 等等。

  -sh, --set-human-readable <星期幾>
      根據指定嘅人類可讀<星期數字>設置橫額圖片。
      例如，星期一為1，星期二為2，等等。(有效值包括[1~7])

(當前設置 / 狀態)
  -c, --config
      顯示當前 theme.conf 內嘅背景圖片路徑。

  -l, --list
      列出可用嘅背景圖片同埋佢哋對應嘅星期。

  -lp, --list-absolute-path
      列出可用嘅背景圖片嘅<絕對路徑>同埋佢哋對應嘅星期。

  -v, --version
      顯示腳本嘅版本。

(幫助 / 手冊 / 如何使用?)
  -h, --help
      顯示呢個幫助信息並退出。

  -he, --help-english
      以(英語)顯示呢個幫助信息並退出。

  -hj, --help-japanese
      以(日語)顯示呢個幫助信息並退出。

  -hc, --help-cantonese
      以(廣東話[香港])顯示呢個幫助信息並退出。

  -htc, --help-traditional-chinese
      以(繁體字中文[臺灣])顯示呢個幫助信息並退出。

【描述】:
  呢個腳本會根據當前日期或者用戶指定嘅星期去更新 rEFInd 啟動管理器入面
  theme.conf 檔案嘅橫額圖片。腳本會喺進行更改之前備份現有嘅 theme.conf ("theme.conf.original")。
  圖片會根據星期喺 (themes/rEFInd-Haruhi/Background) 陣列中揀選。

【注意】:
  呢個腳本係受日本知名輕小說系列《涼宮春日的憂鬱》中嘅角色涼宮春日所啟發嘅。
  春日嘅髮型會根據星期改變：
  - 星期一: (黃色)|長直髮
  - 星期二: (紅色)|馬尾
  - 星期三: (藍色)|兩個雙馬尾
  - 星期四: (綠色)|三條辮仔
  - 星期五: (金色)|四條絲帶
  - 星期六: (啡色)|未知
  - 星期天: (白色)|未知

  對於春日，星期一係 0，星期二係 1，等等。
  顏色同髮型每星期循環一次。

【範例】:
  ./refind_banner_update.sh
      根據當前<星期幾>去更新標誌圖片。

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
      設置為<星期一>嘅背景圖片。

  ./refind_banner_update.sh --help
      顯示呢個幫助信息(英文)。

【顏色範例表】:
  星期       | 數字 | 顏色
  -------------------------
  星期一    | 0     | 黃色
  星期二    | 1     | 紅色
  星期三    | 2     | 藍色
  星期四    | 3     | 綠色
  星期五    | 4     | 金色
  星期六    | 5     | 啡色
  星期天    | 6     | 白色

EOF
}

# Function to display help message in Traditional Chinese (Taiwan)
display_help_tc() {
  cat << EOF
--------------------------------------------------------------
使用方法: ./refind_banner_update.sh [選項]

[選項]:
(更新 rEFInd 標誌配置)
  無選項
      根據當前的<星期幾>去更新背景圖片。

  -s, --set <星期幾>
      根據指定的<星期幾>去設置背景圖片。
      有效值包括: mon、monday、Mon、MON、Monday、0 (代表星期一) 等等。

  -sh, --set-human-readable <星期數字>
      根據指定的可讀<星期數字>設置橫幅圖片。
      例如，星期一為1，星期二為2，等等。(有效值包括[1~7])

(當前設置 / 狀態)
  -c, --config
      顯示當前 theme.conf 內的背景圖片路徑。

  -l, --list
      列出可用的背景圖片及其對應的星期。

  -lp, --list-absolute-path
      列出可用的背景圖片中的<絕對路徑>以及它們對應的星期。

  -v, --version
      顯示腳本的版本。

(幫助 / 手冊 / 如何使用?)
  -h, --help
      顯示此幫助信息並退出。

  -he, --help-english
      以(英語)顯示此幫助信息並退出。

  -hj, --help-japanese
      以(日語)顯示此幫助信息並退出。

  -hc, --help-cantonese
      以(廣東話[香港])顯示此幫助信息並退出。

  -htc, --help-traditional-chinese
      以(繁體字中文[臺灣])顯示此幫助信息並退出。

【描述】:
  此腳本會根據當前日期或用戶指定的星期來更新 rEFInd 啟動管理器的
  theme.conf 文件中的橫幅圖片。腳本會在更改之前備份現有的 theme.conf ("theme.conf.original")。
  圖片會根據星期從 (themes/rEFInd-Haruhi/Background) 陣列中選擇。

【注意】:
  此腳本是受到日本知名輕小說系列《涼宮春日的憂鬱》中角色涼宮春日所啟發的。
  春日的髮型會根據星期改變：
  - 星期一: (黃色)|長直髮
  - 星期二: (紅色)|馬尾
  - 星期三: (藍色)|兩條雙馬尾
  - 星期四: (綠色)|三條辮子
  - 星期五: (金色)|四條緞帶
  - 星期六: (棕色)|未知
  - 星期天: (白色)|未知

  對於春日，星期一係 0，星期二係 1，等等。
  顏色同髮型每星期循環一次。

【示例】:
  ./refind_banner_update.sh
      	根據當前<星期幾>去更新標誌圖片。

  ./refind_banner_update.sh -s 0
  ./refind_banner_update.sh -s Monday
  ./refind_banner_update.sh -s Mon
  ./refind_banner_update.sh -sh 1
	設置為<星期一>的背景圖片。

  ./refind_banner_update.sh --help
      	顯示此幫助信息(英文)。

【顏色範例表】:
  星期       | 數字 | 顏色
  -------------------------
  星期一    | 0     | 黃色
  星期二    | 1     | 紅色
  星期三    | 2     | 藍色
  星期四    | 3     | 綠色
  星期五    | 4     | 金色
  星期六    | 5     | 棕色
  星期天    | 6     | 白色

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
    sudo "$0" "${saved_args[@]}"  # Re-run the script with sudo
    exit 0
  fi
}

#--------------------------------------------------------------
# The END of Function Define
#--------------------------------------------------------------

#--------------------------------------------------------------
# The BEGIN of Main Program
#--------------------------------------------------------------

##### DEBUG variables: will be removed ######
echo "1st_weekday_number = $weekday_number"
echo "1st_weekday_num = $weekday_num"
echo "1st_commmand line = $0"

echo "1st_arguements = $@"
echo "1st_saved_args = ${saved_args[@]}"
echo "1st_unknown = $#"
echo ""
##### DEBUG variables: will be removed ######

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
    -lp|--list-path)
      list_absolute_path
      exit 0
      ;;
    -c|--config)
      display_current_banner
      exit 0
      ;;
    -v|--version)
      echo -e "${DARK_RED}--------------------------------------------------------------${NC}"  # Separate message
      echo -e "${YELLOW}Current Version${NC}: ${BLUE}$version${NC}"
      echo -e "${DARK_RED}--------------------------------------------------------------${NC}"  # Separate message
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

##### DEBUG variables: will be removed ######
echo "2nd_weekday_number = $weekday_number"
echo "2nd_weekday_num = $weekday_num"
echo "2nd_commmand line = $0"

echo "2nd_arguements = $@"
echo "2nd_saved_args = ${saved_args[@]}"
echo "2nd_unknown = $#"
echo ""
##### DEBUG variables: will be removed ######

# Check if root privileges are needed
if [[ -z "$user_input_weekday" && ! "$1" =~ ^(help|help-english|help-japanese|help-cantonese|help-traditional-chinese|list|config)$ ]]; then

##### DEBUG variables: will be removed ######
echo "3rd_weekday_number = $weekday_number"
echo "3rd_weekday_num = $weekday_num"
echo "3rd_commmand line = $0"

echo "3rd_arguements = $@"
echo "3rd_saved_args = ${saved_args[@]}"
echo "3rd_unknown = $#"
echo ""
##### DEBUG variables: will be removed ######

	weekday_number=$(get_weekday_number)

elif [[ "$user_input_weekday" =~ ^[0-6]$ || "$user_input_weekday" =~ ^(mon|monday|Mon|MON|Monday|tue|tuesday|Tue|TUE|Tuesday|wed|wednesday|Wed|WED|Wednesday|thu|thursday|Thu|THU|Thursday|fri|friday|Fri|FRI|Friday|sat|saturday|Sat|SAT|Saturday|sun|sunday|Sun|SUN|Sunday)$ ]]; then

##### DEBUG variables: will be removed ######
echo "4th_weekday_number=$weekday_number"
echo "4th_weekday_num=$weekday_num"
echo "4th_commmand line = $0"

echo "4th_arguements = $@"
echo "4th_saved_args = ${saved_args[@]}"
echo "4th_unknown = $#"
echo ""
##### DEBUG variables: will be removed ######	      

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
else
	echo "Invalid option or argument. Use -h for help."
	exit 1
fi   
    check_root "$@"
    
  # Check if theme.conf exists
  if ! sudo test -f "$theme_conf" ; then
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

  # Set the banner based on the determined weekday number
  set_banner_by_weekday "$weekday_number"


#--------------------------------------------------------------
# The END of Main Program
#--------------------------------------------------------------
