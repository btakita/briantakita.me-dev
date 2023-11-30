#!/bin/sh
rm -rf ./app/briantakita.me
./.gitmodules--https.sh
git submodule update --init --recursive
bun install
