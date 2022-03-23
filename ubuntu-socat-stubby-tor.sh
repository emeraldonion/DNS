#!/bin/bash

#######################################################################
### DNS over TLS over Tor (DoToT) for Ubuntu Server 20.04 LTS Focal ###
### Thanks to Nate Sales and Yawnbox of Emerald Onion               ###
### https://emeraldonion.org                                        ###
### https://github.com/emeraldonion/DNS/                            ###
### GNU General Public License v3.0                                 ###
### https://github.com/emeraldonion/DNS/blob/main/LICENSE           ###
#######################################################################

# update ca-certificates, install tor, torify apt, install socat and stubby

apt update

apt install ca-certificates -y

mv /etc/apt/sources.list /etc/apt.sources.backup1

touch /etc/apt/sources.list

echo 'deb https://mirrors.wikimedia.org/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.wikimedia.org/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.wikimedia.org/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.wikimedia.org/ubuntu/ focal-security main restricted universe multiverse
deb [arch=amd64] https://deb.torproject.org/torproject.org focal main' > /etc/apt/sources.list

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import

gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

apt update

apt install tor deb.torproject.org-keyring apt-transport-tor -y

mv /etc/apt/sources.list /etc/apt.sources.backup2

touch /etc/apt/sources.list

echo 'deb tor+https://mirrors.wikimedia.org/ubuntu/ focal main restricted universe multiverse
deb tor+https://mirrors.wikimedia.org/ubuntu/ focal-updates main restricted universe multiverse
deb tor+https://mirrors.wikimedia.org/ubuntu/ focal-backports main restricted universe multiverse
deb tor+https://mirrors.wikimedia.org/ubuntu/ focal-security main restricted universe multiverse
deb [arch=amd64] tor+https://deb.torproject.org/torproject.org focal main' > /etc/apt/sources.list

apt update

apt install socat stubby -y

# set stubby configs

mv /etc/stubby/stubby.yml /etc/stubby/stubby.backup1

touch /etc/stubby/stubby.yml

echo 'resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 1
idle_timeout: 10000
tls_ca_path: "/etc/ssl/certs/"
tls_ciphersuites: "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
tls_min_version: GETDNS_TLS1_3
tls_max_version: GETDNS_TLS1_3
listen_addresses:
  - 127.0.8.53
upstream_recursive_servers:
  - address_data: 127.0.0.1
    tls_auth_name: "dns.emeraldonion.org"
    tls_port: 8530
  - address_data: 127.0.0.1
    tls_auth_name: "dns.quad9.net"
    tls_port: 8531
  - address_data: 127.0.0.1
    tls_auth_name: "1dot1dot1dot1.cloudflare-dns.com"
    tls_port: 8532' > /etc/stubby/stubby.yml

# create user + group

useradd tor-dns

chsh -s /sbin/nologin tor-dns

# create services

touch /etc/systemd/system/tor-dns-eo.service

echo '[Unit]
After=network.target

[Service]
Type=simple
User=tor-dns
Group=tor-dns
ExecStart=socat TCP4-LISTEN:8530,reuseaddr,fork SOCKS4A:127.0.0.1:dns.emeraldonion.org:853,socksport=9050
ProtectKernelLogs=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictNamespaces=yes

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/tor-dns-eo.service

touch /etc/systemd/system/tor-dns-cf.service

echo '[Unit]
After=network.target

[Service]
Type=simple
User=tor-dns
Group=tor-dns
ExecStart=socat TCP4-LISTEN:8532,reuseaddr,fork SOCKS4A:127.0.0.1:1dot1dot1dot1.cloudflare-dns.com:853,socksport=9050
ProtectKernelLogs=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictNamespaces=yes

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/tor-dns-cf.service

touch /etc/systemd/system/tor-dns-q9.service

echo '[Unit]
After=network.target

[Service]
Type=simple
User=tor-dns
Group=tor-dns
ExecStart=socat TCP4-LISTEN:8531,reuseaddr,fork SOCKS4A:127.0.0.1:dns.quad9.net:853,socksport=9050
ProtectKernelLogs=yes
ProtectKernelModules=yes
ProtectKernelTunables=yes
RestrictNamespaces=yes

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/tor-dns-q9.service

# start service

systemctl daemon-reload

systemctl enable --now tor-dns-eo

systemctl enable --now tor-dns-cf

systemctl enable --now tor-dns-q9
