///|
/// High precision tangent approximation for digital filter design.
pub fn tan_approx(x : Double) -> Double {
  let x2 = x * x
  let sin_x = x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0 * (1.0 - x2 / 42.0)))
  let cos_x = 1.0 - x2 / 2.0 * (1.0 - x2 / 12.0 * (1.0 - x2 / 30.0))
  if cos_x.abs() < 0.000000001 {
    0.0
  } else {
    sin_x / cos_x
  }
}

///|
/// Second-order IIR Biquad filter coefficients (b0, b1, b2, a1, a2).
pub struct BiquadCoeffs {
  b0 : Double
  b1 : Double
  b2 : Double
  a1 : Double
  a2 : Double
} derive(Debug, Eq)

///|
/// Computes 2nd-order Butterworth low-pass filter coefficients.
/// `cutoff_hz`: Cutoff frequency in Hz.
/// `sample_rate`: Sampling frequency in Hz.
pub fn compute_butterworth_lowpass(
  cutoff_hz : Double,
  sample_rate : Double,
) -> BiquadCoeffs {
  let pi = 3.14159265358979323846
  let fs = sample_rate
  let fc = cutoff_hz
  let omega = 2.0 * pi * fc / fs
  let tan_half = tan_approx(omega / 2.0)
  let tan2 = tan_half * tan_half
  let sqrt2 = 1.4142135623730951
  let norm = 1.0 + sqrt2 * tan_half + tan2

  let b0 = tan2 / norm
  let b1 = 2.0 * b0
  let b2 = b0
  let a1 = 2.0 * (tan2 - 1.0) / norm
  let a2 = (1.0 - sqrt2 * tan_half + tan2) / norm

  { b0, b1, b2, a1, a2 }
}

///|
/// Computes 2nd-order Butterworth high-pass filter coefficients.
pub fn compute_butterworth_highpass(
  cutoff_hz : Double,
  sample_rate : Double,
) -> BiquadCoeffs {
  let pi = 3.14159265358979323846
  let fs = sample_rate
  let fc = cutoff_hz
  let omega = 2.0 * pi * fc / fs
  let tan_half = tan_approx(omega / 2.0)
  let tan2 = tan_half * tan_half
  let sqrt2 = 1.4142135623730951
  let norm = 1.0 + sqrt2 * tan_half + tan2

  let b0 = 1.0 / norm
  let b1 = -2.0 * b0
  let b2 = b0
  let a1 = 2.0 * (tan2 - 1.0) / norm
  let a2 = (1.0 - sqrt2 * tan_half + tan2) / norm

  { b0, b1, b2, a1, a2 }
}

///|
/// Applies a Biquad filter forward to an array of samples.
pub fn apply_biquad_forward(
  signal : Array[Double],
  coeffs : BiquadCoeffs,
) -> Array[Double] {
  let n = signal.length()
  let out : Array[Double] = Array::new(capacity=n)
  let mut x1 = 0.0
  let mut x2 = 0.0
  let mut y1 = 0.0
  let mut y2 = 0.0

  if n > 0 {
    x1 = signal[0]
    x2 = signal[0]
    y1 = signal[0]
    y2 = signal[0]
  }

  for i = 0; i < n; i = i + 1 {
    let x0 = signal[i]
    let y0 = coeffs.b0 * x0 +
      coeffs.b1 * x1 +
      coeffs.b2 * x2 -
      coeffs.a1 * y1 -
      coeffs.a2 * y2
    out.push(y0)
    x2 = x1
    x1 = x0
    y2 = y1
    y1 = y0
  }
  out
}

///|
/// Zero-phase digital filtering (filtfilt): applies forward and backward biquad passes
/// to eliminate phase distortion (commonly required in biomechanics force plate DSP).
pub fn apply_biquad_zero_phase(
  signal : Array[Double],
  coeffs : BiquadCoeffs,
) -> Array[Double] {
  let fwd = apply_biquad_forward(signal, coeffs)
  let n = fwd.length()
  let rev_input : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    rev_input.push(fwd[n - 1 - i])
  }
  let rev_filtered = apply_biquad_forward(rev_input, coeffs)
  let result : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    result.push(rev_filtered[n - 1 - i])
  }
  result
}

///|
/// Low-pass filter a single ForceTrial's force channels (Fx, Fy, Fz).
pub fn filter_trial_forces(
  trial : @core.ForceTrial,
  cutoff_hz : Double,
  zero_phase : Bool,
) -> @core.ForceTrial {
  let fs = trial.metadata.sampling_rate
  let coeffs = compute_butterworth_lowpass(cutoff_hz, fs)

  let fx = trial.get_fx()
  let fy = trial.get_fy()
  let fz = trial.get_fz()

  let fx_filt = if zero_phase {
    apply_biquad_zero_phase(fx, coeffs)
  } else {
    apply_biquad_forward(fx, coeffs)
  }
  let fy_filt = if zero_phase {
    apply_biquad_zero_phase(fy, coeffs)
  } else {
    apply_biquad_forward(fy, coeffs)
  }
  let fz_filt = if zero_phase {
    apply_biquad_zero_phase(fz, coeffs)
  } else {
    apply_biquad_forward(fz, coeffs)
  }

  let n = trial.length()
  let new_samples : Array[@core.ForceSample] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    let s = trial.samples[i]
    new_samples.push(
      @core.ForceSample::new(
        s.timestamp,
        @core.Vec3::new(fx_filt[i], fy_filt[i], fz_filt[i]),
        s.moment,
        s.cop,
      ),
    )
  }
  @core.ForceTrial::new(trial.metadata, new_samples)
}
