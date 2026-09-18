# 🖥️ Daffodil DC253D (Emdoor IDL528) BIOS & Firmware Optimization Guide

> **Firmware Platform**: American Megatrends International (AMI) Aptio V  
> **BIOS Version**: `BM_BI_IDL528_175B_F` (Release: 09/14/2024)  
> **Embedded Controller (EC)**: Version 1.6  
> **Target Hardware**: Daffodil Computers Ltd. DC253D / 13th Gen Intel Core i3-1315U  

---

## ⚡ 1. What Antigravity Optimized Automatically (OS & Firmware Layer)

You **do not** need to re-flash or dangerously tamper with the SPI flash ROM chip. The optimization suite has already directly calibrated and overridden the BIOS/Firmware parameters at runtime:

1. **ACPI Platform Profile Overridden to `performance`**:
   - The OEM BIOS defaults to a balanced, thermally restricted profile. The script locks `/sys/firmware/acpi/platform_profile` to `performance`.
2. **Intel SpeedShift Hardware P-States (HWP MSRs)**:
   - Reprogrammed CPU MSRs `0x770` (HWP Request) and `0x774` directly to EPP `0` (`performance`) and EPB `0` on AC mains, bypassing OEM BIOS downclocking tables.
3. **Embedded Controller (EC) Direct Register Control**:
   - Directly mapped low-level I/O ports `0x62` and `0x66` on the Emdoor EC to manage charging and prevent continuous battery float stress above 80%.
4. **PCIe ASPM Link Power Overridden**:
   - Replaced conservative BIOS link power states with `pcie_aspm=performance` to stop bus latency on the NVMe and Wi-Fi chipsets.
5. **NVMe APST Autonomous Transition Latency Zeroed**:
   - The BIOS enables aggressive power saving on PCIe drives. The MAP1202 controller freezes under these states; our script sets `default_ps_max_latency_us=0` to keep the NVMe instantly responsive.
6. **UEFI NVRAM Boot Order Cleaned**:
   - Removed Realtek PXE network boot entries (`000A`-`000D`) from `BootOrder` (`efibootmgr -o 0001,0000`). Your machine now boots straight into Fedora/Windows without waiting for DHCP/PXE timeouts.

---

## 🛠️ 2. Recommended Manual BIOS Setup Options (F2 / Del at Boot)

When powering on your laptop, repeatedly tap **`F2`** or **`Delete`** to enter the **American Megatrends (AMI)** BIOS setup menu. Here are the optimal configurations for this motherboard:

### **Tab: Advanced**
- **Intel (VMX) Virtualization Technology**: `Enabled`
  - *Why*: Required for KVM, Docker, WSL2, and hardware-assisted hypervisors.
- **Intel VT-d (Directed I/O)**: `Enabled`
  - *Why*: Enables direct I/O memory management and DMA protection for security.
- **Power & Performance -> CPU - Power Management Control**:
  - **Intel SpeedStep / SpeedShift**: `Enabled`
  - **Turbo Mode**: `Enabled`
  - **C-States**: `Enabled` (Allows deep CPU sleep on battery, dynamically managed by Linux kernel).

### **Tab: Chipset / Storage Configuration**
- **SATA / NVMe Controller Mode**: `AHCI / Non-VMD`
  - *Why*: Daffodil DC253D uses a standard MAXIO MAP1202 NVMe. Do NOT enable Intel RST VMD unless you have a RAID array. Direct NVMe mode provides lower latency and full TRIM support in Linux.

### **Tab: Security**
- **Secure Boot**: `Enabled` (Standard)
  - *Why*: Fedora and Windows 11 both support UEFI Secure Boot via Microsoft signed shims. Prevents bootkit infections.
- **Intel PTT / TPM 2.0**: `Enabled`
  - *Why*: Hardware cryptography provider used for LUKS disk encryption and Windows Hello.

### **Tab: Boot**
- **Fast Boot**: `Disabled` ⚠️
  - *Why*: **CRITICAL for Touchpad & I2C Peripherals.** When Fast Boot is `Enabled`, the AMI BIOS skips initializing the secondary Intel Serial IO I2C host controller (`00:15.0`) during UEFI POST. This leaves the Synaptics/PixArt SYNA3602 touchpad without a clock, causing Linux to fail to detect the touchpad on cold boot. Setting Fast Boot to `Disabled` forces full hardware initialization on every startup.
- **Network Stack / PXE Boot Option ROM**: `Disabled`
  - *Why*: Eliminates Realtek Ethernet ROM initialization delays during boot.
- **Boot Option #1**: `Fedora` (or GRUB)
- **Boot Option #2**: `Windows Boot Manager`

### **Tab: Save & Exit**
- Select **Save Changes and Exit** (or press **F4**).

---

## 🖱️ 3. Touchpad Not Working on Fresh Fedora Installation (First Boot Fix)

If the touchpad does not respond immediately after installing Fedora (before running the optimization script), this is caused by **Windows Fast Startup**, **BIOS Fast Boot**, or **disabled Tap-to-Click** in stock Fedora:

### A. The Windows "Fast Startup" Trap (Dual-Boot Users)
If Windows 11 was booted before Fedora, Windows does not truly shut down—it uses "Fast Startup" (hiberboot), locking the Intel Serial IO I2C bus into a low-power sleep state (`D3hot`). When Linux boots, the I2C bus cannot be probed.
1. Boot into Windows 11.
2. Open **Command Prompt as Administrator** and run:
   ```cmd
   powercfg /h off
   ```
   *(Or go to Control Panel -> Power Options -> "Choose what the power button does" -> Uncheck "Turn on fast startup").*
3. Shut down completely, wait 5 seconds, and power on directly into Fedora.

### B. Immediate 5-Second Workaround (Suspend / Resume Trick)
If booted into Fedora and the cursor is frozen:
- **Close the laptop lid** for 3–5 seconds until the power LED pulses (sleep state), then **open the lid**.
- The ACPI wake event re-powers the I2C bus and forces the kernel to successfully bind `i2c_hid_acpi`.

### C. Terminal Quick Fix
Open a terminal and run:
```bash
sudo modprobe -r i2c_hid_acpi && sudo modprobe i2c_hid_acpi
```

### D. Tap-to-Click is Disabled by Default in Stock Fedora
Stock Fedora GNOME disables "Tap-to-Click" by default out-of-the-box. The DC253D touchpad is a unified clickpad (no separate physical buttons). Light tapping does not register until you firmly press down until the pad clicks mechanically, or until you enable:
- **Settings -> Mouse & Touchpad -> Tap to Click: ON**.
*(Our optimization script automatically enables this system-wide for all users and the GDM login screen).*

---

## ⚠️ 4. Why You Should NOT Flash Unofficial BIOS Mods

- Emdoor IDL528 is an ODM chassis built for Daffodil. There are **no public open-source coreboot/libreboot ports** for this specific 13th Gen Raptor Lake board.
- Flashing unverified AMI Aptio ROMs from other laptop brands using AFU or flashrom carries an extreme risk of bricking the SPI chip without an external CH341A programmer.
- All hardware-level performance, thermal unlock, battery cell preservation, and bus latencies have already been maximally extracted via our kernel & EC subsystem suite.
