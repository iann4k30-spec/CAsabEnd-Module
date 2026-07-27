#!/system/bin/sh

MODPATH=${0%/*}
MODULE_CONFIG=/data/adb/.config/CAsabEnd
LOG_DIR=$MODULE_CONFIG/logs
LOG_FILE=$LOG_DIR/service.log
VERSION_FILE=$MODPATH/version

mkdir -p $LOG_DIR $MODULE_CONFIG/status

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

log "=== CAsabEnd service starting ==="

# Wait for boot completion
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 15

log "Boot completed"

# Save default governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -f "$cpu" ] && DEFAULT_GOV=$(cat "$cpu") && break
done
[ -n "$DEFAULT_GOV" ] && echo "$DEFAULT_GOV" > $MODULE_CONFIG/status/governor

# Source profiler
. $MODPATH/scripts/casabend_profiler.sh

# Apply balance on boot
balance_profile
echo "balance" > $MODULE_CONFIG/status/profile

log "Balance profile applied"

# ---------- Rolling release check ----------
# Will check update once a day via /init trigger
if [ -f /init ] && [ -f "$VERSION_FILE" ]; then
  log "Device uses /init — update check ready"
  # Flag for update check at next boot
  setprop casabend.version "$(cat $VERSION_FILE)" 2>/dev/null
fi

# ---------- Runtime monitor ----------
while true; do
  sleep 30

  # Detect battery saver
  BATTERY_SAVER=$(settings get global low_power 2>/dev/null)
  SCREEN_ON=$(dumpsys power 2>/dev/null | grep -E "mScreenOn|Display Power" | head -1)

  if [ "$BATTERY_SAVER" = "1" ]; then
    CURRENT_PROFILE=$(cat $MODULE_CONFIG/status/profile 2>/dev/null)
    if [ "$CURRENT_PROFILE" != "powersave" ]; then
      powersave_profile
      echo "powersave" > $MODULE_CONFIG/status/profile
      log "Battery saver ON → powersave profile"
    fi
  else
    CURRENT_PROFILE=$(cat $MODULE_CONFIG/status/profile 2>/dev/null)
    if [ "$CURRENT_PROFILE" = "powersave" ]; then
      balance_profile
      echo "balance" > $MODULE_CONFIG/status/profile
      log "Battery saver OFF → balance profile"
    fi
  fi
done
