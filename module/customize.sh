#!/system/bin/sh

SKIPUNZIP=0
MODULE_CONFIG=/data/adb/.config/CAsabEnd

# ============== KSU / APatch / Magisk detection ==============
if [ "$KSU" = "true" ]; then
  echo ""
  echo "  ██████╗ █████╗ ███████╗ █████╗ ██████╗ ███████╗███╗   ██╗██████╗ "
  echo "  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗"
  echo "  ██║     ███████║███████╗███████║██████╔╝█████╗  ██╔██╗ ██║██║  ██║"
  echo "  ██║     ██╔══██║╚════██║██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║"
  echo "  ╚██████╗██║  ██║███████║██║  ██║██████╔╝███████╗██║ ╚████║██████╔╝"
  echo "  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═════╝ "
  echo ""
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║      CAsabEnd — gebuk limit pake module ini      ║"
  echo "  ║             Performance Module v2024.07.27        ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo ""
fi

if [ "$APATCH" = "true" ]; then
  echo ""
  echo "  ██████╗ █████╗ ███████╗ █████╗ ██████╗ ███████╗███╗   ██╗██████╗ "
  echo "  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗"
  echo "  ██║     ███████║███████╗███████║██████╔╝█████╗  ██╔██╗ ██║██║  ██║"
  echo "  ██║     ██╔══██║╚════██║██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║"
  echo "  ╚██████╗██║  ██║███████║██║  ██║██████╔╝███████╗██║ ╚████║██████╔╝"
  echo "  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═════╝ "
  echo ""
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║      CAsabEnd — gebuk limit pake module ini      ║"
  echo "  ║             Performance Module v2024.07.27        ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo ""
fi

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $MODPATH/scripts 0 0 0755 0755
  set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
  set_perm $MODPATH/service.sh 0 0 0755
  set_perm $MODPATH/uninstall.sh 0 0 0755
  set_perm $MODPATH/init.sh 0 0 0755
}

install_module() {
  mkdir -p $MODULE_CONFIG

  ui_print ""
  ui_print "  ██████╗ █████╗ ███████╗ █████╗ ██████╗ ███████╗███╗   ██╗██████╗ "
  ui_print "  ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗"
  ui_print "  ██║     ███████║███████╗███████║██████╔╝█████╗  ██╔██╗ ██║██║  ██║"
  ui_print "  ██║     ██╔══██║╚════██║██╔══██║██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║"
  ui_print "  ╚██████╗██║  ██║███████║██║  ██║██████╔╝███████╗██║ ╚████║██████╔╝"
  ui_print "  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═════╝ "
  ui_print ""
  ui_print "  ╔══════════════════════════════════════════════════╗"
  ui_print "  ║      CAsabEnd — gebuk limit pake module ini      ║"
  ui_print "  ║          🔥 Rolling Release — siap update        ║"
  ui_print "  ╚══════════════════════════════════════════════════╝"
  ui_print ""

  ui_print "  [*] Extracting module files..."
  unzip -o "$ZIPFILE" -d $MODPATH >&2
  rm -rf $MODPATH/module

  ui_print "  [*] Detecting architecture..."
  case $ARCH in
    arm|arm64) ui_print "  [+] ARM/ARM64 — aman gan" ;;
    *)
      ui_print "  [x] Architect mu gak didukung bro :("
      abort "Unsupported architecture"
      ;;
  esac

  ui_print "  [*] Detecting SoC vendor..."
  SOC=$(getprop ro.board.platform 2>/dev/null | tr '[:upper:]' '[:lower:]')
  SOC_VENDOR="generic"

  case $SOC in
    *mt*|*mediatek*) SOC_VENDOR="mediatek"; ui_print "  [+] MediaTek detected — PPM goblog mode: OFF" ;;
    *sm*|*sdm*|*kona*|*lahaina*|*taro*|*kalama*) SOC_VENDOR="snapdragon"; ui_print "  [+] Snapdragon detected — Adreno bakal kepanas" ;;
    *exynos*) SOC_VENDOR="exynos"; ui_print "  [+] Exynos detected — Mali siap digeber" ;;
    *sc*|*ums*) SOC_VENDOR="unisoc"; ui_print "  [+] Unisoc detected — gas pol" ;;
    *gs*) SOC_VENDOR="tensor"; ui_print "  [+] Google Tensor detected — biar mulus" ;;
    *tegra*) SOC_VENDOR="tegra"; ui_print "  [+] Tegra detected — Nintendo Switch vibes" ;;
    *kir*) SOC_VENDOR="kirin"; ui_print "  [+] Kirin detected — Huawei bangkit" ;;
    *) ui_print "  [?] SoC unknown — pake profile generic aja" ;;
  esac
  echo "$SOC_VENDOR" > $MODULE_CONFIG/soc_recognition

  if [ "$KSU" = "true" ]; then
    ui_print ""
    ui_print "  ╔══════════════════════════════════════════════════╗"
    ui_print "  ║   🔧 KernelSU Userspace detected!               ║"
    ui_print "  ║   WebUI bisa dibuka dari module card             ║"
    ui_print "  ╚══════════════════════════════════════════════════╝"

    if [ -d /data/adb/ksu/modules.img ]; then
      mkdir -p /data/adb/ksu/bin
      cp -f $MODPATH/system/bin/* /data/adb/ksu/bin/ 2>/dev/null
    fi
  fi

  if [ "$APATCH" = "true" ]; then
    ui_print ""
    ui_print "  ╔══════════════════════════════════════════════════╗"
    ui_print "  ║   🔧 APatch Userspace detected!                 ║"
    ui_print "  ║   Module siap tempur                              ║"
    ui_print "  ╚══════════════════════════════════════════════════╝"

    if [ -d /data/adb/ap ]; then
      mkdir -p /data/adb/ap/bin
      cp -f $MODPATH/system/bin/* /data/adb/ap/bin/ 2>/dev/null
    fi
  fi

  ui_print ""
  ui_print "  [*] Setting permissions..."
  set_permissions

  ui_print "  [*] Initializing config..."
  mkdir -p $MODULE_CONFIG/status
  mkdir -p $MODULE_CONFIG/logs

  if [ ! -f $MODULE_CONFIG/config.json ]; then
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
  fi

  echo "balance" > $MODULE_CONFIG/status/profile
  echo "$DEFAULT_GOV" > $MODULE_CONFIG/status/governor 2>/dev/null || echo "schedutil" > $MODULE_CONFIG/status/governor

  ui_print ""
  ui_print "  ╔══════════════════════════════════════════════════╗"
  ui_print "  ║   ✅ CAsabEnd siap tempur!                       ║"
  ui_print "  ║   Reboot biar ngerasain bedanya                ║"
  ui_print "  ║                                                 ║"
  ui_print "  ║   Rolling release — tinggal flash update        ║"
  ui_print "  ║   kalo ada versi baru, gausah uninstall         ║"
  ui_print "  ╚══════════════════════════════════════════════════╝"
  ui_print ""
}

set_permissions
