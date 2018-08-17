#!/bin/bash

set -e

MAIN="$PWD"

import() {
  if ! which cf2tf > /dev/null 2> /dev/null; then
    npm i -g @brave/cf2tf
  fi
  if [ -e "$stateLocation/terraform.tfstate" ]; then
    echo -e "State already exists!\nPlease delete '$stateLocation/terraform.tfstate*' manually, first!" 1>&2
    exit 2
  fi
  cf2tf dns --zone "$1" --tfstate > "$stateLocation/terraform.tfstate"
}

apply() {
  cd "$MAIN/domains"
  npx simple-tf-dns "$1" > "$stateLocation/$1.tf"
  cd "$stateLocation"
  ln -sf ../../.terraform .
  if [ ! -e "$MAIN/.terraform/plugins" ]; then
    terraform init
  fi
  terraform apply
}

main() {
  if [ "$1" != "import" ] && [ "$1" != "apply" ]; then
    echo "Usage: $0 {import,apply} <domain> [<domain>...]"
    exit 2
  fi
  if [ -z "$CLOUDFLARE_TOKEN" ] || [ -z "$CLOUDFLARE_EMAIL" ]; then
    echo "You need to set \$CLOUDFLARE_TOKEN and \$CLOUDFLARE_EMAIL" 1>&2
    exit 2
  fi
  cmd="$1"
  shift
  mkdir -p "$MAIN/.terraform"
  for d in "$@"; do
    stateLocation="$MAIN/.state/$d"
    mkdir -p "$stateLocation"
    "$cmd" "$d"
  done
}

main "$@"
