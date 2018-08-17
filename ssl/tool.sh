#!/bin/bash

set -e

acme() {
  if [ ! -e "$HOME/.acme.sh/acme.sh" ]; then # auto-install if not found
    curl https://get.acme.sh | bash -
  fi
  bash "$HOME/.acme.sh/acme.sh" --config-home "$PWD/acme" "$@"
}

main() {
  case "$1" in
    renew) # renew all certs
      acme --cron "$@"
      ;;
    genconf) # generate nginx snippets for ssl
      nssl=$(readlink -f "$PWD/../nginx/_/ssl")

      rm -rf "$nssl"
      mkdir -p "$nssl"
      for d in $(dir -w 1 acme); do
        if [ -e "acme/$d/$d.conf" ]; then
          hsts="include _/hsts.conf;"
          if [ -e "acme/$d/.no-hsts" ]; then
            hsts=""
          fi

          echo "
include _/listen.conf;
include _/modern-ssl.conf;
$hsts
ssl_certificate /etc/ssl/letsencrypt/$d/fullchain.cer;
ssl_certificate_key /etc/ssl/letsencrypt/$d/$d.key;
" > "$nssl/$d.conf"
        fi
      done

      ;;
    add) # add multiple domains, use cloudflare
      domains=()
      shift

      for d in "$@"; do
        domains+=(-d "$d")
      done

      acme --issue --dns dns_cf "${domains[@]}"
      main genconf
      ;;
    acme)
      shift
      acme "$@"
      ;;
    *)
      echo "Usage: $0 {add, renew, genconf, acme}"
      ;;
  esac
}

main "$@"
