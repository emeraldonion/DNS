#!/bin/bash
# Thanks to some of the Emerald Onion crew, Nate Sales and Yawnbox

# install tor, torify apt, install socat and stubby

apt update

apt install ca-certificates -y

mv /etc/apt/sources.list /etc/apt.sources.backup1

touch /etc/apt/sources.list

echo 'deb https://mirrors.wikimedia.org/ubuntu/ focal main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb https://mirrors.wikimedia.org/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb https://mirrors.wikimedia.org/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb https://mirrors.wikimedia.org/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb [arch=amd64] https://deb.torproject.org/torproject.org focal main' >> /etc/apt/sources.list

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import

gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

apt update

apt install tor deb.torproject.org-keyring apt-transport-tor -y

mv /etc/apt/sources.list /etc/apt.sources.backup2

touch /etc/apt/sources.list

echo 'deb tor+https://mirrors.wikimedia.org/ubuntu/ focal main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb tor+https://mirrors.wikimedia.org/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb tor+https://mirrors.wikimedia.org/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb tor+https://mirrors.wikimedia.org/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb [arch=amd64] tor+https://deb.torproject.org/torproject.org focal main' >> /etc/apt/sources.list

apt update

apt install socat stubby -y

# set socat and stubby configs

touch /opt/start-tor-dns.sh

echo '#!/bin/bash' >> /opt/start-tor-dns.sh
echo 'socat TCP4-LISTEN:8530,reuseaddr,fork SOCKS4A:127.0.0.1:dns.emeraldonion.org:853,socksport=9050 &' >> /opt/start-tor-dns.sh
echo 'socat TCP4-LISTEN:8531,reuseaddr,fork SOCKS4A:127.0.0.1:dns.quad9.net:853,socksport=9050 &' >> /opt/start-tor-dns.sh
echo 'socat TCP4-LISTEN:8532,reuseaddr,fork SOCKS4A:127.0.0.1:1dot1dot1dot1.cloudflare-dns.com:853,socksport=9050 &' >> /opt/start-tor-dns.sh

chmod +x /opt/start-tor-dns.sh

mv /etc/stubby/stubby.yml /etc/stubby/stubby.backup1

touch /etc/stubby/stubby.yml

echo 'resolution_type: GETDNS_RESOLUTION_STUB' >> /etc/stubby/stubby.yml
echo 'dns_transport_list:' >> /etc/stubby/stubby.yml
echo '  - GETDNS_TRANSPORT_TLS' >> /etc/stubby/stubby.yml
echo 'tls_authentication: GETDNS_AUTHENTICATION_REQUIRED' >> /etc/stubby/stubby.yml
echo 'tls_query_padding_blocksize: 128' >> /etc/stubby/stubby.yml
echo 'edns_client_subnet_private : 1' >> /etc/stubby/stubby.yml
echo 'round_robin_upstreams: 1' >> /etc/stubby/stubby.yml
echo 'idle_timeout: 10000' >> /etc/stubby/stubby.yml
echo 'tls_ca_path: "/etc/ssl/certs/"' >> /etc/stubby/stubby.yml
echo 'tls_cipher_list: "EECDH+AESGCM:EECDH+CHACHA20"' >> /etc/stubby/stubby.yml
echo 'tls_ciphersuites: "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"' >> /etc/stubby/stubby.yml
echo 'tls_min_version: GETDNS_TLS1_2' >> /etc/stubby/stubby.yml
echo 'tls_max_version: GETDNS_TLS1_3' >> /etc/stubby/stubby.yml
echo 'listen_addresses:' >> /etc/stubby/stubby.yml
echo '  - 127.0.8.53' >> /etc/stubby/stubby.yml
echo 'upstream_recursive_servers:' >> /etc/stubby/stubby.yml
echo '  - address_data: 127.0.0.1' >> /etc/stubby/stubby.yml
echo '    tls_auth_name: "dns.emeraldonion.org"' >> /etc/stubby/stubby.yml
echo '    tls_port: 8530' >> /etc/stubby/stubby.yml
echo '  - address_data: 127.0.0.1' >> /etc/stubby/stubby.yml
echo '    tls_auth_name: "dns.quad9.net"' >> /etc/stubby/stubby.yml
echo '    tls_port: 8531' >> /etc/stubby/stubby.yml
echo '  - address_data: 127.0.0.1' >> /etc/stubby/stubby.yml
echo '    tls_auth_name: "1dot1dot1dot1.cloudflare-dns.com"' >> /etc/stubby/stubby.yml
echo '    tls_port: 8532' >> /etc/stubby/stubby.yml

# create user + group

useradd tor-dns

groupadd tor-dns

chsh -s /sbin/nologin tor-dns

# create services

touch /etc/systemd/system/tor-dns-eo.service

echo '[Unit]' >> /etc/systemd/system/tor-dns-eo.service
echo 'After=network.target' >> /etc/systemd/system/tor-dns-eo.service
echo '[Service]' >> /etc/systemd/system/tor-dns-eo.service
echo 'Type=simple' >> /etc/systemd/system/tor-dns-eo.service
echo 'User=tor-dns' >> /etc/systemd/system/tor-dns-eo.service
echo 'Group=tor-dns' >> /etc/systemd/system/tor-dns-eo.service
echo 'ExecStart=socat TCP4-LISTEN:8532,reuseaddr,fork SOCKS4A:127.0.0.1:dns.emeraldonion.org:853,socksport=9050' >> /etc/systemd/system/tor-dns-eo.service
echo 'ProtectKernelLogs=yes' >> /etc/systemd/system/tor-dns-eo.service
echo 'ProtectKernelModules=yes' >> /etc/systemd/system/tor-dns-eo.service
echo 'ProtectKernelTunables=yes' >> /etc/systemd/system/tor-dns-eo.service
echo 'RestrictNamespaces=yes' >> /etc/systemd/system/tor-dns-eo.service
echo '[Install]' >> /etc/systemd/system/tor-dns-eo.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/tor-dns-eo.service

touch /etc/systemd/system/tor-dns-cf.service

echo '[Unit]' >> /etc/systemd/system/tor-dns-cf.service
echo 'After=network.target' >> /etc/systemd/system/tor-dns-cf.service
echo '[Service]' >> /etc/systemd/system/tor-dns-cf.service
echo 'Type=simple' >> /etc/systemd/system/tor-dns-cf.service
echo 'User=tor-dns' >> /etc/systemd/system/tor-dns-cf.service
echo 'Group=tor-dns' >> /etc/systemd/system/tor-dns-cf.service
echo 'ExecStart=socat TCP4-LISTEN:8532,reuseaddr,fork SOCKS4A:127.0.0.1:1dot1dot1dot1.cloudflare-dns.com:853,socksport=9050' >> /etc/systemd/system/tor-dns-cf.service
echo 'ProtectKernelLogs=yes' >> /etc/systemd/system/tor-dns-cf.service
echo 'ProtectKernelModules=yes' >> /etc/systemd/system/tor-dns-cf.service
echo 'ProtectKernelTunables=yes' >> /etc/systemd/system/tor-dns-cf.service
echo 'RestrictNamespaces=yes' >> /etc/systemd/system/tor-dns-cf.service
echo '[Install]' >> /etc/systemd/system/tor-dns-cf.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/tor-dns-cf.service

touch /etc/systemd/system/tor-dns-q9.service

echo '[Unit]' >> /etc/systemd/system/tor-dns-q9.service
echo 'After=network.target' >> /etc/systemd/system/tor-dns-q9.service
echo '[Service]' >> /etc/systemd/system/tor-dns-q9.service
echo 'Type=simple' >> /etc/systemd/system/tor-dns-q9.service
echo 'User=tor-dns' >> /etc/systemd/system/tor-dns-q9.service
echo 'Group=tor-dns' >> /etc/systemd/system/tor-dns-q9.service
echo 'ExecStart=socat TCP4-LISTEN:8532,reuseaddr,fork SOCKS4A:127.0.0.1:dns.quad9.net:853,socksport=9050' >> /etc/systemd/system/tor-dns-q9.service
echo 'ProtectKernelLogs=yes' >> /etc/systemd/system/tor-dns-q9.service
echo 'ProtectKernelModules=yes' >> /etc/systemd/system/tor-dns-q9.service
echo 'ProtectKernelTunables=yes' >> /etc/systemd/system/tor-dns-q9.service
echo 'RestrictNamespaces=yes' >> /etc/systemd/system/tor-dns-q9.service
echo '[Install]' >> /etc/systemd/system/tor-dns-q9.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/tor-dns-q9.service

# start service

systemctl daemon-reload

systemctl enable --now tor-dns-eo

systemctl enable --now tor-dns-cf

systemctl enable --now tor-dns-q9
