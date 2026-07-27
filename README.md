<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=200&section=header&text=CAsabEnd&fontSize=80&fontAlignY=35&desc=Gebuk%20limit%20pake%20module%20ini&descAlignY=55&animation=twinkling" width="100%"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-v2026.07.27-bc8cff?style=for-the-badge&logo=github"/>
  <img src="https://img.shields.io/badge/Magisk-✓-00b894?style=for-the-badge&logo=magisk"/>
  <img src="https://img.shields.io/badge/KernelSU-✓-6c5ce7?style=for-the-badge&logo=linux"/>
  <img src="https://img.shields.io/badge/APatch-✓-e17055?style=for-the-badge&logo=android"/>
  <img src="https://img.shields.io/github/downloads/iann4k30-spec/CAsabEnd-Module/total?style=for-the-badge&logo=download&color=0984e3"/>
</p>

---

## 🔥 Apa itu CAsabEnd?

**CAsabEnd** adalah module performance dynamic buat Android.  
Dia bakal ngeboost HP kamu pas main game, tapi tetep adem pas dipake sehari-hari.

```
╔══════════════════════════════════════╗
║   ✅ CPU max performance             ║
║   ✅ GPU unlocked (KGSL/Mali)       ║
║   ✅ I/O scheduler optimized        ║
║   ✅ VM & Kernel tuning             ║
║   ✅ TCP network boost              ║
║   ✅ Thermal policy unlocked        ║
║   ✅ Rolling release — gampang update ║
╚══════════════════════════════════════╝
```

---

## 📱 Supported Devices

| SoC | Status |
|-----|--------|
| **Snapdragon** (KGSL + Adreno) | ✅ |
| **MediaTek** (PPM + GED) | ✅ |
| **Exynos** (Mali) | ✅ |
| **Unisoc** | ✅ |
| **Google Tensor** | ✅ |
| **Tegra** | ✅ |
| **Kirin** | ✅ |

---

## 🚀 Install

### Requirements
- Android 10+ (API 29)
- Magisk v20.4+ / KernelSU / APatch
- ARM / ARM64

### Cara Install
```
1. Download CAsabEnd-v2026.07.27.zip
2. Buka Magisk / KernelSU / APatch
3. Modules → Install from storage
4. Pilih zip nya
5. Reboot
```

**Dari WebUI KSU:**
- Buka module card CAsabEnd
- Langsung bisa ganti profile & liat status

---

## 🎮 Profile

| Profile | Icon | Fungsi |
|---------|------|--------|
| **Performance** | 🚀 | CPU max freq, GPU unlocked, I/O gaming, thermal disabled |
| **Balance** | ⚖️ | Daily use, normal freq, hemat tapi tetep responsif |
| **Powersave** | 🔋 | CPU min freq, GPU low power, core offline, baterai awet |

---

## 🔄 Rolling Release

CAsabEnd pake sistem **rolling release**.  
Artinya: tiap ada update tinggal flash zip baru, **gausah uninstall dulu**.

Update bakal ke-detek otomatis di WebUI module.

```
CAsabEnd v2026.07.27  ────────────▶  v2026.08.15
        └─ flash aja                    └─ flash aja
```

---

## 🛠 Teknis

```
CAsabEnd/
├── customize.sh          → Deteksi SoC + install
├── service.sh            → Boot service
├── init.sh               → Init trigger + version tracking
├── action.sh             → KSUWebUI / MMRL launcher
├── scripts/
│   └── casabend_profiler.sh → Core engine (15KB tuning)
└── webroot/
    └── index.html        → WebUI
```

---

## 📸 Screenshot

```
┌──────────────────────────────┐
│   CAsabEnd                    │
│   Status                      │
│  ┌──────┬──────┬──────┬─────┐ │
│  │Perf  │SoC   │Gov   │Freq │ │
│  │lance │snap..│sched.│1800 │ │
│  └──────┴──────┴──────┴─────┘ │
│                               │
│  [🚀 Performance]              │
│  [⚖️ Balance] ← active        │
│  [🔋 Powersave]                │
│                               │
│  #CAsabEnd #rolling           │
│  Module: CAsabEnd             │
│  Version: v2026.07.27         │
└──────────────────────────────┘
```

---

<p align="center">
  <b>Dibuat dengan 🔥 buat komunitas Android</b><br>
  <sub>CAsabEnd — gebuk limit pake module ini</sub>
</p>

<p align="center">
  <a href="https://github.com/iann4k30-spec/CAsabEnd-Module/releases">
    <img src="https://img.shields.io/github/v/release/iann4k30-spec/CAsabEnd-Module?style=for-the-badge&logo=github&color=bc8cff"/>
  </a>
</p>
