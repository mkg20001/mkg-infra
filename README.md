# mkg-infra

My own personal infrastructure template, open-sourced as FOSS.

> WIP, there is more to come (and also a bunch of things will get re-written)

### Why do I publish this?
Mainly because open-sourcing things is a great motivation for me to write better code, as the world can actually see it.

# Usage

First install this into your infrastructure repo (`npm i --save mkg-infra`) or create one if you haven't already.

Then run `npx infra init` to init your infrastructure repo

Now you can install modules using `npx infra enable NAME`

## Modules

- base: Basic files needed

- baseDeploy: Basic deploy configuration (curl, jq, ntp)

- nginx: ACME.sh SSL + nginx webserver config files

- dns: simple-tf-dns + cloudflare config files

- node: Installs nodeJS

- docker: Installs docker-ce

- security: Installs fail2ban, snoopy (command logging tool) and ufw (ufw will have allow openssh by default)

- tools: Installs useful tools like nload, iotop and the well-known netdata dashboard

- cjdns: Installs cjdns

- smc: Installs small-cleanup-script

- sshPasswordless: Installs a sudo-nopasswd for group sudo rule, disables SSH password login, enables public key login

- ipfs: Installs go-ipfs

## Nginx logs

The format I created can be read like this:

```log
IP "X-Forwarded-For" - "REQUEST" [TIMESTAMP] RESULT_CODE RESULT_LENGTH HOST-BLOCK* "HTTP-HOST" "HTTP-REFERRER" "HTTP-USER-AGENT"
```

\*The first entrty in "server_name" of the current server block (useful for debugging)
