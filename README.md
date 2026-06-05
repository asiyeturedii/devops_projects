# macOS System Performance & Resource Monitoring Engine

A lightweight, native POSIX-compliant Shell automation utility designed for high-fidelity system telemetry extraction on Darwin (macOS) architectures. This engine operates with **zero external dependencies**, leveraging core system subroutines, kernel state parameters, and advanced stream processing (`awk`) to compile structured, human-readable performance profiles.

**Project Remote Repository:** [https://github.com/asiyeturedii/devops-server-performance-stats](https://github.com/asiyeturedii/devops-server-performance-stats)

---

## 🛠 Architectural Engineering & Technical Roadblocks

Implementing a resource monitor on Darwin distributions introduces significant deviations from standard GNU/Linux architectures (e.g., the absence of `/proc` virtual filesystems and standard `free -m` utilities). Below is an analytical breakdown of the technical challenges encountered and resolved during this engineering sprint:

### 1. High-Fidelity CPU Telemetry Extraction

- **Problem:** The GNU/Linux implementation utilizes `top -b` for non-interactive batch mode processing, an argument invalid under the Darwin subsystem.
- **Engineering Solution:** Orchestrated an instantaneous system snapshot using `top -l 1`, isolating CPU metrics via `grep "CPU usage"`. To circumvent non-standard string formats, an `awk` processing layer dynamically parses and arithmetically aggregates User-space (`$3`) and Kernel/System-space (`$5`) utilization vectors to output an accurate absolute workload percentage.

### 2. The Memory Management Paradigm (`vm_stat` Page Translation)

- **Problem:** Darwin abstracts memory distribution into physical page layouts rather than raw byte buffers. Initial calculations threw severe syntax anomalies due to nested parenthesis evaluations inside the `awk` context (`(free_bytes / total) * 100`) and localized character encodings in embedded code comments.
- **Engineering Solution:** Implemented a pure mathematical transformation algorithm optimized for the `awk` execution engine:
  1. Extracted physical page metrics via `vm_stat`, normalizing the string by stripping trailing delimiters (`tr -d '.'`).
  2. Map-reduced the page count to absolute bytes by multiplying against the architecture's native **4096-byte page size**.
  3. Eliminated `awk` abstract-syntax-tree (AST) parsing errors by flattening the mathematical order of operations into a parenthesis-free linear equation: `free_percent = free_bytes * 100 / total`.
  4. Streamed hardware limits from `sysctl hw.memsize` and scaled bytes to Gibibytes using the binary factor $1073741824$ ($1024^3$).

### 3. Storage Allocation and Row Alignment

- **Problem:** Standard `df -h` execution injects standard error/output headers that contaminate raw telemetry capture.
- **Engineering Solution:** Bound the root mount (`/`) query to an `awk 'NR==2'` filtering condition, leveraging the `NR` (Number of Records) internal tracker to programmatically discard table headers and index raw metrics exclusively from the secondary record array.

### 4. Precision Sorting & The Floating-Point String Trap

- **Problem:** Invoking a standard alphanumeric sort (`sort -rk 2`) on Unix process tables (`ps`) caused severe index drift due to Darwin formatting CPU/Memory metrics as floating-point strings (`0.0`, `14.2`). This mistakenly prioritized lexicographical values over absolute magnitude and leaked header strings into the top results.
- **Engineering Solution:** Forced numerical evaluation flags (`-n`) within the sort pipeline (`sort -rnk 2`), compelling the runtime environment to parse entries via true float comparison matrices. The collection envelope was expanded to `head -n 6` to offset the process abstraction header and capture exactly 5 active PIDs.

---

## 📊 Production Telemetry Output

When invoked, the engine flushes the terminal buffer and outputs structured telemetry metrics utilizing custom text matrix boundaries:

```text
STATION PERFORMANCE REPORT - Fri Jun  5 13:41:19 +03 2026

========================================================
  TOTAL CPU USAGE
========================================================
Total CPU usage: 10.49%

========================================================
  TOTAL MEMORY USAGE (Free vs Used)
========================================================
Total Memory: 36 GB
Free Percent: 0.396972%
Used Percent: 99.603%

========================================================
  TOTAL DISK USAGE (Free vs Used)
========================================================
Total Space: 926Gi
Used Space:  11Gi
Free Space:  446Gi
Usage:       3%

========================================================
  TOP 5 PROCESSES BY CPU USAGE
========================================================
 1339  26.0 /System/Library/Frameworks/Virtualization.framework/...
53774  11.4 /Applications/Docker.app/Contents/MacOS/Docker Desktop.app/...
  402   5.3 /System/Library/PrivateFrameworks/SkyLight.framework/...
...

========================================================
  SYSTEM EXTRA STATS (Stretch Goals)
========================================================
OS Version:      26.2
System Uptime:   13:41  up 37 days,  3:17, 3 users, load averages: 2.57 2.54 2.69
Logged In Users: asiyeranaturedi

========================================================
REPORT GENERATION COMPLETED
========================================================
```
