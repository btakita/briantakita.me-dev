#!/bin/sh
DIR=$(dirname $0)
(cd $DIR && ./.gitmodules--https.sh)
rm -rf $DIR/app/briantakita.me
(cd $DIR && git submodule update --init --recursive)
(cd $DIR && bun install)
