### sources.list.bak 파일 생성
```
#sudo sed -i.bak "s/\(kr\|archive\|ports\).ubuntu.com/$mirror_server/g" /etc/apt/sources.list
```
```
sudo sed -i.bak "s/\(kr\|archive\).ubuntu.com/$mirror_server/g" /etc/apt/sources.list
```

```
sudo apt-get update
```
```
sudo apt-get install -y lsb-release ca-certificates vim rsyslog openssh-server
```
```
sudo systemctl --now enable ssh.service
```
```
sudo systemctl status ssh.service
```

### vagrant 계정 생성
```
curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash
```

### SSL 인증서 생성
```
sudo apt-get install -y nginx php-fpm
```
```
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
        <head>
                <title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
        </head>
        <body>
                <h1>Welcome to nginx!</h1>
                <p>node01 - 172.19.0.3</p>
                <p><em>Thank you for using nginx.</em></p>
        </body>
</html>
EOF
```
```
sudo systemctl --now enable nginx
```
```
sudo systemctl --now enable php8.1-fpm
```
```
cat ha_sangchul_kr.key ha_sangchul_kr.crt > unified_ha_sangchul_kr.pem
```
