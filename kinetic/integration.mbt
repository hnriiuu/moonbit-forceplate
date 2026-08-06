///|
/// Integrates a 1D curve `(timestamps, values)` using Trapezoidal Rule over interval [start_idx, end_idx].
pub fn integrate_trapezoidal(
  timestamps : Array[Double],
  values : Array[Double],
  start_idx : Int,
  end_idx : Int,
) -> Double {
  let start = if start_idx < 0 { 0 } else { start_idx }
  let end = if end_idx > values.length() { values.length() } else { end_idx }
  if end - start < 2 {
    return 0.0
  }
  let mut total = 0.0
  for i = start; i < end - 1; i = i + 1 {
    let dt = timestamps[i + 1] - timestamps[i]
    let avg_y = (values[i] + values[i + 1]) / 2.0
    total = total + avg_y * dt
  }
  total
}

///|
/// Integrates a 1D curve using Composite Simpson's 1/3 Rule (falls back to Trapezoidal for even sample counts).
pub fn integrate_simpson(
  timestamps : Array[Double],
  values : Array[Double],
  start_idx : Int,
  end_idx : Int,
) -> Double {
  let start = if start_idx < 0 { 0 } else { start_idx }
  let end = if end_idx > values.length() { values.length() } else { end_idx }
  let n = end - start
  if n < 2 {
    return 0.0
  }
  if n % 2 == 0 {
    return integrate_trapezoidal(timestamps, values, start, end)
  }
  let dt = (timestamps[end - 1] - timestamps[start]) / (n - 1).to_double()
  let mut sum_even = 0.0
  let mut sum_odd = 0.0

  for i = 1; i < n - 1; i = i + 1 {
    let val = values[start + i]
    if i % 2 == 0 {
      sum_even = sum_even + val
    } else {
      sum_odd = sum_odd + val
    }
  }

  dt / 3.0 * (values[start] + 4.0 * sum_odd + 2.0 * sum_even + values[end - 1])
}

///|
/// Computes cumulative integral array from `(timestamps, values)` using trapezoidal rule.
pub fn cumulative_integrate(
  timestamps : Array[Double],
  values : Array[Double],
) -> Array[Double] {
  let n = values.length()
  let cum : Array[Double] = Array::new(capacity=n)
  if n == 0 {
    return []
  }
  cum.push(0.0)
  let mut acc = 0.0
  for i = 0; i < n - 1; i = i + 1 {
    let dt = timestamps[i + 1] - timestamps[i]
    let avg_y = (values[i] + values[i + 1]) / 2.0
    acc = acc + avg_y * dt
    cum.push(acc)
  }
  cum
}
