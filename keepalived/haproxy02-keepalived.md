### /etc/keepalived/keepalived.conf
```
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
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 99
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
```
```
keepalived -t
```
```
sudo systemctl restart keepalived
```
```
ip -brief address show eth0
```
