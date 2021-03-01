# PRNS

Emerald Onion's Public Recursive Name Server

### Supported protocols

| Protocol       | URI                                | DNS Stamp                                                         | Spec                                                                                       |
|----------------|------------------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| DNS over TLS   | `tls://dns.emeraldonion.org:853`   | sdns://AwcAAAAAAAAAAAAUZG5zLmVtZXJhbGRvbmlvbi5vcmc                | [RFC 7858](https://tools.ietf.org/html/rfc7858)                                            |
| DNS over HTTPS | `https://dns.emeraldonion.org:443` | sdns://AgcAAAAAAAAAAAAUZG5zLmVtZXJhbGRvbmlvbi5vcmcKL2Rucy1xdWVyeQ | [RFC 8484](https://tools.ietf.org/html/rfc8484)                                            |
| DNS over QUIC  | `quic://dns.emeraldonion.org:8853` | sdns://BAcAAAAAAAAAAAAUZG5zLmVtZXJhbGRvbmlvbi5vcmc                | [draft-ietf-dprive-dnsoquic-02](https://tools.ietf.org/html/draft-ietf-dprive-dnsoquic-02) |
