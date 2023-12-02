#!/bin/sh
DIR=$(dirname $0)
sed 's/:/\//g;s/git@/https:\/\//g' $DIR/.ssh.gitmodules > $DIR/.gitmodules
