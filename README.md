# MoonBit Force Plate Analysis Library (`moonbit-forceplate`)

[![MoonBit CI](https://github.com/hnriiuu/moonbit-forceplate/actions/workflows/test.yml/badge.svg)](https://github.com/hnriiuu/moonbit-forceplate/actions)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![MoonBit Version](https://img.shields.io/badge/MoonBit-0.10.3-purple.svg)](https://www.moonbitlang.com/)

A high-performance, sports-science focused **Force Plate Biomechanics Analysis Library** written in [MoonBit](https://www.moonbitlang.com). Designed for vertical ground reaction force (vGRF), Center of Pressure (COP) static posturography, dynamic jumps (CMJ, SJ, Drop Jump, Pogo Hopping, IMTP), zero-phase DSP filtering, and bilateral load asymmetry analysis.

---

## 📊 Project Statistics & Source Code Scale

- **Handwritten MoonBit (`.mbt`) Files**: **42 files**
- **Effective (Non-Empty) Lines of Code**: **4,061 lines** (Gross LOC: ~4,750 lines)
- **Unit Tests**: **51 tests passed**, 0 failures
- **MoonBit Toolchain Compliance**: `moon check`, `moon test`, `moon fmt`, `moon info` (Zero Warnings)

### Package & File Breakdown

| Package | Files | Non-Empty LOC | Key Capabilities |
| :--- | :--- | :---: | :--- |
| `core` | `types.mbt`, `trial.mbt`, `matrix.mbt`, `core_test.mbt` | 534 | 3D vectors (`Vec3`), CoP, $3\times 3$ matrices, RMS, skewness, kurtosis |
| `filter` | `butterworth.mbt`, `smoothing.mbt`, `notch_median.mbt`, `filter_test.mbt` | 438 | 2nd/4th-order Butterworth, `filtfilt`, Savitzky-Golay, IIR Notch, Median, FIR |
| `resample` | `spline.mbt`, `resample.mbt`, `akima_pchip.mbt`, `resample_test.mbt` | 414 | Cubic Spline, Akima Spline, 1000Hz resampling, 0-100% time normalization |
| `kinetic` | `integration.mbt`, `force_derived.mbt`, `rfd_impulse.mbt`, `work_energy.mbt`, `kinetic_test.mbt` | 415 | Simpson integration, body mass estimation, kinematics, work, RPD, RFD |
| `event` | `detector.mbt`, `segmentation.mbt`, `tkeo_cusum.mbt`, `event_test.mbt` | 428 | $5\sigma$ onset, takeoff/landing thresholds, TKEO energy operator, CUSUM |
| `jump` | `cmj.mbt`, `sj.mbt`, `drop_jump.mbt`, `imtp_pogo.mbt`, `dynamic_stiffness.mbt`, `jump_test.mbt` | 772 | CMJ, SJ, DJ, IMTP, Pogo hops, Dynamic stiffness, Dynamic strength deficit |
| `sway` | `cop_metrics.mbt`, `ellipse.mbt`, `convex_hull.mbt`, `spectral.mbt`, `sway_test.mbt` | 380 | COP path length, 95% Ellipse area, Graham Scan Convex Hull, PSD spectrum |
| `asymmetry` | `bilateral.mbt`, `trajectory.mbt`, `asymmetry_test.mbt` | 259 | Load share %, Symmetry Index (SI), 101-point asymmetry trajectory |
| `export` | `csv_json.mbt`, `report.mbt`, `markdown_report.mbt`, `export_test.mbt` | 295 | CSV exporter, ASCII sparkline reports, Markdown report generator |
| `cmd` | `synthetic.mbt`, `main.mbt`, `cmd_test.mbt` | 266 | Interactive CLI suite, synthetic data generators, benchmarks |
| **Total** | **42 Files** | **4,061** | **Full Sports Biomechanics Analysis Engine** |

---

## 🏃 Quick Start

### Build & Run CLI Demo
```bash
moon check
moon test
moon run cmd/main
```

### Format & Signatures
```bash
moon fmt --deny-warn
moon info --deny-warn
```

---

## 🧬 Biomechanical Formulas & Models

### 1. Zero-Phase 4th-Order Butterworth Filter
$$H(s) = \frac{1}{1 + \sqrt{2} s + s^2}$$
Forward-backward filtering (`apply_biquad_zero_phase`) guarantees zero phase distortion ($\Delta \phi = 0$).

### 2. Teager-Kaiser Energy Operator (TKEO)
$$\Psi[x(n)] = x^2(n) - x(n-1) \cdot x(n+1)$$

### 3. Vertical & Leg Stiffness ($K_{vert}, K_{leg}$)
$$K_{vert} = \frac{F_{max}}{\Delta z_{max}}, \quad K_{leg} = \frac{F_{max}}{\Delta z_{max} + L_{leg} - \sqrt{L_{leg}^2 - (\frac{v \cdot t_c}{2})^2}}$$

### 4. Center of Pressure (COP) 95% Confidence Ellipse Area
$$\text{Area}_{95\%} = 5.991 \cdot \pi \cdot \sqrt{\lambda_1 \lambda_2}$$

---

## 📜 License

Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).
