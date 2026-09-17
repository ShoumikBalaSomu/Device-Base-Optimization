# Device Specification & Optimization Template 📋

Use this document as a blueprint when adding support for a new device model or operating system to the `Device-Base-Optimization` repository.

---

## 1. Directory Placement Standard

All device profiles follow the directory hierarchy:
```text
devices/
└── <os_name>/                      # e.g., windows, linux, macos, android
    └── <manufacturer-model>/       # e.g., lenovo-thinkpad-t490s, dell-xps-15-9520, asus-zephyrus-g14
        ├── README.md               # Hardware guide, specs, and execution instructions
        └── optimize.<ext>          # Custom optimization script (.ps1, .sh, etc.)
```

---

## 2. Hardware Probing Instructions

Before writing a custom script, extract exact hardware specifications using the native system tools below:

### Windows (PowerShell)
```powershell
# System & BIOS
Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory
Get-CimInstance Win32_Bios | Select-Object SMBIOSBIOSVersion, ReleaseDate

# CPU & GPU
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors
Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion

# Storage & Battery
Get-Disk | Select-Object Number, FriendlyName, BusType, Size
Get-CimInstance Win32_Battery | Select-Object Name, DeviceID, EstimatedChargeRemaining
```

### Linux (Bash)
```bash
inxi -Fz          # Comprehensive hardware overview
lshw -short       # Device tree
lsblk -f          # Block devices and filesystems
lspci -tv         # PCI bus topology
ip link           # Network adapters
upower -d         # Battery health and state
```

### macOS (zsh)
```zsh
system_profiler SPHardwareDataType
system_profiler SPPowerDataType
system_profiler SPStorageDataType
```

---

## 3. Template: `README.md` for New Device

```markdown
# <Manufacturer> <Model> Optimization Profile

Custom-engineered system tuning suite for the **<Manufacturer> <Model>**.

## 💻 Hardware Specifications
* **CPU**: <Processor Name>
* **GPU**: <Graphics Card>
* **RAM**: <Memory size & speed>
* **Storage**: <SSD Model & Bus>
* **Network**: <Wi-Fi & Ethernet chipset>
* **Battery**: <Battery model & capacity>
* **Supported OS**: <Windows / Linux distro / macOS>

## 🚀 How to Run
\`\`\`bash
# Insert execution command here
\`\`\`

## 🛠️ Custom Hardware Tweaks
1. **Firmware / BIOS Tuning**: <Details>
2. **Battery Threshold / Conservation**: <Details>
3. **Wi-Fi Chipset Tuning**: <Details>
4. **Storage & Filesystem**: <Details>
5. **Thermals & Power Profile**: <Details>
```
