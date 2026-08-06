///|
/// Structure holding bilateral left vs right load distribution and symmetry indices.
pub struct AsymmetryReport {
  left_share_percent : Double
  right_share_percent : Double
  symmetry_index_si : Double
  asymmetry_ratio_ar : Double
  abs_percent_difference : Double
  braking_peak_asymmetry_percent : Double
  propulsive_peak_asymmetry_percent : Double
  landing_peak_asymmetry_percent : Double
  dominant_side : String
} derive(Debug, Eq)

///|
/// Calculates Symmetry Index SI (%) = (Left - Right) / (0.5 * (Left + Right)) * 100.
pub fn calculate_symmetry_index(
  left_val : Double,
  right_val : Double,
) -> Double {
  let mean_val = (left_val + right_val) / 2.0
  if mean_val.abs() < 0.000001 {
    0.0
  } else {
    (left_val - right_val) / mean_val * 100.0
  }
}

///|
/// Calculates Asymmetry Ratio AR = Max(L, R) / Min(L, R).
pub fn calculate_asymmetry_ratio(
  left_val : Double,
  right_val : Double,
) -> Double {
  let min_val = if left_val < right_val { left_val } else { right_val }
  let max_val = if left_val > right_val { left_val } else { right_val }
  if min_val.abs() < 0.000001 {
    1.0
  } else {
    max_val / min_val
  }
}

///|
/// Calculates Absolute Percentage Difference (%) = |L - R| / Max(L, R) * 100.
pub fn calculate_abs_percent_diff(
  left_val : Double,
  right_val : Double,
) -> Double {
  let max_val = if left_val > right_val { left_val } else { right_val }
  if max_val.abs() < 0.000001 {
    0.0
  } else {
    (left_val - right_val).abs() / max_val * 100.0
  }
}

///|
/// Performs bilateral asymmetry analysis on two simultaneous force plate trials (Left plate & Right plate).
pub fn analyze_dual_plate_trials(
  left_trial : @core.ForceTrial,
  right_trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> AsymmetryReport {
  let left_fz = left_trial.get_fz()
  let right_fz = right_trial.get_fz()
  let n = if left_fz.length() < right_fz.length() {
    left_fz.length()
  } else {
    right_fz.length()
  }

  let mut total_left_impulse = 0.0
  let mut total_right_impulse = 0.0

  for i = 0; i < n; i = i + 1 {
    total_left_impulse = total_left_impulse + left_fz[i]
    total_right_impulse = total_right_impulse + right_fz[i]
  }

  let combined_impulse = total_left_impulse + total_right_impulse
  let left_pct = if combined_impulse > 0.001 {
    total_left_impulse / combined_impulse * 100.0
  } else {
    50.0
  }
  let right_pct = if combined_impulse > 0.001 {
    total_right_impulse / combined_impulse * 100.0
  } else {
    50.0
  }

  let si = calculate_symmetry_index(total_left_impulse, total_right_impulse)
  let ar = calculate_asymmetry_ratio(total_left_impulse, total_right_impulse)
  let apd = calculate_abs_percent_diff(total_left_impulse, total_right_impulse)

  // Segment combined trial to obtain phase bounds
  let comb_samples : Array[@core.ForceSample] = Array::new(capacity=n)
  let ts = left_trial.get_timestamps()
  for i = 0; i < n; i = i + 1 {
    let comb_fz = left_fz[i] + right_fz[i]
    comb_samples.push(
      @core.ForceSample::new(
        ts[i],
        @core.Vec3::new(0.0, 0.0, comb_fz),
        @core.Vec3::zero(),
        @core.CoPPoint::zero(),
      ),
    )
  }
  let comb_trial = @core.ForceTrial::new(left_trial.metadata, comb_samples)
  let events = @event.detect_all_jump_events(comb_trial, body_mass_kg)
  let phases = @event.segment_jump_phases(ts, left_fz, events, body_mass_kg)

  // Braking phase peak force asymmetry
  let brk_l = @core.compute_max(
    @jump.sub_array(left_fz, phases.braking_phase.0, phases.braking_phase.1),
  )
  let brk_r = @core.compute_max(
    @jump.sub_array(right_fz, phases.braking_phase.0, phases.braking_phase.1),
  )
  let brk_asym = calculate_abs_percent_diff(brk_l, brk_r)

  // Propulsive phase peak force asymmetry
  let prp_l = @core.compute_max(
    @jump.sub_array(
      left_fz,
      phases.propulsive_phase.0,
      phases.propulsive_phase.1,
    ),
  )
  let prp_r = @core.compute_max(
    @jump.sub_array(
      right_fz,
      phases.propulsive_phase.0,
      phases.propulsive_phase.1,
    ),
  )
  let prp_asym = calculate_abs_percent_diff(prp_l, prp_r)

  // Landing phase peak force asymmetry
  let lnd_l = @core.compute_max(
    @jump.sub_array(left_fz, phases.landing_phase.0, phases.landing_phase.1),
  )
  let lnd_r = @core.compute_max(
    @jump.sub_array(right_fz, phases.landing_phase.0, phases.landing_phase.1),
  )
  let lnd_asym = calculate_abs_percent_diff(lnd_l, lnd_r)

  let dominant = if total_left_impulse >= total_right_impulse {
    "Left"
  } else {
    "Right"
  }

  {
    left_share_percent: left_pct,
    right_share_percent: right_pct,
    symmetry_index_si: si,
    asymmetry_ratio_ar: ar,
    abs_percent_difference: apd,
    braking_peak_asymmetry_percent: brk_asym,
    propulsive_peak_asymmetry_percent: prp_asym,
    landing_peak_asymmetry_percent: lnd_asym,
    dominant_side: dominant,
  }
}
