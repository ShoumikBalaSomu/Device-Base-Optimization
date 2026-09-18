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
- **Fast Boot**: `Enabled`
  - *Why*: Skips redundant hardware self-test loops during POST for faster cold boot times.
- **Network Stack / PXE Boot Option ROM**: `Disabled`
  - *Why*: Eliminates Realtek Ethernet ROM initialization delays during boot.
- **Boot Option #1**: `Fedora` (or GRUB)
- **Boot Option #2**: `Windows Boot Manager`

### **Tab: Save & Exit**
- Select **Save Changes and Exit** (or press **F4**).

---

## ⚠️ 3. Why You Should NOT Flash Unofficial BIOS Mods

- Emdoor IDL528 is an ODM chassis built for Daffodil. There are **no public open-source coreboot/libreboot ports** for this specific 13th Gen Raptor Lake board.
- Flashing unverified AMI Aptio ROMs from other laptop brands using AFU or flashrom carries an extreme risk of bricking the SPI chip without an external CH341A programmer.
- All hardware-level performance, thermal unlock, battery cell preservation, and bus latencies have already been maximally extracted via our kernel & EC subsystem suite.
