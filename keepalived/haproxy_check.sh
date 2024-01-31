cat <<EOF >> /etc/keepalived/haproxy_check.sh
#!/bin/bash

if pidof haproxy > /dev/null; then
        exit 0
    else
        exit 1
fi
EOF

sudo chmod +x /etc/keepalived/haproxy_check.sh

sudo systemctl restart keepalived

sudo systemctl status keepalived
