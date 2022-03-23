#!/bin/bash

###########################################################################
###                                                                     ###
###   DNS over TLS over Tor (DoToT)                                     ###
###   Thanks to Nate Sales and Yawnbox of Emerald Onion                 ###
###   https://emeraldonion.org                                          ###
###   https://github.com/emeraldonion/DNS/                              ###
###   GNU General Public License v3.0                                   ###
###   https://github.com/emeraldonion/DNS/blob/main/LICENSE             ###
###                                                                     ###
###########################################################################
###                                                                     ###
###   From Debian/Ubuntu, stubby is set to use socat to use tor to      ###
###   distribute queries across all available name servers defined      ###
###   below: Emerald Onion, Quad9, and Cloudflare, at the same time.    ###
###                                                                     ###
###   Using multiple simultaneous connections to these providers via    ###
###   DoT (TLS 1.3 via 853/tcp via Tor) you gain DNS resolution         ###
###   security (across the wire), anonymity (to public DNS resolvers),  ###
###   and censorship resistance (if your government is fucked).         ###
###                                                                     ###
###########################################################################

# install tor, socat and stubby

apt update

apt install tor socat stubby -y

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

# Now you should set 127.0.8.53 as your only nameserver in Netplan on Ubuntu to make this a system-wide configuration, or in /etc/resolv.conf for Debian.
