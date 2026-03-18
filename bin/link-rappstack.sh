#!/usr/bin/env bash
# Symlink @rappstack/* packages to rappstack-dev source for local dev
# Run after `bun install` to restore symlinks
set -e
RAPPSTACK_DEV="/home/brian/work/btakita/agent-loop/src/rappstack-dev/lib"
NODE_MODULES="$(dirname "$0")/../node_modules/@rappstack"

for pkg in domain--any--blog domain--server domain--server--blog \
           ui--any ui--any--blog ui--browser ui--browser--blog \
           ui--server ui--server--blog; do
  rm -rf "$NODE_MODULES/$pkg"
  ln -sf "$RAPPSTACK_DEV/$pkg" "$NODE_MODULES/$pkg"
done
echo "Linked @rappstack/* -> $RAPPSTACK_DEV"
