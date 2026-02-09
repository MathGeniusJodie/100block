#!/bin/bash

LOGDIR="${LOGDIR:-$HOME/Desktop}"
LOCKFILE="${LOCKFILE:-/tmp/100block.lock}"
STATEFILE="${STATEFILE:-/tmp/100block.last-slot}"
INTERVAL_SEC="${INTERVAL_SEC:-600}"
LATE_GRACE_SEC="${LATE_GRACE_SEC:-120}"

logfile() {
    echo "$LOGDIR/100block-$(date '+%Y-%m-%d').txt"
}

log_empty_slot() {
    local slot="$1"
    local slot_epoch stamp
    slot_epoch=$((slot * INTERVAL_SEC))
    stamp=$(date -d "@$slot_epoch" '+%I:%M %p')
    echo "[$stamp]" >> "$(logfile)"
}

# Acquire exclusive lock — if a previous prompt is still open, log a skip and exit
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    now_epoch=$(date +%s)
    current_slot=$((now_epoch / INTERVAL_SEC))
    log_empty_slot "$current_slot"
    exit 0
fi

now_epoch=$(date +%s)
current_slot=$((now_epoch / INTERVAL_SEC))
slot_epoch=$((current_slot * INTERVAL_SEC))
slot_age=$((now_epoch - slot_epoch))

last_slot=$((current_slot - 1))
if [ -f "$STATEFILE" ]; then
    state_value=$(cat "$STATEFILE" 2>/dev/null)
    if [[ "$state_value" =~ ^[0-9]+$ ]]; then
        last_slot="$state_value"
    fi
fi

# Avoid duplicate work if the same scheduled slot is invoked again.
if [ "$last_slot" -ge "$current_slot" ]; then
    exit 0
fi

# Backfill missed 10-minute slots so gaps are visible in the daily log.
slot=$((last_slot + 1))
while [ "$slot" -lt "$current_slot" ]; do
    log_empty_slot "$slot"
    slot=$((slot + 1))
done

# If this activation is late (for example, queued behind an open prompt),
# record an empty slot and do not show another prompt.
if [ "$slot_age" -gt "$LATE_GRACE_SEC" ]; then
    log_empty_slot "$current_slot"
    printf '%s\n' "$current_slot" > "$STATEFILE"
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

printf '%s\n' "$current_slot" > "$STATEFILE"
