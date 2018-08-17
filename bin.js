#!/usr/bin/env node

'use strict'

/* eslint-disable no-console */

// TODO: cli to manage repos using this template

/*

Link on server:
  ssl -> /etc/letsencrypt

Link in repo:
  nginx/_/*
  nginx/conf.d/*
  ssl/acme-wrapper.sh

Cp to repo on init:
  nginx/sites/00-default.conf

*/

const fs = require('fs')
const path = require('path')
const isInside = require('is-path-inside')
const mkdirp = require('mkdirp').sync
const glob = require('glob').sync

function findGitFolder (p, lp) {
  if (lp !== p) {
    if (fs.readdirSync(p).indexOf('.git') !== -1) {
      return p
    }
    return findGitFolder(path.dirname(p), p)
  }

  throw new Error('No .git folder found, is this the right repo?')
}

const repoFolder = __dirname
const mainFolder = findGitFolder(process.cwd())

if (!(isInside(repoFolder, mainFolder) || fs.readdirSync(repoFolder).indexOf('.git') !== -1)) { // repo must be in main folder, skip check if repo folder has .git (dev linked)
  throw new Error('Please don\'t use the globally installed version of this module! This would otherwise break the symlinks on every system!')
}

/* file functions */

function link (from, to) {
  if (!to) {
    to = from
  }
  to = path.join(mainFolder, to)
  mkdirp(path.dirname(to))
  if (fs.existsSync(to)) {
    fs.unlinkSync(to)
  }
  fs.symlinkSync(path.relative(path.dirname(to), path.join(repoFolder, from)), to)
}

function cp (from, to) {
  if (!to) {
    to = from
  }
  to = path.join(mainFolder, to)
  mkdirp(path.dirname(to))
  if (fs.existsSync(to)) {
    return console.warn('%s already exists! Skipping overwrite...', to)
  }
  fs.writeFileSync(to, fs.readFileSync(path.join(repoFolder, from)))
}

function wlink (g, from, to) {
  if (!to) {
    to = from
  }
  const files = glob(path.join(repoFolder, from, g))
  files.map(f => path.basename(f)).forEach(f => {
    link(path.join(from, f), path.join(to, f))
  })
}

/* actual functions */

function sync () {
  wlink('*', 'nginx/_')
  wlink('*', 'nginx/conf.d')
  link('ssl/acme-wrapper.sh')
}

function init () {
  cp('nginx/sites/00-default.conf')
}

/* cli */

require('yargs') // eslint-disable-line no-unused-expressions
  .command({
    command: 'init',
    describe: 'Initializes a new repo',
    builder: {},
    handler (argv) {
      init()
      sync()
    }
  })
  .command({
    command: 'sync',
    describe: 'Syncronizes an existing repo',
    builder: {},
    handler (argv) {
      sync()
    }
  })
  .argv
