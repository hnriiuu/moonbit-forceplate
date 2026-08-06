///|
/// Container holding key timestamps and sample indices detected during a force plate trial.
pub struct EventIndices {
  onset_idx : Int
  onset_timestamp : Double
  min_force_idx : Int
  min_force_timestamp : Double
  takeoff_idx : Int
  takeoff_timestamp : Double
  landing_idx : Int
  landing_timestamp : Double
  peak_force_idx : Int
  peak_force_timestamp : Double
} derive(Debug, Eq)

///|
pub fn EventIndices::new(
  onset_idx : Int,
  onset_timestamp : Double,
  min_force_idx : Int,
  min_force_timestamp : Double,
  takeoff_idx : Int,
  takeoff_timestamp : Double,
  landing_idx : Int,
  landing_timestamp : Double,
  peak_force_idx : Int,
  peak_force_timestamp : Double,
) -> EventIndices {
  {
    onset_idx,
    onset_timestamp,
    min_force_idx,
    min_force_timestamp,
    takeoff_idx,
    takeoff_timestamp,
    landing_idx,
    landing_timestamp,
    peak_force_idx,
    peak_force_timestamp,
  }
}

///|
/// Detects movement onset index using the standard 5*SD threshold method.
pub fn detect_movement_onset_5sd(
  fz : Array[Double],
  baseline_mean : Double,
  baseline_sd : Double,
) -> Int {
  let n = fz.length()
  let threshold = 5.0 * baseline_sd
  let quiet_window = if threshold < 10.0 { 10.0 } else { threshold }

  for i = 0; i < n - 30; i = i + 1 {
    let diff = (fz[i] - baseline_mean).abs()
    if diff > quiet_window {
      // Confirm onset persists for at least 30 consecutive samples (30 ms at 1000 Hz)
      let mut is_persistent = true
      for k = 1; k < 30; k = k + 1 {
        if (fz[i + k] - baseline_mean).abs() <= quiet_window / 2.0 {
          is_persistent = false
          break
        }
      }
      if is_persistent {
        return i
      }
    }
  }
  0
}

///|
/// Detects takeoff index (where vertical force drops below `threshold_n`, default 10 N).
pub fn detect_takeoff_index(
  fz : Array[Double],
  start_search_idx : Int,
  threshold_n : Double,
) -> Int {
  let n = fz.length()
  let start = if start_search_idx < 0 { 0 } else { start_search_idx }
  for i = start; i < n; i = i + 1 {
    if fz[i] < threshold_n {
      return i
    }
  }
  n - 1
}

///|
/// Detects landing index (where vertical force rises back above `threshold_n` after takeoff).
pub fn detect_landing_index(
  fz : Array[Double],
  takeoff_idx : Int,
  threshold_n : Double,
) -> Int {
  let n = fz.length()
  let start = if takeoff_idx < 0 { 0 } else { takeoff_idx }
  for i = start + 5; i < n; i = i + 1 {
    if fz[i] >= threshold_n {
      return i
    }
  }
  n - 1
}

///|
/// Finds index of minimum vertical force in specified index range.
pub fn find_min_force_index(
  fz : Array[Double],
  start_idx : Int,
  end_idx : Int,
) -> Int {
  let start = if start_idx < 0 { 0 } else { start_idx }
  let end = if end_idx > fz.length() { fz.length() } else { end_idx }
  if start >= end {
    return start
  }
  let mut min_val = fz[start]
  let mut min_i = start
  for i = start + 1; i < end; i = i + 1 {
    if fz[i] < min_val {
      min_val = fz[i]
      min_i = i
    }
  }
  min_i
}

///|
/// Finds index of peak vertical force in specified index range.
pub fn find_peak_force_index(
  fz : Array[Double],
  start_idx : Int,
  end_idx : Int,
) -> Int {
  let start = if start_idx < 0 { 0 } else { start_idx }
  let end = if end_idx > fz.length() { fz.length() } else { end_idx }
  if start >= end {
    return start
  }
  let mut max_val = fz[start]
  let mut max_i = start
  for i = start + 1; i < end; i = i + 1 {
    if fz[i] > max_val {
      max_val = fz[i]
      max_i = i
    }
  }
  max_i
}

///|
/// Automated detection of all major force plate jump events.
pub fn detect_all_jump_events(
  trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> EventIndices {
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()
  let n = trial.length()

  let quiet_cnt = if n > 200 { 200 } else { n / 2 }
  let quiet_fz : Array[Double] = Array::new(capacity=quiet_cnt)
  for i = 0; i < quiet_cnt; i = i + 1 {
    quiet_fz.push(fz[i])
  }
  let base_mean = if body_mass_kg > 0.0 {
    body_mass_kg * @kinetic.gravity_constant()
  } else {
    @core.compute_mean(quiet_fz)
  }
  let base_sd = @core.compute_std_dev(quiet_fz)

  let onset_i = detect_movement_onset_5sd(fz, base_mean, base_sd)
  let takeoff_i = detect_takeoff_index(fz, onset_i, 10.0)
  let landing_i = detect_landing_index(fz, takeoff_i, 10.0)
  let min_i = find_min_force_index(fz, onset_i, takeoff_i)
  let peak_i = find_peak_force_index(fz, onset_i, takeoff_i)

  EventIndices::new(
    onset_i,
    if onset_i < n {
      ts[onset_i]
    } else {
      0.0
    },
    min_i,
    if min_i < n {
      ts[min_i]
    } else {
      0.0
    },
    takeoff_i,
    if takeoff_i < n {
      ts[takeoff_i]
    } else {
      0.0
    },
    landing_i,
    if landing_i < n {
      ts[landing_i]
    } else {
      0.0
    },
    peak_i,
    if peak_i < n {
      ts[peak_i]
    } else {
      0.0
    },
  )
}
