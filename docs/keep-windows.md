# Keep Windows (or a VM) for these workloads

Honest **“no Kinoite parity / keep Win32 or a VM”** list for a **power-user Windows 11** host (DCC, games, creative, Razer/Vendor stacks). Cross-link: **`app-mapping.md`**, **`kinoite-wsl2.md`**, **`provisional-configuration-index.md`**.

## Always / usually Windows-only (for this class of machine)

- **Autodesk 3ds Max** (e.g. 2026) + many Max-only plugins, **USD/Arnold/Substance** stacks where licenses are **Windows-locked** — use **Kinoite** for **Blender**/**Maya for Linux** where licensed; else **this OS** or a **dedicated Windows VM** with **GPU** passthrough.  
- **Kernel-level or invasive anti-cheat** multiplayer (varies by title) — Proton/Steam on Linux is **not** a promise; keep **retail Windows** for those games.  
- **Windows-only DAW/DSP in Voicemod-grade** routing (deep virtual cables and vendor ASIO stacks) — approximate with **PipeWire**/**EasyEffects**/**Carla** on Kinoite, not bit-identical.  
- **ShareX-grade** automation: OCR pipelines, custom uploaders, region workflows — **no single** Linux app; rebuild with **Plasma** shortcuts, **Flameshot**, **Spectacle**, **Ksnip**, **OBS**, **FFmpeg** scripts.  
- **OEM lighting / RGB** (e.g. some Razer/Logitech** proprietary** services) — **openrazer**+**Polychromatic**, **Piper**+**Solaar** cover **a subset**; exotic firmware features may need **Windows**.  
- **Apple** desktop: **iTunes** library management, **iCloud** shell integration, **iCloud for Outlook** — on Linux: **web**, **Akonadi**/**DAV**, not the same **Explorer**-integrated experience.  
- **Microsoft-first** or **MSIX-locked** apps (**Clipchamp, Phone Link, some Copilot/Edge assist**) — use **KDE**/**Chromium**/**web**; **1:1** to Windows UWP/Edge-only features: **no**.  
- **VS Build / MSVC**-centric pipelines — **use Linux toolchains in toolbox**; **not** a substitute for every **.NET WPF/Win** workflow.  
- **Bluesky Frame Rate Converter** and similar **vendor-specific Windows drivers** — on Linux, **MangoHud**/**KWin**/**Mesa** tuning; **N/A** same FRC.  
- **DTS Headphone:X**-style **vendor spatial** — Linux **HRTF**/**EasyEffects**; different branding and licensing.  
- **Bogus / PUP / joke ARP entries** — **remove in Windows**; do **not** try to “migrate” a junk installer to Linux. See plan note: **ephemeral/unknown** ARP line → **audit host**.

## Edge cases: Windows VM on Linux (optional)

- **3ds** only, **DCC** that is **licensed to Windows** — a **KVM/VirtualBox** or **QEMU** Windows guest on the **Kinoite** host (when on **bare metal** with GPU) can be **tighter** than dual-boot context-switching. See **`docs/virtualization-windows-vm.md`**, **`virtualbox-kinoite-fallback.md`**.  
- **KOTOR modding** with legacy **.exe** tools: **Wine/VM** or the **KotOR.js** stack for cross-platform work.  

## When you can *drop* Windows (longer arc)

- **All** you need is in **Flathub + Firefox + dev containers + Steam/Proton**-friendly titles, **no** AC-blocked games, **no** Max/Win-only CAD, **no** iTunes lock-in — then **Kinoite bare metal** (or a **clean** WSL/VM **lab**) is enough; keep this list as a **guilt-free** checklist, not a moral imperative.

Update this file after **big** **winget** changes (see `exports` + **`this-pc-inventory-template.md`**).
