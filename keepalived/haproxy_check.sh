#!/bin/bash

# HAProxy가 실행 중인지 확인하는 스크립트 생성
generate_haproxy_check_script() {
    sudo mkdir -m 755 /etc/keepalived

    cat <<EOF > /etc/keepalived/haproxy_check.sh
#!/bin/bash

if pidof haproxy > /dev/null; then
    exit 0
else
    exit 1
fi
EOF
}

# 생성한 스크립트에 실행 권한 부여
chmod +x /etc/keepalived/haproxy_check.sh

# 함수 호출하여 스크립트 생성
generate_haproxy_check_script


### Shell Execute Command
# curl -fsSL https://raw.githubusercontent.com/anti1346/ubuntu22_keepalived_haproxy/main/keepalived/haproxy_check.sh | bash
