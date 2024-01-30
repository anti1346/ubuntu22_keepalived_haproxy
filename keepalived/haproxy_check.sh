cat <<EOF >> /etc/keepalived/haproxy_check.sh
### /etc/keepalived/keepalived.conf

#!/bin/bash

if pidof haproxy > /dev/null; then
        exit 0
    else
        exit 1
fi
EOF

sudo chmod +x /etc/keepalived/haproxy_check.sh