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

# keepalived 패키지 설치
if ! dpkg -l | grep -q keepalived; then
    sudo apt-get install -y keepalived
    sudo systemctl --now enable keepalived.service
    sudo systemctl restart keepalived.service
    generate_keepalived_config
fi

# haproxy 패키지 설치
if ! dpkg -l | grep -q haproxy; then
    sudo apt-get install -y haproxy
    sudo systemctl --now enable haproxy.service
    sudo systemctl restart haproxy.service
    generate_haproxy_config
fi

# vagrant 계정이 존재하지 않으면 vagrant_useradd.sh 스크립트 실행
if ! id "vagrant" &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/anti1346/zz/main/etc/vagrant_useradd.sh | bash
fi

if [ "$HOSTNAME" == "haproxy01" ]; then
    #### haproxy01
    #ssh-keygen -t rsa -b 2048 -C "deployment" -f /root/.ssh/id_rsa -N ""
    if [ ! -f "/root/.ssh/id_rsa" ]; then
        mkdir -m 700 /root/.ssh
        # 함수 호출하여 id_rsa 파일 생성
        generate_ssh_private_key
    fi
    
    if [ ! -d "/etc/ssl/ha_sangchul_kr" ]; then
        mkdir -p /etc/ssl/ha_sangchul_kr
        cd /etc/ssl/ha_sangchul_kr
        openssl req \
        -newkey rsa:4096 \
        -x509 \
        -sha256 \
        -days 3650 \
        -nodes \
        -out ha_sangchul_kr.crt \
        -keyout ha_sangchul_kr.key \
        -subj "/C=KR/ST=Seoul/L=Jongno-gu/O=SangChul Co., Ltd./OU=Infrastructure Team/CN=ha.sangchul.kr"
        cat ha_sangchul_kr.key ha_sangchul_kr.crt > unified_ha_sangchul_kr.pem
    fi
fi

if [ "$HOSTNAME" == "haproxy02" ]; then
    #### haproxy02
    if [ ! -d "/root/.ssh" ]; then
        mkdir -m 700 /root/.ssh
        # 함수 호출하여 authorized_keys 파일에 공개 키 추가
        add_ssh_authorized_key
    fi

    if [ ! -d "/etc/ssl/ha_sangchul_kr" ]; then
        mkdir -p /etc/ssl/ha_sangchul_kr
    fi

    sudo sed -i.bak "s/state MASTER/state BACKUP/g" /etc/keepalived/keepalived.conf
    sudo sed -i.bak "s/priority 100/priority 99/g" /etc/keepalived/keepalived.conf

fi

sudo systemctl status rsyslog.service
sudo systemctl status ssh.service
openssl x509 -in /etc/ssl/ha_sangchul_kr/ha_sangchul_kr.crt -noout -subject -dates

# Check keepalived configuration
if ! keepalived -t &>/dev/null; then
    sudo systemctl restart keepalived.service
fi

# Check HAProxy configuration
if ! haproxy -c -f /etc/haproxy/haproxy.cfg -V &>/dev/null; then
    sudo systemctl restart haproxy.service
fi

echo -e "\n### SSL CERT COPY"
echo "scp /etc/ssl/ha_sangchul_kr/unified_ha_sangchul_kr.pem root@172.19.0.3:/etc/ssl/ha_sangchul_kr/unified_ha_sangchul_kr.pem"





###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
########################################################## 함수 파일 ###########################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
generate_ssh_private_key() {
    cat <<EOF > /root/.ssh/id_rsa
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
    NhAAAAAwEAAQAAAQEA4X3ocCY57yPxHyS/jzsSByaGrLj+5O1zwwkUEqVRPaHDi6R0EvS7
    d0WRW82IxebZWpABUKrpZjwHQZVvYACjtGPnBTQxbAW95QOlXEtglSdtPCS3b48Fb8X7oc
    wbU91HQaWKc0rQ9lTUP+Amh/m7sg1tIGZC/PneKY5yi0uaa4k52FOzRHWsU0CWcAyBnnFX
    hftXGXcfuDQsCTVpEDkvb8kpp6xhQBcSnSNIF7qkSpD0oXBpbcbCdGPwgCp/LIM0G4c6qF
    cmSnqM2L3Xp8ZSfj+xkH/8kA3bqMJvfHA++TUc9B2pBuL18TLP0mU3QZIdNFqvmSBsYdUT
    FG/HX7faYwAAA8CgpohQoKaIUAAAAAdzc2gtcnNhAAABAQDhfehwJjnvI/EfJL+POxIHJo
    asuP7k7XPDCRQSpVE9ocOLpHQS9Lt3RZFbzYjF5tlakAFQqulmPAdBlW9gAKO0Y+cFNDFs
    Bb3lA6VcS2CVJ208JLdvjwVvxfuhzBtT3UdBpYpzStD2VNQ/4CaH+buyDW0gZkL8+d4pjn
    KLS5priTnYU7NEdaxTQJZwDIGecVeF+1cZdx+4NCwJNWkQOS9vySmnrGFAFxKdI0gXuqRK
    kPShcGltxsJ0Y/CAKn8sgzQbhzqoVyZKeozYvdenxlJ+P7GQf/yQDduowm98cD75NRz0Ha
    kG4vXxMs/SZTdBkh00Wq+ZIGxh1RMUb8dft9pjAAAAAwEAAQAAAQBAhsk3HplBh6V+ZgOz
    NxInnay4TJAUbqbLzxNBarFe06WjlkHpEsN6lBvOi3hyOWdFdSQLM31q1g61g8/FRymRe2
    0mnhLueI4otOxjBubyh7/IkDE16VWC8MLbQA8p5o53iKmf6G73rrq2NKySCLLfdtwdg2X0
    AoTCm5LHrbDYyHh8ABi3ifwBWn3lu3XDmA/UQWgOffW556L9KUlNQwwq6N8zX+ADMZpLCd
    rE/czveBPkJTqOfdoZ4R2RWJEyeP2JZU7L3ubXkz5smrpq8d9XwJRx8YOMTeqe9XiByHp/
    ugIwmNnP/VHb9ChshvYfAVqS/iujykqAvjxCWZq56I3RAAAAgQCKmvDS3W7SijupFN5Um/
    z+zXfqiGilT9toAEEwpgKdS822j3Ritwnc4mxJvl4yR7+Wg+4kFy4bxBw+tDNJJ0YKkA7U
    D2skb6tKmarxxSRqQdrBTjY8Ro1LOS3MFxsEIQkGVqEz7RXUqzxlfwn/XRr+8pfyhRVhpX
    fBzaB1yvm1YAAAAIEA52HBBC66G93JcC/nkm4IIr8Qvx5CvXDHgd+9f0c0gSQFm6lrD90H
    DSLpFcZ/hxWTFsrBHbNTghw0YPM6MDKeYqkVDwQj9mdulAUHWh2G4gzHPGgbXvmO5MmkgR
    9TB78ZdhzaqLIgnM/C1jAIAafsa7/HYwNwybJTnYsMAg4qIG0AAACBAPl7uZPs74Yl7mjj
    jHBOxZmfOzxxY8ZymIZjEcZCZJ+wykTnzJZ/g+ukYLh9SWS3xrNGB5PAc2g1FmyZYtP/u8
    /ptjqWD+6Tp501G0Vp+Wic7z2s4nO8+FvKcu0JQoE8nN4k5CASDDnvh/6l8usYvWVj92Aa
    +EBxaduGTn0dT0QPAAAACmRlcGxveW1lbnQ=
    -----END OPENSSH PRIVATE KEY-----
EOF
}

add_ssh_authorized_key() {
    cat <<EOF >> /root/.ssh/authorized_keys
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhfehwJjnvI/EfJL+POxIHJoasuP7k7XPDCRQSpVE9ocOLpHQS9Lt3RZFbzYjF5tlakAFQqulmPAdBlW9gAKO0Y+cFNDFsBb3lA6VcS2CVJ208JLdvjwVvxfuhzBtT3UdBpYpzStD2VNQ/4CaH+buyDW0gZkL8+d4pjnKLS5priTnYU7NEdaxTQJZwDIGecVeF+1cZdx+4NCwJNWkQOS9vySmnrGFAFxKdI0gXuqRKkPShcGltxsJ0Y/CAKn8sgzQbhzqoVyZKeozYvdenxlJ+P7GQf/yQDduowm98cD75NRz0HakG4vXxMs/SZTdBkh00Wq+ZIGxh1RMUb8dft9pj deployment
EOF
}

generate_keepalived_config() {
    cat <<EOF >> /etc/keepalived/keepalived.conf

global_defs {
    notification_email {
        admin@example.com
    }
    notification_email_from admin@example.com
    #smtp_server smtp.example.com
    #smtp_connect_timeout 30
    router_id LVS_DEVEL
    enable_script_security
    script_user root
}

vrrp_script haproxy_check {
    script "/etc/keepalived/haproxy_check.sh"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        172.19.0.10/24 dev eth0 label eth0:1
    }
    track_script {
        haproxy_check
    }
}
EOF
}

generate_haproxy_config() {
    cat <<EOF > /etc/haproxy/haproxy.cfg

global
    log         127.0.0.1 local2
    pidfile     /var/run/haproxy.pid
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

defaults
    log                     global
    mode                    http
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

frontend http-in
    bind *:80
    acl url_admin       path_beg       /admin
    use_backend bk_admin     if url_admin
    default_backend             bk_web

frontend https-in
    bind *:443 ssl crt /etc/ssl/ha_sangchul_kr/unified_ha_sangchul_kr.pem
    acl url_admin       path_beg       /admin
    use_backend bk_admin     if url_admin
    default_backend             bk_web

backend bk_web
    balance     roundrobin
    server      web1 172.19.0.11:80 check
    server      web2 172.19.0.12:80 check

backend bk_admin
    balance     roundrobin
    server      web1 172.19.0.11:80 check
    server      web2 172.19.0.12:80 check

listen stats
    #bind *:1936
    bind *:9000
    stats enable
    stats uri /haproxy_stats
    stats refresh 10s
EOF
}
