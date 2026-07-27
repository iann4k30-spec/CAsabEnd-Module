#!/system/bin/sh

# CAsabEnd Profiler — Core performance engine
MODULE_CONFIG=/data/adb/.config/CAsabEnd
SOC_VENDOR=$(cat $MODULE_CONFIG/soc_recognition 2>/dev/null || echo "generic")
LOG_FILE=$MODULE_CONFIG/logs/profiler.log

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

apply() {
  local file=$1
  local value=$2
  [ ! -f "$file" ] && return 1
  chmod 0644 "$file" 2>/dev/null
  echo "$value" > "$file" 2>/dev/null && return 0 || return 1
}

write() { apply "$@"; }

which_minfreq() { echo "$1" | tr ' ' '\n' | sort -n | head -1; }
which_maxfreq() { echo "$1" | tr ' ' '\n' | sort -n | tail -1; }
which_midfreq() { echo "$1" | tr ' ' '\n' | sort -n | awk '{a[NR]=$1} END{print a[int(NR/2)+1]}'; }

change_cpu_gov() {
  local gov=$1
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -f "$policy/scaling_governor" ] && apply "$policy/scaling_governor" "$gov"
  done
  for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && apply "$cpu" "$gov"
  done
}

cpufreq_max_perf() {
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue
    local maxfreq=$(cat "$policy/scaling_max_freq" 2>/dev/null)
    local avail_govs=$(cat "$policy/scaling_available_governors" 2>/dev/null)
    [ -z "$maxfreq" ] && continue
    apply "$policy/scaling_min_freq" "$maxfreq"
    apply "$policy/scaling_max_freq" "$maxfreq"
    case "$avail_govs" in
      *performance*) apply "$policy/scaling_governor" "performance" ;;
      *schedutil*) apply "$policy/scaling_governor" "schedutil" ;;
      *interactive*) apply "$policy/scaling_governor" "interactive" ;;
    esac
  done
}

cpufreq_unlock() {
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue
    local maxfreq=$(cat "$policy/cpuinfo_max_freq" 2>/dev/null)
    local minfreq=$(cat "$policy/cpuinfo_min_freq" 2>/dev/null)
    [ -z "$maxfreq" ] && continue
    apply "$policy/scaling_max_freq" "$maxfreq"
    apply "$policy/scaling_min_freq" "$minfreq"
  done
}

cpufreq_min_perf() {
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$policy" ] || continue
    local minfreq=$(cat "$policy/cpuinfo_min_freq" 2>/dev/null)
    local avail_govs=$(cat "$policy/scaling_available_governors" 2>/dev/null)
    [ -z "$minfreq" ] && continue
    apply "$policy/scaling_max_freq" "$minfreq"
    apply "$policy/scaling_min_freq" "$minfreq"
    case "$avail_govs" in
      *powersave*) apply "$policy/scaling_governor" "powersave" ;;
      *schedutil*) apply "$policy/scaling_governor" "schedutil" ;;
      *conservative*) apply "$policy/scaling_governor" "conservative" ;;
    esac
  done
}

gpu_max_perf() {
  for gpu in /sys/class/kgsl/kgsl-3d0; do
    [ ! -d "$gpu" ] && continue
    apply "$gpu/max_pwrlevel" 0
    apply "$gpu/min_pwrlevel" 0
    apply "$gpu/force_bus_on" 1
    apply "$gpu/force_rail_on" 1
    apply "$gpu/force_clk_on" 1
    apply "$gpu/bus_split" 0
    apply "$gpu/throttling" 0
    apply "$gpu/thermal_pwrlevel" 0
    apply "$gpu/popp" 0
  done
  for gpu in /sys/class/devfreq/*gpu* /sys/class/devfreq/*mali* /sys/class/devfreq/*kgsl*; do
    [ -d "$gpu" ] || continue
    local max_freq=$(cat "$gpu/max_freq" 2>/dev/null || cat "$gpu/available_frequencies" 2>/dev/null | tr ' ' '\n' | sort -n | tail -1)
    [ -z "$max_freq" ] && continue
    apply "$gpu/min_freq" "$max_freq"
    apply "$gpu/max_freq" "$max_freq"
    apply "$gpu/governor" "performance"
  done
  apply "/sys/class/misc/mali0/device/power_policy" "always_on"
  apply "/sys/module/mali/parameters/mali_boost" 1
}

gpu_min_perf() {
  for gpu in /sys/class/kgsl/kgsl-3d0; do
    [ ! -d "$gpu" ] && continue
    local num_pwrs=$(cat "$gpu/num_pwrlevels" 2>/dev/null)
    [ -n "$num_pwrs" ] && num_pwrs=$((num_pwrs - 1))
    apply "$gpu/min_pwrlevel" "$num_pwrs"
    apply "$gpu/max_pwrlevel" "$num_pwrs"
    apply "$gpu/force_bus_on" 0
    apply "$gpu/force_rail_on" 0
    apply "$gpu/force_clk_on" 0
  done
  for gpu in /sys/class/devfreq/*gpu* /sys/class/devfreq/*mali* /sys/class/devfreq/*kgsl*; do
    [ -d "$gpu" ] || continue
    local min_freq=$(cat "$gpu/available_frequencies" 2>/dev/null | tr ' ' '\n' | sort -n | head -1)
    [ -z "$min_freq" ] && min_freq=$(cat "$gpu/min_freq" 2>/dev/null)
    [ -z "$min_freq" ] && continue
    apply "$gpu/min_freq" "$min_freq"
    apply "$gpu/max_freq" "$min_freq"
    apply "$gpu/governor" "powersave"
  done
}

gpu_normal() {
  for gpu in /sys/class/kgsl/kgsl-3d0; do
    [ ! -d "$gpu" ] && continue
    apply "$gpu/min_pwrlevel" 0
    apply "$gpu/max_pwrlevel" 0
    apply "$gpu/force_bus_on" 0
    apply "$gpu/force_rail_on" 0
    apply "$gpu/force_clk_on" 0
    apply "$gpu/bus_split" 1
    apply "$gpu/throttling" 1
    apply "$gpu/thermal_pwrlevel" 0
    apply "$gpu/popp" 1
  done
  for gpu in /sys/class/devfreq/*gpu* /sys/class/devfreq/*mali* /sys/class/devfreq/*kgsl*; do
    [ -d "$gpu" ] || continue
    apply "$gpu/min_freq" "$(cat "$gpu/available_frequencies" 2>/dev/null | tr ' ' '\n' | sort -n | head -1)"
    apply "$gpu/max_freq" "$(cat "$gpu/max_freq" 2>/dev/null)"
    apply "$gpu/governor" "simple_ondemand"
  done
}

snapdragon_performance() {
  apply /sys/class/kgsl/kgsl-3d0/max_pwrlevel 0
  apply /sys/class/kgsl/kgsl-3d0/min_pwrlevel 0
  apply /sys/class/kgsl/kgsl-3d0/force_bus_on 1
  apply /sys/class/kgsl/kgsl-3d0/force_rail_on 1
  apply /sys/class/kgsl/kgsl-3d0/force_clk_on 1
  apply /sys/class/kgsl/kgsl-3d0/bus_split 0
  apply /sys/class/kgsl/kgsl-3d0/throttling 0
  apply /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel 0
  apply /sys/class/kgsl/kgsl-3d0/popp 0
  apply /sys/kernel/gpu/gpu_clock_control "1"
  apply /sys/kernel/gpu/gpu_busy 1
  apply /sys/module/adreno_idler/parameters/adreno_idler_active 0
  apply /sys/kernel/debug/kgsl/kgsl-3d0/bus_dcvs "0"
  apply /sys/kernel/debug/kgsl/kgsl-3d0/force_rail_on 1
}

snapdragon_normal() {
  apply /sys/class/kgsl/kgsl-3d0/bus_split 1
  apply /sys/class/kgsl/kgsl-3d0/throttling 1
  apply /sys/class/kgsl/kgsl-3d0/thermal_pwrlevel 0
  apply /sys/class/kgsl/kgsl-3d0/popp 1
  apply /sys/module/adreno_idler/parameters/adreno_idler_active 1
}

snapdragon_powersave() {
  local npwrs=$(cat /sys/class/kgsl/kgsl-3d0/num_pwrlevels 2>/dev/null)
  npwrs=$((npwrs - 1))
  apply /sys/class/kgsl/kgsl-3d0/min_pwrlevel "$npwrs"
  apply /sys/class/kgsl/kgsl-3d0/max_pwrlevel "$npwrs"
  apply /sys/class/kgsl/kgsl-3d0/force_bus_on 0
  apply /sys/class/kgsl/kgsl-3d0/force_rail_on 0
  apply /sys/class/kgsl/kgsl-3d0/force_clk_on 0
}

mediatek_performance() {
  apply /proc/ppm/enabled 0
  for p in 1 2 3 4 5 6 7 8 9; do apply /proc/ppm/policy_status "$p 0"; done
  apply /proc/cpufreq/cpufreq_forced_freq "1"
  apply /proc/cpufreq/cpufreq_cci_mode "1"
  apply /sys/module/ged/parameters/boost_amp 1
  apply /sys/module/ged/parameters/ged_boost_enable 1
  apply /sys/module/ged/parameters/ged_smart_boost 1
  apply /sys/module/ged/parameters/gpu_bottom_freq 0
  apply /sys/module/ged/parameters/gpu_idle 0
  apply /sys/module/ged/parameters/is_GED_KPI_enabled 1
  apply /sys/kernel/ged/boost_enable 1
  apply /sys/kernel/ged/gpu_boost 1
  apply /sys/kernel/ged/hal_boost 1
}

mediatek_normal() {
  apply /proc/ppm/enabled 1
  apply /sys/module/ged/parameters/gpu_idle 1
  apply /sys/kernel/ged/boost_enable 0
}

mediatek_powersave() {
  apply /proc/ppm/enabled 1
  apply /sys/module/ged/parameters/gpu_bottom_freq 1
  apply /sys/module/ged/parameters/gpu_idle 1
  apply /sys/module/ged/parameters/boost_amp 0
  apply /sys/kernel/ged/boost_enable 0
}

exynos_performance() {
  apply /sys/class/misc/mali0/device/power_policy "always_on"
  apply /sys/devices/14ac0000.mali/dvfs_max_lock 100
  apply /sys/devices/14ac0000.mali/dvfs_min_lock 100
  apply /sys/kernel/gpu/gpu_max_clock 100
  apply /sys/kernel/gpu/gpu_min_clock 100
  apply /sys/kernel/gpu/gpu_clock_control 1
  apply /sys/kernel/gpu/gpu_dvfs 0
}

exynos_normal() {
  apply /sys/class/misc/mali0/device/power_policy "job_round_robin"
  apply /sys/kernel/gpu/gpu_dvfs 1
}

exynos_powersave() {
  apply /sys/class/misc/mali0/device/power_policy "coarse_demand"
  apply /sys/devices/14ac0000.mali/dvfs_min_lock 0
  apply /sys/devices/14ac0000.mali/dvfs_max_lock 0
}

io_tune() {
  local mode=$1
  for block in /sys/block/*; do
    [ -d "$block/queue" ] || continue
    local sched=$(cat "$block/queue/scheduler" 2>/dev/null)
    case "$mode" in
      performance)
        case "$sched" in *kyber*) apply "$block/queue/scheduler" "kyber" ;;
          *fiops*) apply "$block/queue/scheduler" "fiops" ;;
          *bfq*) apply "$block/queue/scheduler" "bfq" ;;
          *deadline*) apply "$block/queue/scheduler" "deadline" ;;
          *noop*) apply "$block/queue/scheduler" "noop" ;; esac
        apply "$block/queue/read_ahead_kb" 512
        apply "$block/queue/nr_requests" 256
        ;;
      powersave)
        case "$sched" in *cfq*) apply "$block/queue/scheduler" "cfq" ;;
          *noop*) apply "$block/queue/scheduler" "noop" ;;
          *deadline*) apply "$block/queue/scheduler" "deadline" ;; esac
        apply "$block/queue/read_ahead_kb" 128
        apply "$block/queue/nr_requests" 64
        ;;
      *)
        case "$sched" in *cirrus*) apply "$block/queue/scheduler" "cirrus" ;;
          *maple*) apply "$block/queue/scheduler" "maple" ;;
          *fiops*) apply "$block/queue/scheduler" "fiops" ;;
          *bfq*) apply "$block/queue/scheduler" "bfq" ;; esac
        apply "$block/queue/read_ahead_kb" 256
        apply "$block/queue/nr_requests" 128
        ;;
    esac
  done
}

kernel_tune() {
  local mode=$1
  case "$mode" in
    performance)
      apply /proc/sys/kernel/panic 0
      apply /proc/sys/kernel/panic_on_oops 0
      apply /proc/sys/kernel/panic_on_rcu_stall 0
      apply /proc/sys/kernel/softlockup_panic 0
      apply /proc/sys/kernel/hung_task_panic 0
      apply /proc/sys/vm/dirty_ratio 90
      apply /proc/sys/vm/dirty_background_ratio 60
      apply /proc/sys/vm/dirty_expire_centisecs 3000
      apply /proc/sys/vm/dirty_writeback_centisecs 1500
      apply /proc/sys/vm/vfs_cache_pressure 200
      apply /proc/sys/vm/swappiness 10
      apply /proc/sys/vm/min_free_kbytes 8192
      apply /proc/sys/vm/compact_memory 1
      ;;
    powersave)
      apply /proc/sys/vm/dirty_ratio 30
      apply /proc/sys/vm/dirty_background_ratio 10
      apply /proc/sys/vm/dirty_expire_centisecs 6000
      apply /proc/sys/vm/dirty_writeback_centisecs 3000
      apply /proc/sys/vm/vfs_cache_pressure 50
      apply /proc/sys/vm/swappiness 60
      apply /proc/sys/vm/min_free_kbytes 4096
      ;;
    *)
      apply /proc/sys/vm/dirty_ratio 50
      apply /proc/sys/vm/dirty_background_ratio 20
      apply /proc/sys/vm/dirty_expire_centisecs 3000
      apply /proc/sys/vm/dirty_writeback_centisecs 1500
      apply /proc/sys/vm/vfs_cache_pressure 100
      apply /proc/sys/vm/swappiness 30
      apply /proc/sys/vm/min_free_kbytes 6144
      ;;
  esac
}

tcp_tune() {
  local mode=$1
  case "$mode" in
    performance)
      apply /proc/sys/net/core/rmem_default 262144
      apply /proc/sys/net/core/rmem_max 4194304
      apply /proc/sys/net/core/wmem_default 262144
      apply /proc/sys/net/core/wmem_max 4194304
      apply /proc/sys/net/ipv4/tcp_rmem "4096 87380 33554432"
      apply /proc/sys/net/ipv4/tcp_wmem "4096 65536 33554432"
      apply /proc/sys/net/ipv4/tcp_congestion_control "bbr"
      apply /proc/sys/net/ipv4/tcp_slow_start_after_idle 0
      ;;
    *)
      apply /proc/sys/net/core/rmem_default 131072
      apply /proc/sys/net/core/rmem_max 2097152
      apply /proc/sys/net/ipv4/tcp_rmem "4096 87380 16777216"
      apply /proc/sys/net/ipv4/tcp_wmem "4096 65536 16777216"
      apply /proc/sys/net/ipv4/tcp_congestion_control "cubic"
      ;;
  esac
}

thermal_tune() {
  local mode=$1
  case "$mode" in
    performance)
      apply /sys/module/msm_thermal/parameters/enabled N
      apply /sys/module/msm_thermal/parameters/temp_threshold 90
      apply /sys/module/msm_thermal/parameters/core_limit_temp_degC 90
      apply /sys/module/msm_thermal/core_control/enabled 0
      apply /sys/devices/soc.0/qcom,bcl.60/mode "disabled"
      for tz in /sys/class/thermal/thermal_zone*/policy; do
        apply "$tz" "performance"
      done
      ;;
    *)
      apply /sys/module/msm_thermal/parameters/enabled Y
      apply /sys/module/msm_thermal/core_control/enabled 1
      apply /sys/devices/soc.0/qcom,bcl.60/mode "enabled"
      for tz in /sys/class/thermal/thermal_zone*/policy; do
        apply "$tz" "step_wise"
      done
      ;;
  esac
}

sched_tune() {
  local mode=$1
  case "$mode" in
    performance)
      apply /proc/sys/kernel/sched_child_runs_first 1
      apply /proc/sys/kernel/sched_autogroup_enabled 0
      apply /proc/sys/kernel/sched_tunable_scaling 1
      apply /proc/sys/kernel/sched_cfs_boost 1
      apply /proc/sys/kernel/sched_walt_init_task_load_pct 50
      apply /proc/sys/kernel/sched_migration_cost_ns 500000
      apply /proc/sys/kernel/sched_min_granularity_ns 1000000
      apply /proc/sys/kernel/sched_wakeup_granularity_ns 1500000
      apply /proc/sys/kernel/sched_nr_migrate 64
      apply /proc/sys/kernel/sched_schedstats 0
      ;;
    *)
      apply /proc/sys/kernel/sched_autogroup_enabled 1
      apply /proc/sys/kernel/sched_cfs_boost 0
      apply /proc/sys/kernel/sched_migration_cost_ns 500000
      apply /proc/sys/kernel/sched_min_granularity_ns 750000
      apply /proc/sys/kernel/sched_wakeup_granularity_ns 1000000
      apply /proc/sys/kernel/sched_nr_migrate 32
      ;;
  esac
}

performance_profile() {
  log "PERFORMANCE profile"
  change_cpu_gov "performance"
  cpufreq_max_perf
  gpu_max_perf
  case "$SOC_VENDOR" in
    mediatek) mediatek_performance ;;
    snapdragon) snapdragon_performance ;;
    exynos) exynos_performance ;;
  esac
  io_tune "performance"
  kernel_tune "performance"
  tcp_tune "performance"
  thermal_tune "performance"
  sched_tune "performance"
  apply /proc/touchpanel/game_switch_enable 1
  apply /proc/touchpanel/oplus_tp_limit_enable 0
  apply /proc/touchpanel/oppo_tp_limit_enable 0
  apply /sys/module/logger/parameters/log_mode 0
}

balance_profile() {
  log "BALANCE profile"
  local BAL_GOV=$(grep -o '"balance"[^,]*' $MODULE_CONFIG/config.json 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
  [ -z "$BAL_GOV" ] && BAL_GOV="schedutil"
  change_cpu_gov "$BAL_GOV"
  cpufreq_unlock
  gpu_normal
  case "$SOC_VENDOR" in
    mediatek) mediatek_normal ;;
    snapdragon) snapdragon_normal ;;
    exynos) exynos_normal ;;
  esac
  io_tune "balance"
  kernel_tune "balance"
  tcp_tune "balance"
  thermal_tune "balance"
  sched_tune "balance"
  apply /proc/touchpanel/game_switch_enable 0
  apply /sys/module/logger/parameters/log_mode 1
}

powersave_profile() {
  log "POWERSAVE profile"
  local PS_GOV=$(grep -o '"powersave"[^,]*' $MODULE_CONFIG/config.json 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
  [ -z "$PS_GOV" ] && PS_GOV="schedutil"
  change_cpu_gov "$PS_GOV"
  cpufreq_min_perf
  gpu_min_perf
  case "$SOC_VENDOR" in
    mediatek) mediatek_powersave ;;
    snapdragon) snapdragon_powersave ;;
    exynos) exynos_powersave ;;
  esac
  io_tune "powersave"
  kernel_tune "powersave"
  thermal_tune "powersave"
  local total_cpus=$(ls -d /sys/devices/system/cpu/cpu[0-9]* 2>/dev/null | wc -l)
  if [ "$total_cpus" -gt 4 ]; then
    local half=$((total_cpus / 2))
    for cpu in $(seq $half $((total_cpus - 1))); do
      apply "/sys/devices/system/cpu/cpu$cpu/online" 0
    done
  fi
}
