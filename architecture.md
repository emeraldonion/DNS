# Architecture

Daemons:

- kresd
    - `wg-ip:53` Plain DNS
    - `wg-ip:853, anycast:853` DoT
    - `wg-ip:8453` webmgmt
    - `wg-ip:8080` cachepurge
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
- nginx `:9113`
