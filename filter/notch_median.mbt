///|
pub fn sin_approx(x : Double) -> Double {
  let x2 = x * x
  x * (1.0 - x2 / 6.0 * (1.0 - x2 / 20.0 * (1.0 - x2 / 42.0)))
}

///|
pub fn cos_approx(x : Double) -> Double {
  let x2 = x * x
  1.0 - x2 / 2.0 * (1.0 - x2 / 12.0 * (1.0 - x2 / 30.0))
}

///|
/// Computes 2nd-order IIR Notch filter coefficients (removes specific notch_freq_hz e.g. 50 Hz / 60 Hz powerline noise).
pub fn compute_notch_filter(
  notch_freq_hz : Double,
  q_factor : Double,
  sample_rate : Double,
) -> BiquadCoeffs {
  let pi = 3.14159265358979323846
  let omega = 2.0 * pi * notch_freq_hz / sample_rate
  let alpha = tan_approx(omega / (2.0 * q_factor))
  let cos_w = cos_approx(omega)

  let b0 = 1.0 / (1.0 + alpha)
  let b1 = -2.0 * cos_w * b0
  let b2 = b0
  let a1 = -2.0 * cos_w * b0
  let a2 = (1.0 - alpha) * b0

  { b0, b1, b2, a1, a2 }
}

///|
/// Applies a Median Filter of `window_size` to remove impulsive artifact spikes from force signals.
pub fn apply_median_filter(
  signal : Array[Double],
  window_size : Int,
) -> Array[Double] {
  let n = signal.length()
  if n == 0 {
    return []
  }
  let half = window_size / 2
  let out : Array[Double] = Array::new(capacity=n)

  for i = 0; i < n; i = i + 1 {
    let start = if i - half < 0 { 0 } else { i - half }
    let end = if i + half >= n { n - 1 } else { i + half }
    let win : Array[Double] = Array::new(capacity=end - start + 1)
    for j = start; j <= end; j = j + 1 {
      win.push(signal[j])
    }
    win.sort()
    let mid = win.length() / 2
    let median = if win.length() % 2 == 0 {
      (win[mid - 1] + win[mid]) / 2.0
    } else {
      win[mid]
    }
    out.push(median)
  }
  out
}

///|
/// Exponential Moving Average (EMA) filter: S_t = alpha * Y_t + (1 - alpha) * S_{t-1}.
pub fn apply_exponential_moving_average(
  signal : Array[Double],
  alpha : Double,
) -> Array[Double] {
  let n = signal.length()
  if n == 0 {
    return []
  }
  let a = if alpha < 0.0 { 0.0 } else if alpha > 1.0 { 1.0 } else { alpha }
  let out : Array[Double] = Array::new(capacity=n)
  out.push(signal[0])

  for i = 1; i < n; i = i + 1 {
    let prev = out[i - 1]
    out.push(a * signal[i] + (1.0 - a) * prev)
  }
  out
}

///|
/// Designing Hamming windowed lowpass FIR filter coefficients.
pub fn compute_fir_lowpass_hamming(
  cutoff_hz : Double,
  sample_rate : Double,
  num_taps : Int,
) -> Array[Double] {
  let n = if num_taps % 2 == 0 { num_taps + 1 } else { num_taps }
  let pi = 3.14159265358979323846
  let fc = cutoff_hz / sample_rate
  let middle = (n - 1) / 2
  let coeffs : Array[Double] = Array::new(capacity=n)

  let mut sum = 0.0
  for i = 0; i < n; i = i + 1 {
    let m = i - middle
    let h = if m == 0 {
      2.0 * fc
    } else {
      sin_approx(2.0 * pi * fc * m.to_double()) / (pi * m.to_double())
    }
    let w = 0.54 -
      0.46 * cos_approx(2.0 * pi * i.to_double() / (n - 1).to_double())
    let val = h * w
    coeffs.push(val)
    sum = sum + val
  }

  let norm_coeffs : Array[Double] = Array::new(capacity=n)
  let norm = if sum.abs() < 0.000000001 { 1.0 } else { sum }
  for i = 0; i < n; i = i + 1 {
    norm_coeffs.push(coeffs[i] / norm)
  }
  norm_coeffs
}
