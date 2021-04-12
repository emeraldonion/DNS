# Emerald Onion's Encrypted DNS Resolver

The Emerald Onion public recursive name server (aka DNS resolver) is a privacy-respecting DNS service offering modern, encrypted DNS protocols: `DNS-over-TLS (DoT)`, `DNS-over-HTTPS (DoH)`, and `DNS-over-QUIC (DoQ)`. We have configured [dnsproxy](https://github.com/AdguardTeam/dnsproxy) and [unbound](https://www.nlnetlabs.nl/projects/unbound/about/) with specific privacy controls:

1. `DoT`, `DoH`, and `DoQ` TLS-based transport encryption ensures that your ISP cannot see your DNS queries.
2. IP connection data and metadata logging has been disabled completely. No IP logs exist at Emerald Onion's edge, firewall, `dnsproxy` syslog, or `unbound` syslog.
3. DNS query data and metadata logging has been disabled completely. This includes disabling `unbound-control` to prevent the possibility of exposing unbound's in-memory data to the Emerald Onion admins.
4. A DNS caching resolver offers inherent privacy due to the fact that if another user requested DNS information before you, and the validity time has not expired, then the DNS service will not transmit another upstream request for the data. This makes it more difficult for network adversaries to track users.
5. [QNAME minimization](https://www.isc.org/blogs/qname-minimization-and-privacy/) assures that upstream DNS services are only sent the minimum amount of data necessary to perform DNS resolution.

Emerald Onion's software configurations are pulled directly from [this Github repo](https://github.com/emeraldonion/DNS/tree/main/templates), so users can validate for themselves that these privacy settings are enforced. This public DNS service is shared by [Emerald Onion's Tor exit relays](https://metrics.torproject.org/rs.html#search/as:396507), meaning that Tor user's queries are blended with non-Tor exit user's queries, further enhancing DNS privacy.

### How To Use

#### iOS 14 and macOS Big Sur (DoH)

1. From your device, download this [DNS Profile](https://github.com/emeraldonion/DNS/raw/main/eo-doh.mobileconfig) in Safari
2. iOS: Settings > General > Profiles > Emerald Onion DNS-over-HTTPS > Install
3. macOS: Settings > Profiles > Emerald Onion DNS-over-HTTPS > Install

#### Android 9 (DoT)

1. Open settings
2. Network & internet > Advanced > Private DNS
3. Choose Private DNS provider hostname and enter `dns.emeraldonion.org`

#### Firefox (DoH)

1. Go to Preferences
2. Type "DNS" in "Find in Preferences" at the top
3. Click Network Settings
4. Enable "DNS over HTTPS"
5. Use provider "Custom" and enter `https://dns.emeraldonion.org/dns-query`

#### Chrome (DoH)

1. Go to Settings
2. Type "DNS" in "Search Settings" at the top
3. Click Security
4. Enable "Use secure DNS"
5. Select with "Custom" and enter `https://dns.emeraldonion.org/dns-query`

#### Local proxy with Docker

If your system doesn't support DoT, DoH, or DoQ and you don't want to change your stub resolver, you can use our [Docker image for dnsproxy](https://github.com/emeraldonion/docker-dnsproxy) which supports all 3 protocols.

1. Create and start the container: `docker run -p 127.0.53.53:53:53/udp emeraldonion/docker-dnsproxy`
2. Update your DNS server to 127.0.53.53

### Protocols

- [DNS over TLS](https://tools.ietf.org/html/rfc7858) : `tls://dns.emeraldonion.org:853`
- [DNS over HTTPS](https://tools.ietf.org/html/rfc8484): `https://dns.emeraldonion.org:443`
- [DNS over QUIC](https://tools.ietf.org/html/draft-ietf-dprive-dnsoquic-02): `quic://dns.emeraldonion.org:8853`

### Protocols, Pros and Cons

There is not one protocol that is strictly better than the others, but DoH (DNS over HTTPS) seems to be the one that most of the industry is adopting. Emerald Onion is using [draft implementation of DoQ](https://github.com/AdguardTeam/dnsproxy/pull/128), so please only use that for testing.

All 3 supported protocols provide a layer of transport security to protect DNS queries from surveillance. The difference is only in the transport itself; DoT uses TLS, DoH uses HTTPS+TLS, and DoQ uses QUIC+TLS. All protocols use the standard RFC1035 DNS wire format. For more information on how DNS messages work over alternate transports, check out [Cloudflare's 1.1.1.1 documentation](https://developers.cloudflare.com/1.1.1.1/dns-over-https/wireformat). Note: our resolver does not support the JSON message format.

- DoT is the simplest protocol using only an additional TLS layer on top of DNS.
- DoH is the most widely supported protocol where browsers such as Firefox have built-in DoH support.
- DoQ is the newest protocol and uses the modern QUIC transport protocol.

Emerald Onion does not offer vulnerable DNS-over-UDP services.

### Emerald Onion's Server-Side Configuration

We're using [dnsproxy](https://github.com/AdguardTeam/dnsproxy) to proxy DoT, DoH, and DoQ queries to [unbound](https://github.com/NLnetLabs/unbound) as the resolver. On the networking side, we use [BIRD](https://gitlab.nic.cz/labs/bird/tree/master) as a BGP daemon automated with [bcg](https://github.com/natesales/bcg) which converts a simple YAML file into BIRD configs with filtering for IRR, RPKI, and max-prefix limits. Each DNS server announces the same routes making this an anycast service that can be easily scaled out by adding more servers.

If you're interested in running your own service like this, this repo can serve as a quick way to get started. Just edit the Ansible [hosts file](https://github.com/emeraldonion/APRNS/blob/main/hosts.yml) to contain a list of your DNS servers, BGP configuration, and TLS certificate paths, and run `ansible-playbook -i hosts.yml install.yml`. Ansible will install and configure the DNS server with unbound and dnsproxy, and set up BGP session with BIRD and BCG according to the `bcg` key in your Ansible hosts file. The `hosts.yml` file in this repo contains our production config as a starting place, but you'll have to make a few modifications if you're running your own deployment:

1. Replace `tls_cert` and `tls_key` with the path to your TLS certificate and private key.
2. Replace the `hosts` key with objects for each of your DNS servers, noting `ansible_host` and `bcg` which takes a raw [bcg](https://github.com/natesales/bcg) config in YAML.

### Legal

Per the [legal FAQ](https://emeraldonion.org/faq/), Emerald Onion does not log network information. To report abuse, please contact [Abuse](mailto:abuse@emeraldonion.org).

### Donate

Emerald Onion is 100% volunteer-run, and 100% of donations go to business administration and insurance, hardware, bandwidth, and co-location. Please consider becoming a monthly donor using [Github Sponsors](https://github.com/sponsors/emeraldonion)!

Other donation methods are available here: [emeraldonion.org/donate](https://emeraldonion.org/donate/)

Emerald Onion is a U.S. 501(c)(3) nonprofit, tax ID #82-2009438. Contributions are tax deductible as allowed by law.
