#!/bin/bash

LOGFILE="$HOME/Desktop/100block-log.txt"
LOCKFILE="/tmp/100block.lock"

# Acquire exclusive lock — if a previous prompt is still open, exit silently
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

# Ensure display is available (for systemd user service)
export DISPLAY="${DISPLAY:-:0.0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

TEXT=$(zenity --entry \
    --title="100 Block" \
    --text="What did you do in the last 10 minutes?" \
    --width=420 \
    2>/dev/null)

if [ -n "$TEXT" ]; then
    echo "[$(date '+%A, %B %d %Y — %I:%M %p')]  $TEXT" >> "$LOGFILE"
fi
