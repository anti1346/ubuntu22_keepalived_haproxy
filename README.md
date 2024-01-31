```
sudo sed -i.bak "s/\(kr\|archive\).ubuntu.com/mirror.kakao.com/g" /etc/apt/sources.list;
sudo apt-get update;
sudo apt-get install -y lsb-release ca-certificates
```

## HAProxy
### haproxy01, haproxy02
```
curl -fsSL https://raw.githubusercontent.com/anti1346/ubuntu22_keepalived_haproxy/main/install_haproxy.sh | bash
```
```
curl -fsSL https://raw.githubusercontent.com/anti1346/ubuntu22_keepalived_haproxy/main/keepalived/haproxy_check.sh | bash
```

### haproxy01
```
scp -o StrictHostKeyChecking=no /etc/ssl/ha_sangchul_kr/unified_ha_sangchul_kr.pem root@172.19.0.3:/etc/ssl/ha_sangchul_kr/unified_ha_sangchul_kr.pem
```

#### keepalived restart
```
sudo systemctl restart keepalived.service
```
#### keepalived status
```
sudo systemctl status keepalived.service
```
#### haproxy restart
```
sudo systemctl restart haproxy.service
```
#### haproxy status
```
sudo systemctl status haproxy.service
```

## Web Server
### web01, web02
```
curl -fsSL https://raw.githubusercontent.com/anti1346/ubuntu22_keepalived_haproxy/main/install_webserver.sh | bash
```
#### nginx restart
```
sudo systemctl restart nginx.service
```
#### nginx status
```
sudo systemctl status nginx.service
```
#### haproxy restart
```
sudo systemctl restart php8.1-fpm
```
#### haproxy status
```
sudo systemctl status php8.1-fpm
```