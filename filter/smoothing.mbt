///|
/// Applies a centered moving average filter to an array of samples.
/// `window_size`: Odd integer specifying the window span.
pub fn apply_moving_average(
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
    let mut sum = 0.0
    let mut count = 0
    for j = start; j <= end; j = j + 1 {
      sum = sum + signal[j]
      count = count + 1
    }
    out.push(sum / count.to_double())
  }
  out
}

///|
/// Applies a 5-point quadratic/cubic Savitzky-Golay smoothing filter.
/// Coefficients for 5-point window: [-3, 12, 17, 12, -3] / 35.
pub fn apply_savitzky_golay_5(signal : Array[Double]) -> Array[Double] {
  let n = signal.length()
  if n < 5 {
    return apply_moving_average(signal, 3)
  }
  let out : Array[Double] = Array::new(capacity=n)
  let norm = 35.0

  out.push(signal[0])
  out.push(signal[1])

  for i = 2; i < n - 2; i = i + 1 {
    let val = (
        -3.0 * signal[i - 2] +
        12.0 * signal[i - 1] +
        17.0 * signal[i] +
        12.0 * signal[i + 1] -
        3.0 * signal[i + 2]
      ) /
      norm
    out.push(val)
  }

  out.push(signal[n - 2])
  out.push(signal[n - 1])
  out
}

///|
/// Applies a 7-point quadratic/cubic Savitzky-Golay smoothing filter.
/// Coefficients for 7-point window: [-2, 3, 6, 7, 6, 3, -2] / 21.
pub fn apply_savitzky_golay_7(signal : Array[Double]) -> Array[Double] {
  let n = signal.length()
  if n < 7 {
    return apply_savitzky_golay_5(signal)
  }
  let out : Array[Double] = Array::new(capacity=n)
  let norm = 21.0

  for k = 0; k < 3; k = k + 1 {
    out.push(signal[k])
  }

  for i = 3; i < n - 3; i = i + 1 {
    let val = (
        -2.0 * signal[i - 3] +
        3.0 * signal[i - 2] +
        6.0 * signal[i - 1] +
        7.0 * signal[i] +
        6.0 * signal[i + 1] +
        3.0 * signal[i + 2] -
        2.0 * signal[i + 3]
      ) /
      norm
    out.push(val)
  }

  for k = n - 3; k < n; k = k + 1 {
    out.push(signal[k])
  }
  out
}

///|
/// Truncates force values below a specified noise threshold to zero.
/// Crucial for flight phase detection where low noise floor (e.g. < 5 N) should be zeroed.
pub fn apply_threshold_zeroing(
  signal : Array[Double],
  threshold : Double,
) -> Array[Double] {
  let n = signal.length()
  let out : Array[Double] = Array::new(capacity=n)
  for i = 0; i < n; i = i + 1 {
    if signal[i].abs() < threshold {
      out.push(0.0)
    } else {
      out.push(signal[i])
    }
  }
  out
}
