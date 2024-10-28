#!/bin/bash

# 獲取當前腳本的絕對路徑
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. 讓用戶選擇端口號
echo "--------------------------------------------"
while true; do
    read -p "--->>> 請輸入 Apache 服務的 Port (預設 80): " USER_PORT
    USER_PORT=${USER_PORT:-80}  # 若未輸入則設置為 80

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

# 3. 安裝 Apache
echo "--------------------------------------------"
echo "--->>> 安裝 Apache..."
echo "--------------------------------------------"
sudo apt install apache2 -y

# 4. 安裝依賴項
echo "--------------------------------------------"
echo "--->>> 安裝 PHP 和其他依賴項..."
echo "--------------------------------------------"
sudo apt install php php-curl php-json php-mbstring git -y

# 5. 下載 SpeedTest-X
echo "--------------------------------------------"
echo "--->>> 正在下載 SpeedTest-X..."
echo "--------------------------------------------"
cd /var/www/html
sudo git clone https://github.com/BadApple9/speedtest-x.git

# 6. 設置權限
echo "--------------------------------------------"
echo "--->>> 正在設定資料權限..."
echo "--------------------------------------------"
sudo chown -R www-data:www-data /var/www/html/speedtest-x
sudo chmod -R 755 /var/www/html/speedtest-x

# 7. 下載需要覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 下載更新資料中..."
echo "--------------------------------------------"
sudo wget -O "$SCRIPT_DIR/data.zip" $(curl -s https://api.github.com/repos/zz22558822/SpeedTest-X_install/releases/latest | grep "browser_download_url" | grep ".zip" | cut -d '"' -f 4)
sudo chmod -R 777 "$SCRIPT_DIR/data.zip"
sudo wget -O "$SCRIPT_DIR/SpeedTest-X_Updata_Apache.sh" https://github.com/zz22558822/SpeedTest-X_install/blob/main/SpeedTest-X_Updata_Apache.sh
sudo chmod -R 777 "$SCRIPT_DIR/SpeedTest-X_Updata_Apache.sh"

# 8. 解壓縮覆蓋檔案
echo "--------------------------------------------"
echo "--->>> 解壓縮更新資料中..."
echo "--------------------------------------------"
sudo mkdir -p "$SCRIPT_DIR/data"
sudo unzip -o "$SCRIPT_DIR/data.zip" -d "$SCRIPT_DIR/data/"
sudo chmod -R 777 "$SCRIPT_DIR/data/"
sudo rm -f "$SCRIPT_DIR/data.zip"

# 9. 檔案覆蓋
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
    sudo cp "$SCRIPT_DIR/data/config.php" "$TARGET_DIR/config.php"
else
    echo "--------------------------------------------"
    echo "--->>> 錯誤：找不到 'data' 資料夾。請確認腳本所在目錄結構正確。"
    echo "--------------------------------------------"
    exit 1
fi

# 10. 配置 Apache
echo "--------------------------------------------"
echo "--->>> 配置 Apache..."
echo "--------------------------------------------"
sudo bash -c 'cat <<EOL > /etc/apache2/sites-available/speedtest.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/speedtest-x

    <Directory /var/www/html/speedtest-x>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL'

# 11. 重新啟動 Apache 容器
echo "--------------------------------------------"
echo "--->>> 啟用配置和重啟 Apache..."
echo "--------------------------------------------"
sudo a2ensite speedtest.conf
sudo a2dissite 000-default.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# 12. 設定防火牆
echo "--------------------------------------------"
echo "--->>> 設定防火牆..."
echo "--------------------------------------------"
sudo ufw allow 'Apache Full'

# 13. 顯示訪問路徑
SERVER_IP=$(hostname -I | awk '{print $1}' | sed 's/[[:space:]]//g')
echo "--------------------------------------------"
echo "--->>> 訪問路徑: http://${SERVER_IP}:${USER_PORT}"
echo ""
echo "--->>> SpeedTest-X 安裝完成。"
echo "--------------------------------------------"