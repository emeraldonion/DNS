# Anycast Public Recursive Name Server

The Emerald Onion Anycast Public Recursive Name Server (APRNS) is a privacy-respecting DNS resolver using modern, encrypted DNS protocols (DoT, DoH, and DoQ).

### How To

#### Chrome

1. Go to Settings
2. Type "DNS" in "Search Settings" at the top
3. Click Security
4. Enable "Use secure DNS"
5. Select with "Custom" and enter `https://dns.emeraldonion.org/dns-query`

| Protocol       | URI                                | DNS Stamp                                                           | Spec                                                                                       |
|----------------|------------------------------------|---------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| DNS over TLS   | `tls://dns.emeraldonion.org:853`   | `sdns://AwcAAAAAAAAAAAAUZG5zLmVtZXJhbGRvbmlvbi5vcmc`                | [RFC 7858](https://tools.ietf.org/html/rfc7858)                                            |
| DNS over HTTPS | `https://dns.emeraldonion.org:443` | `sdns://AgcAAAAAAAAAAAAUZG5zLmVtZXJhbGRvbmlvbi5vcmcKL2Rucy1xdWVyeQ` | [RFC 8484](https://tools.ietf.org/html/rfc8484)                                            |
| DNS over QUIC  | `quic://dns.emeraldonion.org:8853` | `sdns://BAcAAAAAAAAAAAAUZG5zLmVtZXJhbGRvbmlvbi5vcmc`                | [draft-ietf-dprive-dnsoquic-02](https://tools.ietf.org/html/draft-ietf-dprive-dnsoquic-02) |

### Advanced: Protocols, Pros and Cons

There is not one protocol that is strictly better than the others, but DoH (DNS over HTTPS) seems to be the one that most of the industry is adopting. Emerald Onion is using [draft implementation of DoQ](https://github.com/AdguardTeam/dnsproxy/pull/128), so please only use that for testing.

All 3 supported protocols provide a layer of transport security to protect DNS queries from surveillance. The difference is only in the transport itself; DoT uses TLS, DoH uses HTTPS+TLS, and DoQ uses QUIC+TLS. All protocols use the standard RFC1035 DNS wire format. For more information on how DNS messages work over alternate transports, check out [Cloudflare's 1.1.1.1 documentation](https://developers.cloudflare.com/1.1.1.1/dns-over-https/wireformat). Note: our resolver does not support the JSON message format.

- DoT is the simplest protocol using only an additional TLS layer on top of DNS.
- DoH is the most widely supported protocol where browsers such as Firefox have built-in DoH support.
- DoQ is the newest protocol and uses the modern QUIC transport protocol.

### Advanced: Emerald Onion APRNS Configuration

We're using [dnsproxy](https://github.com/AdguardTeam/dnsproxy) to proxy DoT, DoH, and DoQ queries to [unbound](https://github.com/NLnetLabs/unbound) as the resolver. On the networking side, we use [BIRD](https://gitlab.nic.cz/labs/bird/tree/master) as a BGP daemon automated with [bcg](https://github.com/natesales/bcg) which converts a simple YAML file into BIRD configs with filtering for IRR, RPKI, and max-prefix limits. Each DNS server announces the same routes making this an anycast service that can be easily scaled out by adding more servers.

If you're interested in running your own service like this, this repo can serve as a quick way to get started. Just edit the Ansible [hosts file](https://github.com/emeraldonion/APRNS/blob/main/hosts.yml) to contain a list of your DNS servers and BGP configuration, and run `ansible-playbook -i hosts.yml install.yml`. Ansible will install and configure the DNS server with unbound and dnsproxy, and set up BGP session with BIRD+BCG according to the `bcg` key in your Ansible hosts file. A TLS certificate is required as well (DoT, DoH, and DoQ use TLS), so specify the path to your cert and key in the `vars` section of `hosts.yml`.

### Legal

Per the [legal FAQ](https://emeraldonion.org/faq/), Emerald Onion does not log network information. To report abuse, please contact [Abuse](mailto:abuse@emeraldonion.org).

### Donate

Emerald Onion is 100% volunteer-run, and 100% of donations go to business administration and insurrance, hardware, bandwidth, and co-location. Please consider becoming a monthly donor using [Github Sponsors](https://github.com/sponsors/emeraldonion)!

Other donation methods are available here: [emeraldonion.org/donate](https://emeraldonion.org/donate/)

Emerald Onion is a U.S. 501(c)(3) nonprofit, tax ID #82-2009438. Contributions are tax deductible as allowed by law.
