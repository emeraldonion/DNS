# Anycast Public Recursive Name Server

The Emerald Onion Anycast Public Recursive Name Server (APRNS) is a public privacy-respecting DNS resolver using modern encrypted DNS protocols (DoT, DoH, and DoQ). Per the [legal FAQ](https://emeraldonion.org/faq/), Emerald Onion does not log network information.

The hostname for all protocols is `dns.emeraldonion.org` and is currently hosted out of Seattle, WA.


### How To

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

stuff
