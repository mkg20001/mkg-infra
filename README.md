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

- nginx: ACME.sh SSL + nginx webserver config files

- dns: simple-tf-dns + cloudflare config files
