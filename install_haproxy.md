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
sudo systemctl start rsyslog
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
#### haproxy01
```
mkdir -p /etc/ssl/ha_sangchul_kr
```
```
cd /etc/ssl/ha_sangchul_kr
```
```
openssl req \
-newkey rsa:4096 \
-x509 \
-sha256 \
-days 3650 \
-nodes \
-out ha_sangchul_kr.crt \
-keyout ha_sangchul_kr.key \
-subj "/C=KR/ST=Seoul/L=Jongno-gu/O=SangChul Co., Ltd./OU=Infrastructure Team/CN=ha.sangchul.kr"
```
```
openssl x509 -in /etc/ssl/ha_sangchul_kr/ha_sangchul_kr.crt -noout -subject -dates
```
```
cat ha_sangchul_kr.key ha_sangchul_kr.crt > unified_ha_sangchul_kr.pem
```

#### haproxy02
```
mkdir -p /etc/ssl/ha_sangchul_kr
```
```
cd /etc/ssl/ha_sangchul_kr
```
```
scp unified_ha_sangchul_kr.pem vagrant@172.19.0.3:~
```
```
 mv /home/vagrant/unified_ha_sangchul_kr.pem .
```
