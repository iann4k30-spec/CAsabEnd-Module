#!/system/bin/sh

# CAsabEnd Action — Vol Key / MMRL / KSU WebUI launcher
MODULE_CONFIG=/data/adb/.config/CAsabEnd
MODPATH=/data/adb/modules/CAsabEnd

if command -v ksuwebui >/dev/null 2>&1; then
  ksuwebui "file://$MODPATH/webroot/index.html"
elif command -v webui >/dev/null 2>&1; then
  webui "file://$MODPATH/webroot/index.html"
elif [ -n "$MMRL" ] || [ -f /data/adb/modules/MMRL/action.sh ]; then
  am start -a android.intent.action.VIEW -d "file://$MODPATH/webroot/index.html" 2>/dev/null
else
  # Fallback: toast notification
  echo "CAsabEnd: Buka WebUI dari KSUWebUI / MMRL" > /proc/self/fd/2 2>/dev/null
fi
