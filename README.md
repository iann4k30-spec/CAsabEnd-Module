<p align="center">
  <img src="logo.png" width="160" alt="CAsabEnd Logo" style="border:3px solid #000;box-shadow:6px 6px 0 #000">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-rolling-bc8cff?style=for-the-badge&logo=github"/>
  <img src="https://img.shields.io/badge/Magisk-✓-00b894?style=for-the-badge&logo=magisk"/>
  <img src="https://img.shields.io/badge/KernelSU-✓-6c5ce7?style=for-the-badge&logo=linux"/>
  <img src="https://img.shields.io/badge/APatch-✓-e17055?style=for-the-badge&logo=android"/>
  <img src="https://img.shields.io/github/downloads/iann4k30-spec/CAsabEnd-Module/total?style=for-the-badge&logo=download&color=0984e3"/>
</p>

---

## About

CAsabEnd is a dynamic performance module for Android. It maximizes device performance during gaming and preserves battery during daily use.

Built on the proven Encore codebase with additional refinements and rolling release system.

---

## Features

- **CPU** — frequency scaling, governor switching, stune/top-app boost
- **GPU** — KGSL (Snapdragon), GED (MediaTek), Mali (Exynos) optimization
- **I/O** — scheduler tuning, read-ahead, queue depth
- **Memory** — VM dirty ratio, swappiness, vfs cache, compaction
- **Network** — TCP buffer, congestion control (BBR), fastopen
- **Thermal** — policy control, threshold adjustment
- **Scheduler** — WALT tuning, sched boost, cpuset management
- **WebUI** — profile switching, configuration, status monitoring

---

## Platform Support

| Platform | Tuning |
|----------|--------|
| Snapdragon (KGSL + Adreno) | GPU pwrlevel, bus dcvs, adreno idler |
| MediaTek (PPM + GED) | PPM policy, GED boost, gx game mode |
| Exynos (Mali) | DVFS lock, power policy |

---

## Profiles

| Mode | Behavior |
|------|----------|
| **Performance** | Max CPU/GPU freq, thermal off, sched boost 100, I/O gaming |
| **Balance** | Default freq, normal governor, daily use |
| **Powersave** | Min freq, GPU low power, core offline |

---

## Requirements

- Android 10+ (API 29)
- Magisk v20.4+ / KernelSU / APatch
- ARM64 / ARM

---

## Install

```
1. Download CAsabEnd build artifact
2. Flash via Magisk / KernelSU / APatch
3. Reboot
```

WebUI accessible from KSU module card, KsuWebUI Standalone, or MMRL.

---

## Build from Source

```bash
git clone https://github.com/iann4k30-spec/CAsabEnd-Module
cd CAsabEnd-Module

# Build daemon (NDK required)
ndk-build -j$(nproc)

# Build WebUI (Bun required)
cd webui
bun install
bun run build
cp -r dist/* ../module/webroot

# Package
cd ..
bash .github/scripts/compile_zip.sh
```

GitHub Actions also produces build artifacts automatically on push.

---

<p align="center">
  <a href="https://github.com/iann4k30-spec/CAsabEnd-Module/releases">
    <img src="https://img.shields.io/github/v/release/iann4k30-spec/CAsabEnd-Module?style=for-the-badge&logo=github&color=bc8cff"/>
  </a>
</p>
