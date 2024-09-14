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

# Function to display help message in English (default)
display_help_en() {
  cat << EOF
Usage: ./refind_banner_update.sh [OPTIONS]

Options:
  -s, --set <weekday>
      Set the banner image based on the specified weekday.
      Valid values are: Mon, Tuesday, 0 (for Monday), etc.
      
  -h, --help
      Display this help message and exit.

  -he, --help_english
      Display this help message in English and exit.

  -hj, --help_japanese
      Display this help message in Japanese and exit.

  -hc, --help_cantonese
      Display this help message in Cantonese (Hong Kong) and exit.

  -htc, --help_traditional_chinese
      Display this help message in Traditional Chinese (Taiwan) and exit.

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
  - Saturday: Loose hair (Brown)
  - Sunday: Short bob (White)

  For Haruhi, Monday is represented by 0, Tuesday by 1, and so on.
  The colors and hairstyles repeat weekly.

Examples:
  ./refind_banner_update.sh
      Update the banner image based on the current day of the week.

  ./refind_banner_update.sh -s Mon
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
      
  -h, --help
      このヘルプメッセージを表示して終了します。

  -he, --help_english
      英語でこのヘルプメッセージを表示して終了します。

  -hj, --help_japanese
      日本語でこのヘルプメッセージを表示して終了します。

  -hc, --help_cantonese
      広東語（香港）でこのヘルプメッセージを表示して終了します。

  -htc, --help_traditional_chinese
      繁体字中国語（台湾）でこのヘルプメッセージを表示して終了します。

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
  - 土曜日: ゆるい髪 (茶色)
  - 日曜日: ショートボブ (白)

  ハルヒにとって、月曜日は0、火曜日は1と表されます。
  色と髪型は毎週繰り返します。

例:
  ./refind_banner_update.sh
      現在の曜日に基づいてバナー画像を更新します。

  ./refind_banner_update.sh -s Mon
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
      
  -h, --help
      顯示呢個幫助訊息並退出。

  -he, --help_english
      顯示呢個幫助訊息（英文）並退出。

  -hj, --help_japanese
      顯示呢個幫助訊息（日文）並退出。

  -hc, --help_cantonese
      顯示呢個幫助訊息（粵語）並退出。

  -htc, --help_traditional_chinese
      顯示呢個幫助訊息（繁體中文）並退出。

描述:
  呢個腳本會根據當前日期或者用戶指定嘅星期去更新rEFInd啟動管理器入面
  theme.conf檔案嘅橫額圖片。腳本喺進行任何更改之前會備份現有嘅
  theme.conf檔案("theme.conf.original")。圖片係根據星期喺(themes/rEFInd-Haruhi/Background)陣列入面揀出嚟嘅。

注意:
  呢個腳本嘅靈感係嚟自日本流行輕小說系列《涼宮春日的憂鬱》入面嘅角色涼宮春日。
  春日嘅髮型會根據星期變化:
  - 星期一: 長直髮 (黃色)
  - 星期二: 馬尾 (紅色)
  - 星期三: 兩條馬尾 (藍色)
  - 星期四: 三條辮仔 (綠色)
  - 星期五: 四條髮帶 (金色)
  - 星期六: 隨意髮型 (啡色)
  - 星期日: 短髮 (白色)

  對於春日嚟講，星期一係0，星期二係1，如此類推。
  顏色同髮型每週重複。

例子:
  ./refind_banner_update.sh
      根據當前嘅星期更新橫額圖片。

  ./refind_banner_update.sh -s Mon
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
  星期六     | 5    | 啡色
  星期日     | 6    | 白色

EOF
}

# Function to display help message in Traditional Chinese (Taiwan)
display_help_tc() {
  cat << EOF
使用方法: ./refind_banner_update.sh [OPTIONS]

選項:
  -s, --set <星期>
      根據指定的星期來設置橫幅圖片。
      有效的值包括：星期一、星期二、0（代表星期一）等。
      
  -h, --help
      顯示此幫助信息並退出。

  -he, --help_english
      顯示此幫助信息（英文）並退出。

  -hj, --help_japanese
      顯示此幫助信息（日文）並退出。

  -hc, --help_cantonese
      顯示此幫助信息（廣東話）並退出。

  -htc, --help_traditional_chinese
      顯示此幫助信息（繁體中文）並退出。

描述:
  此腳本根據當前的日期或用戶指定的星期來更新rEFInd啟動管理器的
  theme.conf檔案中的橫幅圖片。更新前會備份現有的theme.conf("theme.conf.original")。
  圖片從(themes/rEFInd-Haruhi/Background)數組中根據星期選擇。

注意:
  此腳本受到日本流行輕小說系列《涼宮春日的憂鬱》中角色涼宮春日的啟發。
  春日的髮型會根據星期變化:
  - 星期一: 長直髮 (黃色)
  - 星期二: 馬尾 (紅色)
  - 星期三: 兩條馬尾 (藍色)
  - 星期四: 三條辮子 (綠色)
  - 星期五: 四條緞帶 (金色)
  - 星期六: 隨意髮型 (褐色)
  - 星期日: 短髮 (白色)

  對於春日來說，星期一是0，星期二是1，以此類推。
  顏色和髮型每週重複。

例子:
  ./refind_banner_update.sh
      根據當前的星期更新橫幅圖片。

  ./refind_banner_update.sh -s Mon
      設置為星期一的橫幅圖片。

  ./refind_banner_update.sh --help
      顯示此幫助信息。

顏色示例表:
  星期       | 數字 | 顏色
  -------------------------
  星期一     | 0    | 黃色
  星期二     | 1    | 紅色
  星期三     | 2    | 藍色
  星期四     | 3    | 綠色
  星期五     | 4    | 金色
  星期六     | 5    | 褐色
  星期日     | 6    | 白色

EOF
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
  "themes/rEFInd-Haruhi/Background/5-(SAT)-Custom.png"  # Saturday
  "themes/rEFInd-Haruhi/Background/6-(SUN)-Custom.png"  # Sunday
)

# Handle command-line arguments
case "$1" in
  -h|--help)
    display_help_en
    ;;
  -he|--help_english)
    display_help_en
    ;;
  -hj|--help_japanese)
    display_help_jp
    ;;
  -hc|--help_cantonese)
    display_help_hk
    ;;
  -htc|--help_traditional_chinese)
    display_help_tc
    ;;
  -s|--set)
    # Set the banner image based on the specified weekday
    weekday="$2"
    case "$weekday" in
      Mon|Monday|0) img="${background_images[0]}" ;;
      Tue|Tuesday|1) img="${background_images[1]}" ;;
      Wed|Wednesday|2) img="${background_images[2]}" ;;
      Thu|Thursday|3) img="${background_images[3]}" ;;
      Fri|Friday|4) img="${background_images[4]}" ;;
      Sat|Saturday|5) img="${background_images[5]}" ;;
      Sun|Sunday|6) img="${background_images[6]}" ;;
      *) error_rollback "Invalid weekday specified: $weekday" ;;
    esac
    echo "Setting banner image to: $img"
    sudo sed -i "s|^banner=.*|banner=$img|" "$theme_conf"
    ;;
  *)
    echo "Invalid option: $1"
    display_help_en
    ;;
esac

