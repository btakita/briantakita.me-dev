#!/bin/sh
pwd
DIR=$(dirname $0)
(cd $DIR/app/briantakita.me && bun -b run build)
