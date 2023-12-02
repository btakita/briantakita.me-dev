#!/bin/sh
DIR=$(dirname $0)
(cd $DIR && ./.gitmodules--https.sh)
rm -rf .
(cd $DIR && git submodule update --init --recursive)
(cd $DIR && bun install)
