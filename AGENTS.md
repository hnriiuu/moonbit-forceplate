# Project AGENTS.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project for **force plate biomechanics analysis** (`hnriiuu/moonbit_forceplate`).

## Project Structure

- MoonBit packages are organized per directory; each directory contains a `moon.pkg` file listing its dependencies.
- Packages contain implementation files (`.mbt`), blackbox tests (`_test.mbt`), and whitebox tests (`_wbtest.mbt`).
- Top-level directory contains `moon.mod` module manifest.

## Packages Overview

- `core`: 3D Force vector primitives, multi-axis frame samples, sensor calibration, trial buffers.
- `filter`: DSP Butterworth lowpass/highpass/bandpass, zero-phase filtering, Savitzky-Golay smoothing, moving average.
- `resample`: Cubic spline interpolation, standardized frequency resampling, time normalization.
- `kinetic`: Numerical integration (trapezoidal, Simpson's), net force, body mass estimation, velocity, displacement, impulse, RFD.
- `event`: Movement onset ($5\sigma$), unloading, takeoff, landing event detection, phase segmentation.
- `jump`: CMJ (Countermovement Jump), SJ (Squat Jump), Drop Jump (DJ) analysis, RSI, stiffness, peak power.
- `sway`: Posturography analysis, COP path length, COP mean velocity, 95% confidence ellipse area, AP/ML ranges.
- `asymmetry`: Bilateral dual-plate load distribution percentage, symmetry index (SI), phase peak force asymmetry.
- `export`: CSV parser, JSON export, ASCII biomechanics report generator.
- `cmd`: Interactive CLI tool, synthetic signal generator, benchmarks.

## Tooling & Quality Standards

- `moon check`: Typecheck and validate module packages.
- `moon test`: Execute unit and integration tests.
- `moon fmt --deny-warn`: Auto-format code without warnings.
- `moon info --deny-warn`: Update package interface signatures without warnings.
