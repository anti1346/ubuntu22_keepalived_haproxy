#!/bin/bash

#### COMMON
sudo sed -i.bak "s/\(kr\|archive\).ubuntu.com/mirror.kakao.com/g" /etc/apt/sources.list
sudo apt-get update

# 필수 패키지 설치
if ! dpkg -l | grep -q openssh-server; then
    sudo apt-get install -y lsb-release ca-certificates vim rsyslog openssh-server
    sudo systemctl restart rsyslog
    sudo systemctl --now enable ssh.service
    sudo systemctl restart ssh.service
fi

# nginx 패키지 설치
if ! dpkg -l | grep -q haproxy; then
    sudo apt-get install -y nginx php-fpm
    sudo systemctl --now enable nginx
    sudo systemctl --now enable php8.1-fpm
    generate_index_html
fi

# vagrant 계정이 존재하지 않으면 vagrant_useradd.sh 스크립트 실행
if ! id "vagrant" &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash
fi





###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
########################################################## 함수 파일 ###########################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
generate_index_html() {
    cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
    <head>
        <title>Welcome to nginx!</title>
        <style>
            html { color-scheme: light dark; }
            body { width: 35em; margin: 0 auto; font-family: Tahoma, Verdana, Arial, sans-serif; }
        </style>
    </head>
    <body>
        <h1>Welcome to nginx!</h1>
        <p>node01 - 172.19.0.3</p>
        <p><em>Thank you for using nginx.</em></p>
    </body>
</html>
EOF
}
