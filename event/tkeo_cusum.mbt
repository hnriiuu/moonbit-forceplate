///|
/// Applies Teager-Kaiser Energy Operator (TKEO) to force signal: Psi[x(n)] = x^2(n) - x(n-1)*x(n+1).
pub fn apply_tkeo(signal : Array[Double]) -> Array[Double] {
  let n = signal.length()
  let out : Array[Double] = Array::new(capacity=n)
  if n == 0 {
    return []
  }
  out.push(0.0)
  for i = 1; i < n - 1; i = i + 1 {
    let psi = signal[i] * signal[i] - signal[i - 1] * signal[i + 1]
    out.push(if psi < 0.0 { 0.0 } else { psi })
  }
  if n > 1 {
    out.push(0.0)
  }
  out
}

///|
/// Detects movement onset using TKEO energy thresholding.
pub fn detect_onset_tkeo(fz : Array[Double], quiet_baseline_cnt : Int) -> Int {
  let n = fz.length()
  let tkeo = apply_tkeo(fz)
  let cnt = if quiet_baseline_cnt > n { n } else { quiet_baseline_cnt }

  let base_tkeo : Array[Double] = Array::new(capacity=cnt)
  for i = 0; i < cnt; i = i + 1 {
    base_tkeo.push(tkeo[i])
  }

  let mean_t = @core.compute_mean(base_tkeo)
  let sd_t = @core.compute_std_dev(base_tkeo)
  let scale = if sd_t < 1.0 { 1.0 } else { sd_t }
  let thresh = mean_t + 3.0 * scale

  for i = cnt; i < n; i = i + 1 {
    if tkeo[i] > thresh {
      return i
    }
  }
  0
}

///|
/// CUSUM (Cumulative Sum) change-point detector for detecting baseline shift in quiet standing.
pub fn detect_cusum_changepoint(
  signal : Array[Double],
  quiet_cnt : Int,
  drift_k : Double,
  threshold_h : Double,
) -> Int {
  let n = signal.length()
  if n == 0 {
    return 0
  }
  let cnt = if quiet_cnt > n { n } else { quiet_cnt }
  let base : Array[Double] = Array::new(capacity=cnt)
  for i = 0; i < cnt; i = i + 1 {
    base.push(signal[i])
  }
  let mean = @core.compute_mean(base)
  let sd = @core.compute_std_dev(base)
  let scale = if sd < 1.0 { 1.0 } else { sd }

  let k = drift_k * scale
  let h = threshold_h * scale

  let mut s_pos = 0.0
  let mut s_neg = 0.0

  for i = cnt; i < n; i = i + 1 {
    let dev = signal[i] - mean
    s_pos = if s_pos + dev - k > 0.0 { s_pos + dev - k } else { 0.0 }
    s_neg = if s_neg - dev - k > 0.0 { s_neg - dev - k } else { 0.0 }

    if s_pos > h || s_neg > h {
      return i
    }
  }
  0
}
