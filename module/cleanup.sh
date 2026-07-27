#!/system/bin/sh

MODULE_CONFIG=/data/adb/.config/CAsabEnd
MODPATH=/data/adb/modules/CAsabEnd

if [ -d "$MODPATH" ] && [ ! -f "$MODPATH/disable" ]; then
  log -t CAsabEnd "Cleanup: module active, keeping config"
fi

rm -f /data/adb/service.d/.casabend_cleanup.sh
exit 0
