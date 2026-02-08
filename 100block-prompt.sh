#!/bin/bash

LOGDIR="$HOME/Desktop"
LOCKFILE="/tmp/100block.lock"

logfile() {
    echo "$LOGDIR/100block-$(date '+%Y-%m-%d').txt"
}

# Acquire exclusive lock — if a previous prompt is still open, log a skip and exit
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    echo "[$(date '+%I:%M %p')]" >> "$(logfile)"
    exit 0
fi

# Ensure display is available (for systemd user service)
export DISPLAY="${DISPLAY:-:0.0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

TEXT=$(zenity --entry \
    --title="100 Block" \
    --text="What did you do in the last 10 minutes?" \
    --width=420 \
    2>/dev/null)

if [ -n "$TEXT" ]; then
    echo "[$(date '+%I:%M %p')]  $TEXT" >> "$(logfile)"
fi
