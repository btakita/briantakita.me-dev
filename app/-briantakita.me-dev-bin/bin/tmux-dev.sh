#!/bin/sh
DIR_DEFAULT=$(dirname $0)/../..
DIR="${DIR:-$DIR_DEFAULT}"

cd $DIR
tmux rename-window dev
tmux split-window -v $SHELL
tmux send-keys 'tig' 'C-m'
tmux select-pane -t 1
tmux split-window -h $SHELL
tmux send-keys "cd $DIR/app/briantakita.me; bun -b run dev" 'C-m'
tmux select-pane -t 1

tmux select-window -t 0
