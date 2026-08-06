///|
pub fn sub_array(arr : Array[Double], start : Int, end : Int) -> Array[Double] {
  let s = if start < 0 { 0 } else { start }
  let e = if end > arr.length() { arr.length() } else { end }
  let res : Array[Double] = Array::new(capacity=if e > s { e - s } else { 0 })
  for i = s; i < e; i = i + 1 {
    res.push(arr[i])
  }
  res
}

///|
/// Result metrics for a Countermovement Jump (CMJ) force plate analysis.
pub struct CMJReport {
  jump_height_flight_m : Double
  jump_height_impulse_m : Double
  rsi_modified : Double
  peak_force_n : Double
  peak_force_rel_bw : Double
  peak_power_w : Double
  peak_power_rel_w_kg : Double
  takeoff_velocity_m_s : Double
  eccentric_duration_s : Double
  concentric_duration_s : Double
  time_to_takeoff_s : Double
  events : @event.EventIndices
  phase_durations : @event.PhaseDurations
} derive(Debug, Eq)

///|
/// Analyzes a Countermovement Jump trial and generates a complete biomechanical CMJ metrics report.
pub fn analyze_cmj_trial(
  trial : @core.ForceTrial,
  body_mass_kg : Double,
) -> CMJReport {
  let g = @kinetic.gravity_constant()
  let body_weight = body_mass_kg * g
  let ts = trial.get_timestamps()
  let fz = trial.get_fz()

  let events = @event.detect_all_jump_events(trial, body_mass_kg)
  let phases = @event.segment_jump_phases(ts, fz, events, body_mass_kg)
  let phase_durs = @event.compute_phase_durations(ts, phases)

  let wf = @kinetic.compute_kinematics_from_trial(trial, body_mass_kg)

  let t_flight = phase_durs.flight_duration
  let h_flight = g * t_flight * t_flight / 8.0

  let v_takeoff = if events.takeoff_idx < wf.velocity.length() {
    wf.velocity[events.takeoff_idx]
  } else {
    0.0
  }
  let h_impulse = v_takeoff * v_takeoff / (2.0 * g)

  let t_takeoff = phase_durs.contact_duration
  let rsi_mod = if t_takeoff > 0.001 { h_flight / t_takeoff } else { 0.0 }

  let peak_f = @core.compute_max(fz)
  let peak_f_rel = peak_f / body_weight

  let peak_p = @core.compute_max(wf.power)
  let peak_p_rel = peak_p / body_mass_kg

  {
    jump_height_flight_m: h_flight,
    jump_height_impulse_m: h_impulse,
    rsi_modified: rsi_mod,
    peak_force_n: peak_f,
    peak_force_rel_bw: peak_f_rel,
    peak_power_w: peak_p,
    peak_power_rel_w_kg: peak_p_rel,
    takeoff_velocity_m_s: v_takeoff,
    eccentric_duration_s: phase_durs.braking_duration,
    concentric_duration_s: phase_durs.propulsive_duration,
    time_to_takeoff_s: t_takeoff,
    events,
    phase_durations: phase_durs,
  }
}
