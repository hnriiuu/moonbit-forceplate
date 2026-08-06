///|
/// Structure holding calculated impulse metrics over a specified interval.
pub struct ImpulseMetrics {
  total_impulse : Double
  net_impulse : Double
  braking_impulse : Double
  propulsive_impulse : Double
} derive(Debug, Eq)

///|
/// Calculates total, net, braking, and propulsive impulse over a specified sample range.
pub fn calculate_impulse(
  ts : Array[Double],
  fz : Array[Double],
  body_mass_kg : Double,
  start_idx : Int,
  end_idx : Int,
) -> ImpulseMetrics {
  let g = gravity_constant()
  let body_weight_n = body_mass_kg * g
  let start = if start_idx < 0 { 0 } else { start_idx }
  let end = if end_idx > fz.length() { fz.length() } else { end_idx }

  let mut total = 0.0
  let mut net = 0.0
  let mut braking = 0.0
  let mut propulsive = 0.0

  for i = start; i < end - 1; i = i + 1 {
    let dt = ts[i + 1] - ts[i]
    let avg_fz = (fz[i] + fz[i + 1]) / 2.0
    let avg_net = avg_fz - body_weight_n

    total = total + avg_fz * dt
    net = net + avg_net * dt

    if avg_net < 0.0 {
      braking = braking + avg_net.abs() * dt
    } else {
      propulsive = propulsive + avg_net * dt
    }
  }

  {
    total_impulse: total,
    net_impulse: net,
    braking_impulse: braking,
    propulsive_impulse: propulsive,
  }
}

///|
/// Structure holding Rate of Force Development (RFD) metrics.
pub struct RFDMetrics {
  peak_rfd : Double
  peak_rfd_timestamp : Double
  rfd_0_50ms : Double
  rfd_0_100ms : Double
  rfd_0_150ms : Double
  rfd_0_200ms : Double
} derive(Debug, Eq)

///|
/// Computes 1st derivative (dF/dt) using 2-point central differences.
pub fn compute_rfd_series(
  ts : Array[Double],
  fz : Array[Double],
) -> Array[Double] {
  let n = fz.length()
  let rfd : Array[Double] = Array::new(capacity=n)
  if n == 0 {
    return []
  }
  if n == 1 {
    return [0.0]
  }

  rfd.push((fz[1] - fz[0]) / (ts[1] - ts[0]))

  for i = 1; i < n - 1; i = i + 1 {
    let dt = ts[i + 1] - ts[i - 1]
    let df = fz[i + 1] - fz[i - 1]
    rfd.push(df / dt)
  }

  rfd.push((fz[n - 1] - fz[n - 2]) / (ts[n - 1] - ts[n - 2]))
  rfd
}

///|
/// Calculates windowed and peak Rate of Force Development (RFD, N/s) starting from `onset_idx`.
pub fn calculate_rfd_metrics(
  ts : Array[Double],
  fz : Array[Double],
  onset_idx : Int,
) -> RFDMetrics {
  let n = fz.length()
  let rfd_series = compute_rfd_series(ts, fz)

  let mut max_rfd = 0.0
  let mut max_t = 0.0

  let start = if onset_idx < 0 { 0 } else { onset_idx }
  let onset_t = if start < n { ts[start] } else { 0.0 }
  let onset_f = if start < n { fz[start] } else { 0.0 }

  for i = start; i < n; i = i + 1 {
    if rfd_series[i] > max_rfd {
      max_rfd = rfd_series[i]
      max_t = ts[i]
    }
  }

  fn find_window_rfd(target_dt : Double) -> Double {
    let target_t = onset_t + target_dt
    let mut end_i = start
    while end_i < n && ts[end_i] < target_t {
      end_i = end_i + 1
    }
    if end_i >= n {
      end_i = n - 1
    }
    let actual_dt = ts[end_i] - onset_t
    if actual_dt <= 0.000001 {
      0.0
    } else {
      (fz[end_i] - onset_f) / actual_dt
    }
  }

  {
    peak_rfd: max_rfd,
    peak_rfd_timestamp: max_t,
    rfd_0_50ms: find_window_rfd(0.05),
    rfd_0_100ms: find_window_rfd(0.10),
    rfd_0_150ms: find_window_rfd(0.15),
    rfd_0_200ms: find_window_rfd(0.20),
  }
}
