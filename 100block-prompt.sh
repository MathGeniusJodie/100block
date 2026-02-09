#!/bin/bash

LOGDIR="${LOGDIR:-$HOME/Desktop}"

logfile() {
    echo "$LOGDIR/100block-$(date '+%Y-%m-%d').txt"
}

# If another prompt is already open, log an empty slot and exit.
if pgrep -x zenity >/dev/null 2>&1; then
    echo "[$(date '+%I:%M %p')]" >> "$(logfile)"
    exit 0
else
    # Ensure display is available (for systemd user service)
    export DISPLAY="${DISPLAY:-:0.0}"
    export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

    TEXT=$(zenity --entry \
        --title="100 Block" \
        --text="What did you do in the last 10 minutes?" \
        --width=420 \
        2>/dev/null)
    echo "[$(date '+%I:%M %p')]  $TEXT" >> "$(logfile)"
fi
