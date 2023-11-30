#!/bin/sh
cd app/briantakita.me
pwd
bun -b run build
(cd .vercel/output/functions/render.func && touch bun.lockb)
