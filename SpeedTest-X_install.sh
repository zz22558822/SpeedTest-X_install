#!/bin/bash

# 1. 更新系統
echo "更新系統..."
sudo apt update && sudo apt upgrade -y

# 2. 安裝 Apache
echo "安裝 Apache..."
sudo apt install apache2 -y

# 3. 安裝依賴項
echo "安裝 PHP 和其他依賴項..."
sudo apt install php php-curl php-json php-mbstring git -y

# 4. 下載 SpeedTest-X
echo "正在下載 SpeedTest-X..."
cd /var/www/html
sudo git clone https://github.com/SpeedTest-CLI/SpeedTest-X.git

# 5. 設置權限
echo "正在設定資料權限..."
sudo chown -R www-data:www-data /var/www/html/SpeedTest-X
sudo chmod -R 755 /var/www/html/SpeedTest-X

# 6. 檔案覆蓋
echo "正在更新資料..."
sudo cp /data/index.html /var/www/html/SpeedTest-X/index.html
sudo cp /data/favicon.ico /var/www/html/SpeedTest-X/favicon.ico
sudo cp /data/logo.png /var/www/html/SpeedTest-X/logo.png
sudo cp /data/results.html /var/www/html/SpeedTest-X/results.html
sudo cp /data/speedtest.js /var/www/html/SpeedTest-X/speedtest.js
sudo cp /data/config.php /var/www/html/SpeedTest-X/config.php

# 7. 配置 Apache
echo "配置 Apache..."
sudo bash -c 'cat <<EOL > /etc/apache2/sites-available/speedtest.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/SpeedTest-X

    <Directory /var/www/html/SpeedTest-X>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL'

# 8. 重新啟動 Apache 容器
echo "啟用配置和重啟 Apache..."
sudo a2ensite speedtest.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# 9. 設定防火牆
echo "設定防火牆..."
sudo ufw allow 'Apache Full'

echo "SpeedTest-X 安裝完成。"
