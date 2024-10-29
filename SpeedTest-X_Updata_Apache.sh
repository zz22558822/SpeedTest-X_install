#!/bin/bash

# 獲取當前腳本的絕對路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "--------------------------------------------"
echo "--->>> 下載更新資料中..."
echo "--------------------------------------------"
sudo wget -O "$SCRIPT_DIR/data.zip" $(curl -s https://api.github.com/repos/zz22558822/SpeedTest-X_install/releases/latest | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)
sudo chmod 755 "$SCRIPT_DIR/data.zip"

# 解壓縮覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 解壓縮更新資料中..."
echo "--------------------------------------------"
sudo mkdir -p "$SCRIPT_DIR/data"
sudo unzip -o "$SCRIPT_DIR/data.zip" -d "$SCRIPT_DIR/data/"
sudo chmod -R 777 "$SCRIPT_DIR/data/"
sudo rm -f "$SCRIPT_DIR/data.zip"

# 覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 正在更新資料..."
echo "--------------------------------------------"
TARGET_DIR="/var/www/html/speedtest-x"

# 確認 data 資料夾是否存在
if [ -d "$SCRIPT_DIR/data" ]; then
    sudo cp "$SCRIPT_DIR/data/index.html" "$TARGET_DIR/index.html"
    sudo cp "$SCRIPT_DIR/data/favicon.ico" "$TARGET_DIR/favicon.ico"
    sudo cp "$SCRIPT_DIR/data/logo.png" "$TARGET_DIR/logo.png"
    sudo cp "$SCRIPT_DIR/data/results.html" "$TARGET_DIR/results.html"
    sudo cp "$SCRIPT_DIR/data/speedtest.js" "$TARGET_DIR/speedtest.js"
	sudo cp "$SCRIPT_DIR/data/report.php" "$TARGET_DIR/backend/report.php"
    sudo cp "$SCRIPT_DIR/data/config.php" "$TARGET_DIR/backend/config.php"
else
    echo "--------------------------------------------"
    echo "--->>> 錯誤：找不到 'data' 資料夾。請確認腳本所在目錄結構正確。"
    echo "--------------------------------------------"
    exit 1
fi

echo "--------------------------------------------"
echo "--->>> 資料更新完成..."
echo "--------------------------------------------"