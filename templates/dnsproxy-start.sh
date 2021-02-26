#!/bin/bash

/usr/bin/dnsproxy \
  --cache-size=0 \
  --upstream=127.0.0.1:5353 \
  --bootstrap=127.0.0.1:5353 \
  --https-port=8443 \
  --tls=port=8053 \
  --quic-port=8784 \
  --tls-crt=/opt/eodns/internal-cert.pem \
  --tls-key=/opt/eodns/internal-key.pem
