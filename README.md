# Emerald Onion's Encrypted DNS Resolver

The Emerald Onion is a privacy-respecting DNS resolver offering modern, encrypted DNS protocols: `DNS-over-TLS (DoT)` and `DNS-over-HTTPS (DoH)` We have configured specific privacy controls:

1. `DoT` and `DoH` use transport encryption to ensure that your ISP cannot see your DNS queries.
2. IP connection data and metadata logging have been disabled completely. No IP logs are kept by Emerald Onion's edge or firewall.
3. DNS query data and metadata logging have been disabled completely.
4. A DNS caching resolver offers inherent privacy due to the fact that if another user requested DNS information before you, and the validity time has not expired, then the DNS service will not transmit another upstream request for the data. This makes it more difficult for network adversaries to track users.
5. [QNAME minimization](https://www.isc.org/blogs/qname-minimization-and-privacy/) ensures that upstream DNS services are only sent the minimum amount of data necessary to perform DNS resolution.

Emerald Onion's software configurations are pulled directly from this Github repo, so users can validate for themselves that these privacy settings are enforced. This public DNS service is shared by [Emerald Onion's Tor exit relays](https://metrics.torproject.org/rs.html#search/as:396507), meaning that Tor users' queries are blended with non-Tor exit users' queries, further enhancing DNS privacy.

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

If your system doesn't support DoT or DoH and you don't want to change your stub resolver, you can use our [Docker image for dnsproxy](https://github.com/emeraldonion/docker-dnsproxy) which supports both protocols.

1. Create and start the container: `docker run -p 127.0.53.53:53:53/udp emeraldonion/docker-dnsproxy`
2. Update your DNS server to 127.0.53.53

### Protocols

- [DNS over TLS](https://tools.ietf.org/html/rfc7858) : `tls://dns.emeraldonion.org:853`
- [DNS over HTTPS](https://tools.ietf.org/html/rfc8484): `https://dns.emeraldonion.org:443`

### Protocols, Pros and Cons

There is not one protocol that is strictly better than the others, but DoH (DNS over HTTPS) seems to be the one that most of the industry is adopting.

Both protocols provide a layer of transport security to protect DNS queries from surveillance. The difference is only in the transport itself; DoT uses TLS, while DoH uses HTTPS. All protocols use the standard RFC1035 DNS wire format. For more information on how DNS messages work over alternate transports, check out [Cloudflare's 1.1.1.1 documentation](https://developers.cloudflare.com/1.1.1.1/dns-over-https/wireformat). Note: our resolver does not support the JSON message format.

Emerald Onion does not offer vulnerable DNS-over-UDP services.

### Legal

Per the [legal FAQ](https://emeraldonion.org/faq/), Emerald Onion does not log network information. To report abuse, please contact [Abuse](mailto:abuse@emeraldonion.org).

### Donate

Emerald Onion is 100% volunteer-run, and 100% of donations go to business administration and insurance, hardware, bandwidth, and co-location. Please consider becoming a monthly donor using [Github Sponsors](https://github.com/sponsors/emeraldonion)!

Other donation methods are available here: [emeraldonion.org/donate](https://emeraldonion.org/donate/)

Emerald Onion is a U.S. 501(c)(3) nonprofit, tax ID #82-2009438. Contributions are tax deductible as allowed by law.
