#!/system/bin/sh

# CAsabEnd Init — early boot init trigger
# Dipanggil dari service.sh atau /init untuk:
#  - Rolling update check
#  - Recovery mode
#  - Version tracking

MODULE_CONFIG=/data/adb/.config/CAsabEnd
MODPATH=/data/adb/modules/CAsabEnd
LOG_FILE=$MODULE_CONFIG/logs/init.log

mkdir -p $MODULE_CONFIG/logs 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Init triggered" >> $LOG_FILE

# Check if this is a fresh install -> recovery mode
if [ ! -f "$MODULE_CONFIG/config.json" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Fresh install detected — creating config" >> $LOG_FILE
  mkdir -p $MODULE_CONFIG/status

  cat > $MODULE_CONFIG/config.json <<EOF
{
  "preferences": {
    "enforce_lite_mode": false,
    "disable_tweaks": false,
    "log_level": 2
  },
  "cpu_governor": {
    "balance": "schedutil",
    "powersave": "schedutil"
  }
}
EOF
  echo "balance" > $MODULE_CONFIG/status/profile
fi

# Detect SoC
SOC_VENDOR=$(cat $MODULE_CONFIG/soc_recognition 2>/dev/null)
if [ -z "$SOC_VENDOR" ]; then
  SOC=$(getprop ro.board.platform 2>/dev/null | tr '[:upper:]' '[:lower:]')
  case $SOC in
    *mt*|*mediatek*) echo "mediatek" > $MODULE_CONFIG/soc_recognition ;;
    *sm*|*sdm*|*kona*|*lahaina*|*taro*|*kalama*) echo "snapdragon" > $MODULE_CONFIG/soc_recognition ;;
    *exynos*) echo "exynos" > $MODULE_CONFIG/soc_recognition ;;
    *sc*|*ums*) echo "unisoc" > $MODULE_CONFIG/soc_recognition ;;
    *gs*) echo "tensor" > $MODULE_CONFIG/soc_recognition ;;
    *tegra*) echo "tegra" > $MODULE_CONFIG/soc_recognition ;;
    *kir*) echo "kirin" > $MODULE_CONFIG/soc_recognition ;;
  esac
fi

# Version tracking
VERSION_FILE=$MODPATH/version
if [ -f "$VERSION_FILE" ]; then
  CURRENT_VER=$(cat $VERSION_FILE)
  setprop casabend.version "$CURRENT_VER" 2>/dev/null
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Version: $CURRENT_VER" >> $LOG_FILE
fi

exit 0
