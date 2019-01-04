#!/bin/bash

set -e

cf_ips() {
  echo "# https://www.cloudflare.com/ips"
  echo

  for type in v4 v6; do
    echo "# IP$type"
    curl -s "https://www.cloudflare.com/ips-$type" | sed "s|^|allow |g" | sed "s|\$|;|g"
    echo
  done

  echo "# Generated at $(LC_ALL=C date)"
}

cf_ips > _/allow-cf.conf
echo "Generated _/allow-cf.conf!"
