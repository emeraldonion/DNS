# Architecture

Daemons:

- kresd
    - `wg-ip:53` Plain DNS
    - `wg-ip:853, anycast:853` DoT
    - `wg-ip:8453` webmgmt
    - `wg-ip:8080` cachepurge
- odohd
    - `wg-ip:8081` HTTP server
    - `wg-ip:8082` Prometheus
- doqd
    - `wg-ip:853, anycast:8853` DoQ listener
    - `wg-ip:8083` Prometheus
- nginx
    - `anycast:80, anycast:443`
    - `wg-ip:8084` Prometheus
- nginx-exporter
    - `wg-ip:9113`
- node-exporter
    - `wg-ip:9100`

Prometheus Exporters:

- node `:9100`
- kresd `:8453`
- odohd `:8082`
- nginx `:9113`
- doqd `:8083`
