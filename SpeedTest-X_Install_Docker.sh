#!/bin/bash

# 獲取當前腳本的絕對路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. 讓用戶選擇端口號
echo "--------------------------------------------"
while true; do
    read -p "--->>> 請輸入 Docker 服務的 Port (預設 8080): " USER_PORT
    USER_PORT=${USER_PORT:-8080}  # 若未輸入則設置為 8080

    # 檢查輸入的 Port 是否為有效的數字且在範圍內
    if [[ "$USER_PORT" =~ ^[0-9]+$ ]] && ((USER_PORT >= 1 && USER_PORT <= 65535)); then
        echo "--->>> 使用的 Port 為：$USER_PORT"
        break
    else
        echo "無效的 Port，請輸入介於 1-65535 之間的數字。"
    fi
done

# 2. 更新系統
echo "--------------------------------------------"
echo "--->>> 更新系統..."
echo "--------------------------------------------"
sudo apt update && sudo apt upgrade -y

# 3. 安裝 Docker
echo "--------------------------------------------"
echo "--->>> 安裝 Docker及依賴項..."
echo "--------------------------------------------"
sudo apt install -y docker.io curl  unzip
sudo systemctl start docker
sudo systemctl enable docker

# 4. 建立資料夾並執行 SpeedTest-X Docker 容器
echo "--------------------------------------------"
echo "--->>> 正在安裝 SpeedTest-X..."
echo "--------------------------------------------"
sudo mkdir -p "/opt/SpeedTest-X"
sudo docker run -d --name SpeedTest-X -p "$USER_PORT:80" -v "/opt/SpeedTest-X:/var/www/html" badapple9/speedtest-x:latest


# 5. 設置權限
echo "--------------------------------------------"
echo "--->>> 正在設定資料權限..."
echo "--------------------------------------------"
sudo chmod -R 777 "/opt/SpeedTest-X"

# 6. 下載需要覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 下載更新資料中..."
echo "--------------------------------------------"
sudo wget -O "$SCRIPT_DIR/data.zip" $(curl -s https://api.github.com/repos/zz22558822/SpeedTest-X_install/releases/latest | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)
sudo chmod -R 777 "$SCRIPT_DIR/data.zip"
sudo wget -O "$SCRIPT_DIR/SpeedTest-X_Updata_Docker.sh" https://raw.githubusercontent.com/zz22558822/SpeedTest-X_install/refs/heads/main/SpeedTest-X_Updata_Docker.sh
sudo chmod -R 777 "$SCRIPT_DIR/SpeedTest-X_Updata_Docker.sh"

# 7. 解壓縮覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 解壓縮更新資料中..."
echo "--------------------------------------------"
sudo mkdir -p "$SCRIPT_DIR/data"
sudo unzip -o "$SCRIPT_DIR/data.zip" -d "$SCRIPT_DIR/data/"
sudo chmod -R 777 "$SCRIPT_DIR/data/"
sudo rm -f "$SCRIPT_DIR/data.zip"


# 8. 檔案覆蓋
echo "--------------------------------------------"
echo "--->>> 正在更新資料..."
echo "--------------------------------------------"
if [ -d "$SCRIPT_DIR/data" ]; then
    sudo cp "$SCRIPT_DIR/data/index.html" "/opt/SpeedTest-X/index.html"
    sudo cp "$SCRIPT_DIR/data/favicon.ico" "/opt/SpeedTest-X/favicon.ico"
    sudo cp "$SCRIPT_DIR/data/logo.png" "/opt/SpeedTest-X/logo.png"
    sudo cp "$SCRIPT_DIR/data/results.html" "/opt/SpeedTest-X/results.html"
    sudo cp "$SCRIPT_DIR/data/speedtest.js" "/opt/SpeedTest-X/speedtest.js"
    sudo cp "$SCRIPT_DIR/data/report.php" "/opt/SpeedTest-X/backend/report.php"
    sudo cp "$SCRIPT_DIR/data/config.php" "/opt/SpeedTest-X/backend/config.php"
else
    echo "--------------------------------------------"
    echo "--->>> 錯誤：找不到 'data' 資料夾。請確認腳本所在目錄結構正確。"
    echo "--------------------------------------------"
    exit 1
fi

# 9. 設定 Docker 自動重啟 SpeedTest-X 容器
echo "--------------------------------------------"
echo "--->>> 正在設置 Docker 自動重啟..."
echo "--------------------------------------------"
sudo docker update --restart unless-stopped SpeedTest-X


# 10. 顯示訪問路徑
SERVER_IP=$(hostname -I | awk '{print $1}' | sed 's/[[:space:]]//g')
echo "--------------------------------------------"
echo "--->>> 訪問路徑: http://${SERVER_IP}:${USER_PORT}"
echo ""
echo "--->>> SpeedTest-X 安裝完成。"
echo "--------------------------------------------"
