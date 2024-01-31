### /etc/haproxy/haproxy.cfg
```
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
    bind *:9000
    stats enable
    stats uri /haproxy_stats
    stats refresh 10s
EOF
```
```
haproxy -c -f /etc/haproxy/haproxy.cfg -V
```