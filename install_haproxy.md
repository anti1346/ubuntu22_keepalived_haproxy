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

