#!/bin/bash

# run_test "name" "command" "expected output"
function run_test() {
  echo "$1 ($2)"
  result=$($2)
  nsid=$(echo "$result" | grep NSID | cut -d '"' -f 2)
  address=$(echo "$result" | grep From | cut -d " " -f 3)
  echo "NSID: $nsid, Address: $address)"
  if [[ "$result" == *"$3"* ]]; then
    echo "PASS"
  else
    echo "FAIL"
    echo "$result"
  fi
  echo
}

run_test "IPv4 DoH" "kdig -4 +nsid +https @dns.emeraldonion.org" "a.root-servers.net"
run_test "IPv6 DoH" "kdig -6 +nsid +https @dns.emeraldonion.org" "a.root-servers.net"

run_test "IPv4 DoT" "kdig -4 +nsid +tls @dns.emeraldonion.org" "a.root-servers.net"
run_test "IPv6 DoT" "kdig -6 +nsid +tls @dns.emeraldonion.org" "a.root-servers.net"

run_test "DNSSEC SIGOK" "kdig +nsid +https @dns.emeraldonion.org sigok.verteiltesysteme.net" "134.91.78.139"
run_test "DNSSEC SIGFAIL" "kdig +nsid +https @dns.emeraldonion.org sigfail.verteiltesysteme.net" ""

run_test "QNAME minimisation" "kdig +nsid +https @dns.emeraldonion.org qnamemintest.internet.nl TXT" "QNAME minimisation is enabled"

doq_command="q example.com @quic://dns.emeraldonion.org --format=raw NS"
echo "IPv4 DoQ ($doq_command)"
result=$($doq_command)
if [[ "$result" == *"a.iana-servers.net"* ]]; then
  echo "PASS"
else
  echo "FAIL"
  echo "$result"
fi
echo
