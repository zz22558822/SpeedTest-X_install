#!/bin/bash

# 獲取當前腳本的絕對路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. 讓用戶選擇端口號
read -p "請輸入要使用的端口號（例如 8080）：" PORT

# 檢查端口號是否為數字，並且在有效範圍內
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "無效的端口號。請輸入 1 到 65535 之間的數字。"
    exit 1
fi

# 2. 更新系統
echo "更新系統..."
sudo apt update && sudo apt upgrade -y

# 3. 安裝 Docker
echo "安裝 Docker及依賴項..."
sudo apt install -y docker.io curl  unzip
sudo systemctl start docker
sudo systemctl enable docker

# 4. 建立資料夾並執行 SpeedTest-X Docker 容器
echo "安裝 SpeedTest-X..."
sudo mkdir -p "/opt/SpeedTest-X"
sudo docker run -d --name SpeedTest-X -p "$PORT:80" -v "/opt/SpeedTest-X:/var/www/html" badapple9/speedtest-x:latest


# 5. 設置權限
echo "正在設定資料權限..."
sudo chmod -R 777 "/opt/SpeedTest-X"

# 6. 下載需要覆蓋檔案
echo "下載更新資料中..."
sudo wget -O "$SCRIPT_DIR/data.zip" $(curl -s https://api.github.com/repos/zz22558822/SpeedTest-X_install/releases/latest | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)
sudo chmod -R 777 "$SCRIPT_DIR/data.zip"

# 7. 解壓縮覆蓋檔案
sudo unzip -o "$SCRIPT_DIR/data.zip" -d "$SCRIPT_DIR/data/"
sudo chmod -R 777 "$SCRIPT_DIR/data/"
sudo rm -f "$SCRIPT_DIR/data.zip"


# 8. 檔案覆蓋
echo "正在更新資料..."
sudo cp "$SCRIPT_DIR/data/index.html" "/opt/SpeedTest-X/index.html"
sudo cp "$SCRIPT_DIR/data/favicon.ico" "/opt/SpeedTest-X/favicon.ico"
sudo cp "$SCRIPT_DIR/data/logo.png" "/opt/SpeedTest-X/logo.png"
sudo cp "$SCRIPT_DIR/data/results.html" "/opt/SpeedTest-X/results.html"
sudo cp "$SCRIPT_DIR/data/speedtest.js" "/opt/SpeedTest-X/speedtest.js"
sudo cp "$SCRIPT_DIR/data/config.php" "/opt/SpeedTest-X/config.php"

# 9. 設定 Docker 自動重啟 SpeedTest-X 容器
echo "正在設置 Docker 容器開機自動啟動..."
sudo docker update --restart unless-stopped SpeedTest-X



echo "SpeedTest-X 安裝完成。"
