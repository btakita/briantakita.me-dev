#!/bin/sh
sed 's/:/\//g;s/git@/https:\/\//g' .ssh.gitmodules > .gitmodules
