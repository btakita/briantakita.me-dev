#!/bin/sh
DIR_DEFAULT=$(dirname $0)/..
DIR="${DIR:-$DIR_DEFAULT}"

cd $DIR
tmux rename-window dev
tmux split-window -v $SHELL
tmux send-keys 'tig' 'C-m'
tmux select-pane -t 0

tmux select-window -t 0
