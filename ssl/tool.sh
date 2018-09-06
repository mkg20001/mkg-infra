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
      shift
      acme --cron "$@"
      main dhparams
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
ssl_trusted_certificate /etc/ssl/letsencrypt/$d/fullchain.cer;
ssl_dhparam /etc/ssl/letsencrypt/$d/dhparams.pem;
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
      main dhparams
      main genconf
      ;;
    acme)
      shift
      acme "$@"
      ;;
    dhparams)
      now=$(date +%s)
      for d in $(dir -w 1 acme); do
        conf="acme/$d/$d.conf"
        if [ -e "$conf" ]; then
          . "$conf"
          # 1 week = 60*60*24*7 in s
          (( last = $DH_LastRenew + 604800 ))
          create=false
          params="acme/$d/dhparams.pem"
          if [ $now -gt $last ]; then
            echo "[DH] Renewing DHParams for $d..."
            create=true
          elif [ ! -e "$params" ]; then
            echo "[DH] Creating DHParams for $d..."
            create=true
          else
            echo "[DH] Ignore renew DHParams (nextupdate=$(date -d@$last), domain=$d)"
          fi
          if $create; then
            openssl dhparam -out "$params" -dsaparam 4096
            cat <(cat "$conf" | grep -v DH_LastRenew) <(echo "DH_LastRenew=$now") > "$conf.new"
            mv "$conf.new" "$conf"
          fi
        fi
      done
      ;;
    *)
      echo "Usage: $0 {add, renew, genconf, acme, dhparams}"
      ;;
  esac
}

main "$@"
