# ⚡ Laptop Undervolting & Thermal Management Guide

Undervolting is the process of reducing the voltage supplied to the CPU/GPU without changing the clock speed. Because power consumption $P$ is roughly proportional to the square of the voltage $V$ and the frequency $f$:

$$P \propto V^2 \cdot f$$

Even a small reduction in voltage (millivolts) results in a significant drop in heat output and power draw, preventing thermal throttling.

---

## 🐧 Linux Section (Fedora & Arch)

Linux requires direct access to the CPU's Model Specific Registers (MSR). This is the most efficient method for your Fedora and Arch setups.

### **1. Prerequisites**
* **Disable Secure Boot:** Fedora/Arch kernels will lock down MSR access if Secure Boot is active.
* **Install Tools:**
    * **Fedora:** `sudo dnf install intel-undervolt msr-tools`
    * **Arch:** `sudo pacman -S intel-undervolt msr-tools`

### **2. Configuration**
Edit `/etc/intel-undervolt.conf`. For most Intel mobile chips (6th–10th Gen), start with these values:

```text
undervolt 0 'CPU' -80
undervolt 1 'GPU' 0
undervolt 2 'CPU Cache' -80
```
*Note: The CPU and CPU Cache **must** have the same offset on most Intel architectures to be effective.*

### **3. Testing & Automation**
1.  **Load MSR:** `sudo modprobe msr`
2.  **Apply Temporarily:** `sudo intel-undervolt apply`
3.  **Stress Test:** Use `stress-ng` or compile a large project. If the system freezes, a hard reboot resets the voltage to default.
4.  **Make Permanent:** Once stable, run `sudo systemctl enable --now intel-undervolt.service`.

---

## 🪟 Windows Section

Windows offers GUI-based tools that are more granular but require background processes to stay active.

### **1. CPU Undervolting (ThrottleStop)**
ThrottleStop is the gold standard for Intel laptops.
1.  **FIVR Menu:** Open the "FIVR" window.
2.  **Unlock Adjustable Voltage:** Check this box for "CPU Core" and "CPU Cache."
3.  **Offset Voltage:** Move the slider to a starting point of **-80mV**.
4.  **Save:** Select "OK - Do not save voltages immediately" while testing. Once stable, change to "Save voltages immediately."

### **2. GPU Undervolting (MSI Afterburner)**
Useful if games like *Path of Exile* are causing your GPU to hit 85°C+.
1.  **Curve Editor:** Press `Ctrl + F`.
2.  **Flatten the Curve:** Find a stable frequency (e.g., 1800MHz) and drag the points to the right of it down to a flat line. This forces the GPU to use a lower voltage for its maximum boost clock.
3.  **Apply:** Click the checkmark in the main Afterburner window.

---

## ⚠️ The "Silicon Lottery" Rulebook

Regardless of the OS, keep these principles in mind for your config repo:

* **Step-by-Step:** Move in increments of **-10mV**.
* **Stability ≠ Idle:** A laptop might be stable at -120mV while browsing but crash instantly during a 100% CPU load (like an ML training loop or a heavy boss fight).
* **Locked Hardware:** If your offsets show **0.00mV** after applying (check `intel-undervolt read` or ThrottleStop's table), your BIOS likely has "Undervolt Protection" enabled due to the Plundervolt vulnerability. You may need to look for a BIOS "Overclocking Lock" toggle.

---

### **Monitoring Tools for your Dotfiles**
| OS | Tool | Command/Package |
| :--- | :--- | :--- |
| **Linux** | `lm_sensors` | `watch -n 1 sensors` |
| **Linux** | `btop` | `btop` (Check the CPU info panel) |
| **Windows** | `HWiNFO64` | Check "CPU Core Voltage Offset" |
| **Windows** | `Core Temp` | Lightweight tray monitor |

## Resources

[Reddit](https://www.reddit.com/r/pathofexile/comments/hpi8fb/psa_use_at_your_own_risk_but_undervolting_my/)

## Implementation

```bash
sudo intel-undervolt apply
```
```text
CPU (0): Values do not equal
GPU (1): -0.00 mV
CPU Cache (2): Values do not equal
System Agent (3): -0.00 mV
Analog I/O (4): -0.00 mV

```

The reason you're seeing `Values do not equal` is that your **11th Gen Intel (Tiger Lake)** processor has hardware-level **Undervolt Protection**. 

Starting with the 11th Gen, Intel locked the voltage control registers (MSR 0x150) to mitigate the "Plundervolt" security vulnerability. Your CPU is receiving the command but immediately rejecting it, which is why the readback doesn't match your config.

Since you're on a laptop where the BIOS is likely "thin" (no advanced overclocking menus), you have two paths forward:

---

## **Path A: The Practical Alternative (Power Limiting)**
If you can't lower the *voltage*, you can still lower the *wattage*. This is 100% effective at stopping thermal throttling in games like Path of Exile.

`intel-undervolt` can also control **Power Limits (PL1 and PL2)**.
1.  **Edit your config:** `sudo nano /etc/intel-undervolt.conf`
2.  **Modify the power limit section:**
    ```text
    # Example for a U-series chip like your i5-1155G7
    # PL1 is long-term power (usually 15-28W)
    # PL2 is short-term burst (usually 35-45W)
    
    power package 0 25 15
    ```
    * The first number `25` is the wattage limit.
    * The second number `15` is the time window in seconds.
3.  **Apply:** `sudo intel-undervolt apply`
    * *This will almost always work even when voltage is locked.* By capping the power at, say, 20W or 25W, you prevent the CPU from spiking to 95°C.

---

## **Path B: The "Hard" Path (BIOS Bit-Flipping)**
To truly unlock the voltage, you have to manually flip a hidden bit in your UEFI variables using an EFI shell. **This is risky and can soft-brick your laptop if you use the wrong offset.**

For most 11th Gen laptops, the "Overclocking Lock" and "CFG Lock" are hidden variables. The community-standard process involves:
1.  **Identifying the Offset:** Using a tool like `H2OUVE` or dumping your BIOS to find the hex offset for `Overclocking Lock`. (For many 11th Gen chips, the offset is `0xDF`).
2.  **Flipping the Bit:** Booting into a specialized EFI Shell (like `mod-setup_var`) and running a command like:
    `setup_var CpuSetup 0xDF 0x00`
3.  **Result:** This "unlocks" the door, allowing `intel-undervolt` to actually work.

> [!CAUTION]  
> I do not recommend Path B unless you have a way to recover your BIOS (like a CMOS reset or BIOS Flashback) and are comfortable with hex offsets.

---
