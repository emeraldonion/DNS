#!/bin/bash

/usr/bin/dnsproxy --upstream=127.0.0.1:5353 --bootstrap=127.0.0.1:5353 --https-port=8443 --tls=port=8053 --quic-port=8784 --cache-size=0
