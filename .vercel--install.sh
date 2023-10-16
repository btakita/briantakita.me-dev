#!/bin/sh
./.gitmodules--https.sh
git submodule update --init --recursive
bun install